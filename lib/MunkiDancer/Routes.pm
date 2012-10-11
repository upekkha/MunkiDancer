package MunkiDancer::Routes;
use Dancer ':syntax';
use MunkiDancer::Common;
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

get '/catalog/:name/exists' => sub {
    my $exists = '0';
    $exists = '1' if Catalog(param('name'));
    my %state = (
        exists => $exists,
    );

    set serializer => 'JSON';
    return \%state;
};

get '/catalog/:name/raw' => sub {
    ParseCatalog(param('name'));
    set serializer => 'JSON';

    return \%catalog;
};

get '/host/:name' => sub {
    ParseHost(param('name'));

    template 'host' => {
        host => \%host,
    };
};

get '/host/:name/exists' => sub {
    my $exists = '0';
    $exists = '1' if Manifest(param('name'));
    my %state = (
        exists => $exists,
    );

    set serializer => 'JSON';
    return \%state;
};


get '/host/:name/raw' => sub {
    ParseHost(param('name'));
    set serializer => 'JSON';

    return \%host;
};

1;
