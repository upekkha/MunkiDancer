package MunkiDancer::Parser;
use Dancer ':syntax';
use MunkiDancer::Common;
use Mac::PropertyList qw( parse_plist_file );
use Exporter 'import';
our @EXPORT = qw(
    %catalog
    %host
    ParseCatalog
    ParseHost
);
our %catalog;   # hash with catalog entries
our %host;      # hash with host information

sub ParseCatalog {
    my ($name) = @_;

    my $catalogfile = Catalog($name);
    Error404("Catalog not found") if ( !$catalogfile);
    my $plist = parse_plist_file($catalogfile)
        or Error404("Catalog could not be parsed");

    %catalog = ();  # empty hash

    # store information of apps that are not updates
    foreach my $app (@{$plist->as_perl}) {
        next if $app->{update_for};
        next if AppExcluded($app);

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

    my $manifestfile = Manifest($name);
    Error404("Host not found") if ( !$manifestfile);
    my $plist = parse_plist_file($manifestfile)
        or Error404("Host could not be parsed");

    %host = ();  # empty hash
    $host{name} = $name;

    # loop over relevant entries
    foreach my $key qw( catalogs managed_installs included_manifests ) {
        foreach my $entry (@{ ${$plist->as_perl}{$key} }) {
            push(@{ $host{$key} }, $entry);     # push to hash of arrays
        }
    }

    return 1;
}

1;
