package MunkiDancer::Routes;
use Dancer ':syntax';
use MunkiDancer::Parser;

get '/' => sub {
    "MunkiDancer";
};

get '/lib/:file' => sub {
    # send files in public/lib
    send_file param('file');
};

get '/catalog/:name' => sub {
    ParseCatalog(param('name'));

    template 'catalog' => {
        catalog => \%catalog,
    };
};

get '/catalog/:name/raw' => sub {
    ParseCatalog(param('name'));
    set serializer => 'JSON';

    return \%catalog;
};

1;
