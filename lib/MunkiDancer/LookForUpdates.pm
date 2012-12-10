package MunkiDancer::LookForUpdates;
use Dancer ':syntax';
use MunkiDancer::Common;
use MunkiDancer::Parser;
use Exporter 'import';
our @EXPORT = qw(
    LookForUpdates
);

sub LookForUpdates {
    foreach my $id ( keys %catalog ) {
        my $latest_version  = LatestVersion($id);
        next if $latest_version eq 'N/A';
        if ($catalog{$id}{version} ne $latest_version) {
            $catalog{$id}{latest_version} = $latest_version;
        }
    }
    return 1;
}

sub LatestVersion {
    my ($id) = @_;

    return 'N/A' if LookForUpdateExcluded($id);
    return 'N/A' unless $catalog{$id}{producturl} =~ m/macupdate/i;

    my $html = `curl --silent $catalog{$id}{producturl}` || '';
    (my $version) = $html =~ m/<span id="appversinfo">(.*)<\/span>/i;

    return 'N/A' unless $version;

    return $version;
}
