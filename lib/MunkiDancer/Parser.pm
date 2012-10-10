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

    my $catalogfile = RepoPath($name) . "/catalogs/$name";
    Error404("Catalog not found") if ( ! -e $catalogfile);
    my $plist = parse_plist_file($catalogfile)
        or Error404("Catalog could not be parsed");

    %catalog = ();  # empty hash

    # loop over applications in catalog
    foreach my $app (@{$plist->as_perl}) {
        # store information in hash
        $catalog{$app->{name}} = {
            "id"          => $app->{name},
            "name"        => $app->{display_name} || $app->{name},
            "description" => $app->{description},
            "version"     => $app->{version},
        };
    }

    return 1;
}

sub ParseHost {
    my ($name) = @_;

    my $manifestfile = RepoPath($name) . "/manifests/$name";
    Error404("Host not found") if ( ! -e $manifestfile);
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
