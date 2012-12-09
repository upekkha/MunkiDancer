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
    response_content_like    [GET => $url],     qr|Catalogs:\s*testcatalog\s*</br>|,                            "$url: Catalog is listed";
    response_content_like    [GET => $url],     qr|Included Manifests:((?!</br>).)*bundles/testbundle|s,        "$url: Included bundle is listed";
    response_content_like    [GET => $url],     qr|Included Manifests:((?!</br>).)*bundles/testinclude|s,       "$url: Deeply included bundle is listed";
    response_content_like    [GET => $url],     qr|<td>TestApp|,                                                "$url: App from bundle is listed";
    response_content_like    [GET => $url],     qr|<td>IncludedOptionalApp|,                                    "$url: App from deeply included bundle is listed";
    response_content_like    [GET => $url],     qr|<td>SecondTestApp|,                                          "$url: App from manifest is listed";
    response_content_unlike  [GET => $url],     qr|<td>ExcludedApp|,                                            "$url: Excluded App is not listed";
    response_content_like    [GET => $url],     qr|<td>Test description</td>|,                                  "$url: Description is listed";
    response_content_like    [GET => $url],     qr|>Test display name<|,                                        "$url: Display name is listed";
    response_content_like    [GET => $url],     qr|href="http://TestApp\.example\.com"|,                        "$url: Product url is listed";
    response_content_like    [GET => $url],     qr|<td>ides</td>|,                                              "$url: License ides is listed";
    response_content_like    [GET => $url],     qr|<td>free</td>|,                                              "$url: License free is listed";
    response_content_like    [GET => $url],     qr|<td>managed_installs</td>|,                                  "$url: Managed installs are listed";
    response_content_like    [GET => $url],     qr|<td>optional_installs</td>|,                                 "$url: Optional installs are listed";
    response_content_like    [GET => $url],     qr|<td>ManagedOptionalApp</td>((?!</tr>).)*managed_installs|s,  "$url: Managed overrides optional";

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
