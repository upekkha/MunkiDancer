package MunkiDancer::Parser;
use Dancer ':syntax';
use MunkiDancer::Common;
use Mac::PropertyList qw( parse_plist parse_plist_file );
use Sort::Versions;
use YAML::Tiny;
use Exporter 'import';
our @EXPORT = qw(
    %catalog
    %host
    %manifest
    ParseCatalog
    CleanCatalog
    ParseHost
    HostsWithPackage
    HostsPerCostunit
    Licenses
);
our %catalog;       # hash with catalog entries
our %host;          # hash with host information
our %manifest;      # hash with host manifest entries
our %catalog_mtime; # hash with time of catalog's last modification

sub ParseCatalog {
    my ($name) = @_;

    my $catalogfile = Catalog($name);
    Error404("Catalog not found") unless $catalogfile;

    # skip parsing catalog if file has was not changed
    my $mtime = (stat $catalogfile)[9];
    return 1 if ( defined $catalog_mtime{$name} && $mtime == $catalog_mtime{$name} );
    $catalog_mtime{$name} = $mtime;

    my $plist = parse_plist( CleanCatalog($catalogfile) )
        or Error404("Catalog could not be parsed");

    %catalog = ();  # empty hash

    # store information of apps that are not updates
    foreach my $app ( @{$plist->as_perl} ) {
        next if ( $app->{update_for} && !UpdateShownInCatalog($app) );
        next if AppExcluded($app);

        # skip if an entry with higher version exists
        if ( exists $catalog{$app->{name}} ) {
            my $upd_vers = $app->{version};
            my $ori_vers = $catalog{$app->{name}}{version};
            next if versioncmp( $upd_vers, $ori_vers ) == -1;    # upd_vers < ori_vers
        }

        my $id   = $app->{name};
        my $name = $app->{display_name} || $id;

        $catalog{$id} = {
            "id"          => $id,
            "name"        => $name,
            "description" => $app->{description},
            "version"     => $app->{version},
            "producturl"  => DefaultProductUrl($name),
        };
    }

    # updates increment version of corresponding app
    foreach my $app ( @{$plist->as_perl} ) {
        next unless $app->{update_for};

        foreach my $upd_for ( @{$app->{update_for}} ) {
            next if UpdateExcluded($app, $upd_for);
            next unless $catalog{$upd_for};

            (my $upd_vers = $app->{version})             =~ s/\.//g;
            (my $ori_vers = $catalog{$upd_for}{version}) =~ s/\.//g;
            if ( $upd_vers > $ori_vers ) {
                $catalog{$upd_for}{version} = $app->{version};
            }
        }
    }

    # fetch additional app info
    FetchAppInfo($name);

    return 1;
}

sub CleanCatalog {
    my ($catalogfile) = @_;

    # read lines of catalog file into array
    open my $CATALOG, '<', $catalogfile
        or die "Can't open file: $!";
    chomp( my @lines = <$CATALOG> );
    close $CATALOG or die "Couldn't close file: $!";

    my @catalog_cleaned = ();

    for my $i (0..$#lines) {
        # Keep specific pkginfo tags
        if ( $lines[$i] =~ /^\t\t<key>(description|name|display_name|version|installer_item_location)<\/key>/ ) {
            push( @catalog_cleaned, $lines[$i], $lines[$i+1] );
            next;
        }

        # Keep update_for tags
        if ( $lines[$i] =~ /^\t\t<key>update_for<\/key>/ ) {
            my $j = 0;
            until( $lines[$i+$j] =~ /^\t\t<\/array>/ ) {
                push( @catalog_cleaned, $lines[$i+$j] );
                $j++;
            }
            push( @catalog_cleaned, $lines[$i+$j] );
            next;
        }

        # Keep unindented tags, and first level dicts separating packages
        if ( $lines[$i] =~ /^</ or $lines[$i] =~ /^\t<(\/)?dict/ ) {
            push( @catalog_cleaned, $lines[$i] );
            next;
        }
    }

    return join( "\n", @catalog_cleaned );
}

