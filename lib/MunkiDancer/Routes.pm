package MunkiDancer::Routes;
use Dancer ':syntax';
use MunkiDancer::Common;
use MunkiDancer::Parser;

get '/' => sub {
    template 'munki';
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
    my %state = (
        exists => Catalog(param('name')) ? '1' : '0',
    );

    set serializer => 'JSON';
    return \%state;
};

get '/catalog/:name/table' => sub {
    ParseCatalog(param('name'));
    my %sortedcatalog;
    foreach my $id ( keys %catalog ) {
        foreach my $key ( keys %{ $catalog{$id} } ) {
            $sortedcatalog{$catalog{$id}{name}}{$key} = $catalog{$id}->{$key};
        }
    }

    template 'munki-table' => {
        catalog => \%sortedcatalog,
    };
};


get '/catalog/:name/raw' => sub {
    ParseCatalog(param('name'));
    set serializer => 'JSON';

    return \%catalog;
};

get '/host/:name' => sub {
    ParseHost(param('name'));

    template 'host' => {
        host     => \%host,
        manifest => \%manifest,
    };
};

get '/host/:name/exists' => sub {
    my %state = (
        exists => Manifest(param('name')) ? '1' : '0',
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
