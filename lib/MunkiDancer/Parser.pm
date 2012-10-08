package MunkiDancer::Parser;
use Dancer ':syntax';
use Mac::PropertyList qw( parse_plist_file );
use Exporter 'import';
our @EXPORT = qw(
    ParseCatalog
);

sub ParseCatalog {
    my ($name) = @_;

    return $name;
}

1;
