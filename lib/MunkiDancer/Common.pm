package MunkiDancer::Common;
use Dancer ':syntax';
use Exporter 'import';
our @EXPORT = qw(
    Catalog
    Manifest
    AppInfo
    Error404
);

sub RepoPath {
    my ($file) = @_;

    my $RepoPath = './repo';    # local symlink to repository
    $RepoPath = './t/testrepo' if ($file =~ /^test/ && $file ne 'testing');

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
