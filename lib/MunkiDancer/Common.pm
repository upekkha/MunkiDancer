package MunkiDancer::Common;
use Dancer ':syntax';
use Exporter 'import';
our @EXPORT = qw(
    Catalog
    Manifest
    AppInfo
    AppExcluded
    UpdateExcluded
    UpdateShownInCatalog
    Error404
);

sub RepoPath {
    my ($file) = @_;

    my $RepoPath = './repo';    # local symlink to repository
    $RepoPath = './t/testrepo' if ($file =~ /test/ && $file ne 'testing');

    return $RepoPath;
}

sub Catalog {
    my ($name) = @_;

    my $file = RepoPath($name) . "/catalogs/$name";
    return 0 unless (-e $file);

    return $file;
}

sub Manifest {
    my ($name) = @_;

    my $file = RepoPath($name) . "/manifests/$name";
    return 0 unless (-e $file);

    return $file;
}

sub AppInfo {
    my ($name) = @_;

    my $file = RepoPath($name) . "/web/appurls.dat";
    return 0 unless (-e $file);

    return $file;
}

sub AppExcluded {
    my ($app) = @_;

    my $excluded_names = 'LicISG|Dphys|unlicensed|ISGmacports|ManagedClient|Munki';

    if( exists $app->{name} ) {
        return 1 if $app->{name} =~ m/$excluded_names/i;
    }
    if( exists $app->{installer_item_location} ) {
        return 1 if $app->{installer_item_location} =~ m/Driver|Kostenstelle/;
    }
}

sub UpdateExcluded {
    my ($app, $upd_for) = @_;

    if( exists $app->{name} ) {
        return 1 if $app->{name} =~ m/MSRemoteDesktop|ExcludedUpdate/i;
    }
}

sub UpdateShownInCatalog {
    my ($app) = @_;

    if( exists $app->{name} ) {
        return 1 if $app->{name} =~ m/MSRemoteDesktop/i;
    }
}

sub Error404 {
    my ($title) = @_;

    set serializer => '';       # make sure we return unserialized error

    Dancer::Continuation::Route::ErrorSent->new(
        return_value => Dancer::Error->new(
            code     => 404,
            title    => $title,
        )->render()
    )->throw
}