sub FetchAppInfo {
    my ($name) = @_;

    my $infofile = AppInfo($name);
    Error404("AppInfo file not found") unless $infofile;

    my $yaml = YAML::Tiny->read($infofile)
        or Error404("AppInfo file could not be parsed");

    my %appinfo = %{$yaml->[0]};
    foreach my $id ( keys %appinfo ) {
        if ( exists $catalog{$id} ) {
            $catalog{$id}{license} = $appinfo{$id}{license} || 'free';
            if ( exists $appinfo{$id}{homepage} ) {
                $catalog{$id}{producturl} = $appinfo{$id}{homepage};
            }
            if ( exists $appinfo{$id}{update_url} ) {
                $catalog{$id}{update_url} = $appinfo{$id}{update_url};
            }
            if ( exists $appinfo{$id}{idesprice} ) {
                $catalog{$id}{idesprice} = $appinfo{$id}{idesprice};
            }
        }
    }

    return 1;
}

sub ParseHost {
    my ($name) = @_;

    # initialize hashes
    %host           = ();
    %manifest       = ();
    $manifest{name} = $name;

    my $manifestfile = Manifest($name);
    Error404("Host not found") unless $manifestfile;
    my $plist = parse_plist_file($manifestfile)
        or Error404("Host could not be parsed");

    # loop over relevant entries
    foreach my $key (qw( catalogs included_manifests managed_installs optional_installs )) {
        foreach my $entry ( @{${$plist->as_perl}{$key}} ) {
            push( @{$manifest{$key}}, $entry ); # push to hash of arrays
        }
    }

    # parse included bundles
    foreach my $bundle ( @{$manifest{included_manifests}} ) {
        ParseBundle($bundle);
    }

    # parse used catalogs
    foreach my $catalog ( @{$manifest{catalogs}} ) {
        ParseCatalog($catalog);
    }

    # store info about installed packages in hash
    foreach my $type (qw( optional_installs managed_installs )) {
        foreach my $app ( @{$manifest{$type}} ) {
            next unless defined $catalog{$app};
            $host{$app} = $catalog{$app};
            $host{$app}{install_type} = $type;
        }
    }

    return 1;
}

sub ParseBundle {
    my ($name) = @_;

    my $bundlefile = Manifest("$name");
    Error404("Bundle $name not found") unless $bundlefile;
    my $plist = parse_plist_file($bundlefile)
        or Error404("Bundle $name could not be parsed");

    # recursively parse included manifests
    foreach my $bundle ( @{${$plist->as_perl}{included_manifests}} ) {
        ParseBundle($bundle);
    }

    foreach my $key (qw( included_manifests optional_installs managed_installs )) {
        foreach my $entry ( @{${$plist->as_perl}{$key}} ) {
            push( @{$manifest{$key}}, $entry );    # push to hash of arrays
        }
    }

    return 1;
}

sub HostsWithPackage {
    my ($pkg) = @_;
    return () unless $pkg =~ /^[a-zA-Z0-9\-_]+$/;

    my $appdir = config->{appdir};
    my @hosts = `cd $appdir/repo/manifests; rgrep -l '^[^\-]*>$pkg<'`;
    chomp @hosts;

    return @hosts;
}

sub HostsPerCostunit {
    my %HostsPerCostunit;

    my $appdir = config->{appdir};
    foreach my $line (`cd $appdir/repo/manifests && rgrep Kostenstelle`) {
        if ( $line =~ m%([^/]*):\s*<string>Kostenstelle(\d{5})</string>% ) {
            my $hostname = $1;
            my $costunit = $2;
            push( @{$HostsPerCostunit{$costunit}}, $hostname );
        }
    }

    return %HostsPerCostunit;
}

sub Licenses {
    my %Licenses;

    my @HostsWithCostunit;
    my %HostsPerCostunit = HostsPerCostunit();
    foreach my $Costunit (keys %HostsPerCostunit) {
        push( @HostsWithCostunit, @{ $HostsPerCostunit{$Costunit} } );
    }

    ParseCatalog('testing');
    foreach my $app (keys %catalog) {
        if( defined ${catalog}{$app}{license} and ${catalog}{$app}{license} eq 'ides' ){
            $Licenses{$app}{idesprice} = ${catalog}{$app}{idesprice} // '';
            my @hosts_with_app = HostsWithPackage($app);
            foreach my $host_with_costunit ( sort @HostsWithCostunit) {
                if( grep { $_ eq $host_with_costunit } @hosts_with_app ) {
                    push( @{$Licenses{$app}{hosts}}, $host_with_costunit );
                    $Licenses{$app}{installations} += 1;
                }
            }
        }
    }

    return %Licenses;
}

1;
