package MunkiDancer::Parser;
use Dancer ':syntax';
use MunkiDancer::Common;
use Mac::PropertyList qw( parse_plist_file );
use Exporter 'import';
our @EXPORT = qw(
    %catalog
    %host
    %manifest
    ParseCatalog
    ParseHost
);
our %catalog;   # hash with catalog entries
our %host;      # hash with host information
our %manifest;  # hash with host manifest entries

sub ParseCatalog {
    my ($name) = @_;

    my $catalogfile = Catalog($name);
    Error404("Catalog not found") if ( !$catalogfile);
    my $plist = parse_plist_file($catalogfile)
        or Error404("Catalog could not be parsed");

    %catalog = ();  # empty hash

    # store information of apps that are not updates
    foreach my $app (@{$plist->as_perl}) {
        next if ($app->{update_for} && !UpdateShownInCatalog($app));
        next if AppExcluded($app);

        # skip if an entry with higher version exists
        if( exists $catalog{$app->{name}} ) {
            (my $upd_vers = $app->{version}) =~ s/\.//g;
            (my $ori_vers = $catalog{$app->{name}}{version}) =~ s/\.//g ;
            next if( $upd_vers <= $ori_vers );
        }

        $catalog{$app->{name}} = {
            "id"          => $app->{name},
            "name"        => $app->{display_name} || $app->{name},
            "description" => $app->{description},
            "version"     => $app->{version},
        };
    }

    # updates increment version of corresponding app
    foreach my $app (@{$plist->as_perl}) {
        next unless $app->{update_for};

        foreach my $upd_for ( @{$app->{update_for}} ) {
            next if UpdateExcluded($app, $upd_for);
            next unless $catalog{$upd_for};

            (my $upd_vers = $app->{version}) =~ s/\.//g;
            (my $ori_vers = $catalog{$upd_for}{version}) =~ s/\.//g ;
            if( $upd_vers > $ori_vers ) {
                $catalog{$upd_for}{version} = $app->{version};
            }
        }
    }

    # fetch additional app info
    FetchAppInfo($name);

    return 1;
}

sub FetchAppInfo {
    my ($name) = @_;

    my $infofile = AppInfo($name);
    Error404("AppInfo file not found") if ( !$infofile);

    open(INFO, '<', $infofile)
        or Error404("AppInfo file could not be opened");
    foreach my $line (<INFO>) {
        chomp($line);
        next if $line=~ m/^#/;                          # skip comments starting with #
        my ($id, $url, $lic) = split ('\*', "$line");   # retrieve app id, url and license separated by *
        if (exists $catalog{$id}) {                     # add info if entry for this app exists
            $catalog{$id}{producturl} = $url || '';
            $catalog{$id}{license}    = $lic || 'free';
        }
    }

    return 1;
}

sub ParseHost {
    my ($name) = @_;

    # initialize hashes
    %host     = ();
    %manifest = ();
    $manifest{name} = $name;

    my $manifestfile = Manifest($name);
    Error404("Host not found") if ( !$manifestfile);
    my $plist = parse_plist_file($manifestfile)
        or Error404("Host could not be parsed");

    # loop over relevant entries
    foreach my $key qw( catalogs included_manifests managed_installs optional_installs ) {
        foreach my $entry (@{ ${$plist->as_perl}{$key} }) {
            push(@{ $manifest{$key} }, $entry); # push to hash of arrays
        }
    }

    # parse included bundles
    foreach my $bundle (@{ $manifest{included_manifests} }) {
        ParseBundle($bundle);
    }

    # parse used catalogs
    foreach my $catalog (@{ $manifest{catalogs} }) {
        ParseCatalog($catalog);
    }

    # store info about installed packages in hash
    foreach my $type qw( optional_installs managed_installs ) {
        foreach my $app (@{ $manifest{$type} }) {
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
    Error404("Bundle $name not found") if ( !$bundlefile);
    my $plist = parse_plist_file($bundlefile)
        or Error404("Bundle $name could not be parsed");

    # recursively parse included manifests
    foreach my $bundle (@{ ${$plist->as_perl}{included_manifests} }) {
        ParseBundle($bundle);
    }

    foreach my $key qw( included_manifests optional_installs managed_installs ) {
        foreach my $entry (@{ ${$plist->as_perl}{$key} }) {
            push(@{ $manifest{$key} }, $entry); # push to hash of arrays
        }
    }

    return 1;
}

1;
