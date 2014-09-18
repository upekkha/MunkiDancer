package MunkiDancer::Routes;
use Dancer ':syntax';
use MunkiDancer::Common;
use MunkiDancer::Parser;
use MunkiDancer::LookForUpdates;

get '/' => sub {
    template 'munki' => {
        ajaxurl    => 'catalog/testing/table',
        loadingmsg => 'Gathering application list...',
    };
};

get '/updates' => sub {
    template 'munki' => {
        ajaxurl    => 'catalog/testing/updates-table',
        loadingmsg => 'Gathering application list and checking for updates. This may take a minute...',
    };
};

get '/catalog/:name' => sub {
    ParseCatalog( param('name') );

    template 'catalog' => {
        catalog => \%catalog,
    };
};

get '/catalog/:name/exists' => sub {
    my %state = ( exists => Catalog( param('name') ) ? '1' : '0', );
    set serializer => 'JSON';

    return \%state;
};

get '/catalog/:name/table' => sub {
    ParseCatalog( param('name') );
    my %sortedcatalog;
    foreach my $id ( keys %catalog ) {
        foreach my $key ( keys %{$catalog{$id}} ) {
            $sortedcatalog{$catalog{$id}{name}}{$key} = $catalog{$id}->{$key};
        }
    }

    template 'munki-table' => {
        catalog => \%sortedcatalog,
    };
};

get '/catalog/:name/updates-table' => sub {
    ParseCatalog( param('name') );
    LookForUpdates();
    my %sortedcatalog;
    foreach my $id ( keys %catalog ) {
        next unless $catalog{$id}->{latest_version};
        foreach my $key ( keys %{$catalog{$id}} ) {
            $sortedcatalog{$catalog{$id}{name}}{$key} = $catalog{$id}->{$key};
        }
        $sortedcatalog{$catalog{$id}{name}}{producturl} = $catalog{$id}->{update_url};
    }

    template 'munki-table' => {
        catalog => \%sortedcatalog,
    };
};

get '/catalog/:name/json' => sub {
    ParseCatalog( param('name') );
    set serializer => 'JSON';

    return \%catalog;
};

get '/host/:name' => sub {
    ParseHost( param('name') );

    template 'host' => {
        host     => \%host,
        manifest => \%manifest,
    };
};

get '/host/:name/exists' => sub {
    my %state = ( exists => Manifest( param('name') ) ? '1' : '0', );
    set serializer => 'JSON';

    return \%state;
};

get '/host/:name/json' => sub {
    ParseHost( param('name') );
    set serializer => 'JSON';

    return \%host;
};

get '/costunits/json' => sub {
    my %HostsPerCostunit = HostsPerCostunit();
    set serializer => 'JSON';

    return \%HostsPerCostunit;
};

get '/costunit/:number/json' => sub {
    my $number = param('number');
    my @hostnames = HostsWithPackage("Kostenstelle$number");
    my @hosts = ();
    foreach my $hostname (@hostnames) {
        push (@hosts, { costunit => $number, hostname => $hostname } );
    }
    set serializer => 'JSON';

    return \@hosts;
};

1;
