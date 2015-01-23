package MunkiDancer::LookForUpdates;
use Dancer ':syntax';
use MunkiDancer::Common;
use MunkiDancer::Parser;
use WWW::Mechanize;
use Exporter 'import';
our @EXPORT = qw(
    LookForUpdates
);

sub LookForUpdates {
    foreach my $id ( keys %catalog ) {
        my $latest_version = LatestVersion($id);
        next if $latest_version eq 'N/A';
        if ( $catalog{$id}{version} ne $latest_version ) {
            $catalog{$id}{latest_version} = $latest_version;
        }
    }
    return 1;
}

sub LatestVersion {
    my ($id) = @_;

    return 'N/A' if LookForUpdateExcluded($id);
    return 'N/A' unless exists $catalog{$id}{update_url};
    return 'N/A' unless $catalog{$id}{update_url} =~ m/macupdate/i;

    my $mech = WWW::Mechanize->new();
    $mech->get( $catalog{$id}{update_url}, 'Accept-Encoding' => 'identity' );
    my $html = $mech->content || '';

    my $match_version_number = qr{
        id="app_info_version_2"     # id used for version numbers
        [^>]* >                     # closing bracket of that tag
        \s*                         # ignore spaces and newlines
        (.*?)                       # extract version number
        \s*                         # ignore spaces and newlines
        <\/h4>                      # closing header tag
    }xi;

    (my $version) = $html =~ m/$match_version_number/;

    return 'N/A' unless $version;

    return $version;
}
