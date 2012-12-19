use Test::More;
use strict;
use warnings;
use lib qw( lib/ );

# required by perl dancer
require_ok 'Dancer';
use_ok 'Template';
use_ok 'YAML';
# required for auto_reload
use_ok 'Clone';
use_ok 'Module::Refresh';
# required to parse plist files
use_ok 'Mac::PropertyList';
# required to output json
use_ok 'JSON';
# required to download webpages
use_ok 'WWW::Mechanize';
# application's modules
use_ok 'MunkiDancer::Common';
use_ok 'MunkiDancer::Routes';
use_ok 'MunkiDancer::Parser';
use_ok 'MunkiDancer::LookForUpdates';

done_testing();
