package MunkiDancer::Routes;
use Dancer ':syntax';
use MunkiDancer::Parser;

get '/' => sub {
    "MunkiDancer";
};

get '/catalog/:name' => sub {
    ParseCatalog(param('name'));

    template 'catalog' => {
        catalog => \%catalog,
    };
};

1;
