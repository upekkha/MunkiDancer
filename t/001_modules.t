use Test::More;
use strict;
use warnings;
use lib qw( lib/ );

use_ok 'MunkiDancer::Common';
use_ok 'MunkiDancer::Routes';
use_ok 'MunkiDancer::Parser';
use_ok 'MunkiDancer::LookForUpdates';
use_ok 'Mac::PropertyList';

done_testing();
