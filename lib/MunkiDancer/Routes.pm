package MunkiDancer::Routes;
use Dancer ':syntax';
use MunkiDancer::Parser;

get '/' => sub {
    "MunkiDancer";
};

get '/catalog/:name' => sub {
    ParseCatalog(param('name'));
};

1;
