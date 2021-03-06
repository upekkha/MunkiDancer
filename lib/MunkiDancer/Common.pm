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
    LookForUpdateExcluded
    DefaultProductUrl
    Error404
);

sub RepoPath {
    my ($file) = @_;

    my $RepoPath = config->{appdir} . '/repo';    # local symlink to repository
    $RepoPath = './t/testrepo' if ( $file =~ /test/ && $file ne 'testing' );

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

    my $file = RepoPath($name) . '/web/appinfo.yml';
    return 0 unless (-e $file);

    return $file;
}

sub AppExcluded {
    my ($app) = @_;

    my $excluded_names = 'LicISG|Dphys|license|ManagedClient|Munki|AdobeSharedApplications|kostenstelle|Xcode';

    if ( exists $app->{name} ) {
        return 1 if $app->{name} =~ m/$excluded_names/i;
    }
    if ( exists $app->{installer_item_location} ) {
        return 1 if $app->{installer_item_location} =~ m/Driver|Kostenstelle/;
    }
}

sub UpdateExcluded {
    my ($app, $upd_for) = @_;

    if ( exists $app->{name} ) {
        return 1 if $app->{name} =~ m/MSRemoteDesktop|ExcludedUpdate/i;
    }
}

sub UpdateShownInCatalog {
    my ($app) = @_;

    if ( exists $app->{name} ) {
        return 1 if $app->{name} =~ m/MSRemoteDesktop|BibDesk|Latexit|Texmaker|TeXShop/;
    }
}

sub LookForUpdateExcluded {
    my ($app_id) = @_;

    my $excluded_ids = 'iWork|iLife|RemoteDesktopAdmin|Xcode';

    return 1 if $app_id =~ m/$excluded_ids/i;
}

sub DefaultProductUrl {
    my ($app_name) = @_;

    (my $escaped_name = $app_name) =~ s/ /\%20/g;
    my $url = "http://www.google.com/search?q=Mac%20OS%20$escaped_name";

    return $url;
}

sub Error404 {
    my ($title) = @_;

    set serializer => '';       # make sure we return unserialized error

    Dancer::Continuation::Route::ErrorSent->new(
        return_value => Dancer::Error->new(
            code     => 404,
            title    => $title,
        )->render()
    )->throw;
}
