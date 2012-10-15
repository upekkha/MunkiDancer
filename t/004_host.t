use Test::More;
use strict;
use warnings;
use lib qw( lib/ );

use MunkiDancer::Routes;
use Dancer::Test;
my $url;

# ensure correct parsing of host manifest
$url = '/host/testhost';
    response_content_like    [GET => $url],     qr|<h2>Host testhost</h2>|,                                     "$url: Host name is listed";
    response_content_like    [GET => $url],     qr|catalogs:\s*testcatalog\s*</br>|,                            "$url: Catalog is listed";
    response_content_like    [GET => $url],     qr|included_manifests:\s*bundles/testbundle\s*</br>|,           "$url: Bundle is listed";
    response_content_like    [GET => $url],     qr|managed_installs:|,                                          "$url: Managed installs are listed";
    response_content_like    [GET => $url],     qr|TestApp|,                                                    "$url: App from bundle is listed";
    response_content_like    [GET => $url],     qr|SecondTestApp|,                                              "$url: App from manifest is listed";

# route to poll if host exists
$url = '/host/testhost/exists';
    response_content_like    [GET => $url],     qr|"exists"\s*:\s*"1"|,                                         "$url: Exists = 1";
$url = '/host/testnotthere/exists';
    response_content_like    [GET => $url],     qr|"exists"\s*:\s*"0"|,                                         "$url: Exists = 0";

# raw data should have json content-type
foreach $url qw( /host/testhost/raw /host/testhost/exists /host/testnotthere/exists ) {
    response_headers_include [GET => $url],     [ 'Content-Type' => 'application/json' ],                       "$url: Content-type is json";
}

done_testing();
