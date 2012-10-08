package MunkiDancer::Parser;
use Dancer ':syntax';
use Mac::PropertyList qw( parse_plist_file );
use Exporter 'import';
our @EXPORT = qw(
    %catalog
    ParseCatalog
);
our %catalog;   # hash with catalog entries

sub ParseCatalog {
    my ($name) = @_;

    %catalog = ();  # empty hash
    my $plist = parse_plist_file("./t/testrepo/catalogs/testcatalog");

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
