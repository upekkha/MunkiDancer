use Test::More;
use strict;
use warnings;
use lib qw( lib/ );

use MunkiDancer::Routes;
use Dancer::Test;

my @defined_routes = (
    '/',
    '/catalog/testcatalog',
    '/catalog/testcatalog/raw',
    '/lib/style.css',
);
foreach my $url (@defined_routes) {
    route_exists        [GET => $url],                  "$url: route handler is defined";
    response_status_is  [GET => $url],          200,    "$url: response status is 200";
}

my @defined_error_routes = (
    '/catalog/testnotthere',
    '/catalog/testnotthere/raw',
);
foreach my $url (@defined_error_routes) {
    route_exists        [GET => $url],                  "$url: route handler is defined";
    response_status_is  [GET => $url],          404,    "$url: response status is 404";
}

my @undefined_routes = (
    '.',
);
foreach my $url (@undefined_routes) {
    route_doesnt_exist  [GET => $url],                  "$url: route handler is not defined";
    response_status_is  [GET => $url],          404,    "$url: response status is 404";
}

done_testing();
