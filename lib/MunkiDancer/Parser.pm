package MunkiDancer::Parser;
use Dancer ':syntax';
use MunkiDancer::Common;
use Mac::PropertyList qw( parse_plist_file );
use Exporter 'import';
our @EXPORT = qw(
    %catalog
    ParseCatalog
);
our %catalog;   # hash with catalog entries

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
            "name"         => $app->{name},
            "display_name" => $app->{display_name} || $app->{name},
            "description"  => $app->{description},
            "version"      => $app->{version},
        };
    }

    return 1;
}

1;
