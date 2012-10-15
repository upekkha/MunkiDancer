use Test::More;
use strict;
use warnings;
use lib qw( lib/ );

use MunkiDancer::Routes;
use Dancer::Test;
my $url;

# ensure correct parsing of catalog
$url = '/catalog/testcatalog';
    response_content_like    [GET => $url],     qr|<tr>\s*<td>TestApp|,                                         "$url: App is listed";
    response_content_like    [GET => $url],     qr|<td>Test description</td>|,                                  "$url: Description is listed";
    response_content_like    [GET => $url],     qr|>Test display name<|,                                        "$url: Display name is listed";
    response_content_like    [GET => $url],     qr|href="http://TestApp\.example\.com"|,                        "$url: Product url is listed";
    response_content_like    [GET => $url],     qr|<td>ides</td>|,                                              "$url: License ides is listed";
    response_content_like    [GET => $url],     qr|<td>free</td>|,                                              "$url: License free is listed";
    response_content_unlike  [GET => $url],     qr|<td>SecondTestAppUpd|,                                       "$url: Update is not listed";
    response_content_unlike  [GET => $url],     qr|<td>AppNotThereUpd|,                                         "$url: Update without app is ignored";
    response_content_unlike  [GET => $url],     qr|<td>ExcludedApp|,                                            "$url: Excluded App is not listed";
    response_content_unlike  [GET => $url],     qr|<td>ExcludedUpdate|,                                         "$url: Excluded Update is not listed";
    response_content_like    [GET => $url],     qr|<td>This is an app and update</td>|,                         "$url: Excluded Update included as app is listed";
    response_content_like    [GET => $url],     qr|<td>Last description is shown</td>|,                         "$url: Multiple entries: last description is shown";
    response_content_unlike  [GET => $url],     qr|<td>First description is ignored</td>|,                      "$url: Multiple entries: first description is ignored";
    response_content_unlike  [GET => $url],     qr|<td>Middle description is ignored</td>|,                     "$url: Multiple entries: middle description is ignored";
    response_content_like    [GET => $url],     qr|>0\.13</td>|,                                                "$url: Multiple entries: highest version";
    response_content_unlike  [GET => $url],     qr|>1\.0\.5</td>|,                                              "$url: Update with lower version is ignored";
    response_content_like    [GET => $url],     qr|>1\.1\.0</td>|,                                              "$url: Update increments version (above)";
    response_content_like    [GET => $url],     qr|>2\.1\.0</td>|,                                              "$url: Update increments version (below)";

# route to poll if catalog exists
$url = '/catalog/testcatalog/exists';
    response_content_like    [GET => $url],     qr|"exists"\s*:\s*"1"|,                                         "$url: Exists = 1";
$url = '/catalog/testnotthere/exists';
    response_content_like    [GET => $url],     qr|"exists"\s*:\s*"0"|,                                         "$url: Exists = 0";

# raw data should have json content-type
foreach $url qw( /catalog/testcatalog/raw /catalog/testcatalog/exists /catalog/testnotthere/exists ) {
    response_headers_include [GET => $url],     [ 'Content-Type' => 'application/json' ],                       "$url: Content-type is json";
}

done_testing();
