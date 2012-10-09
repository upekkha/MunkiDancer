package MunkiDancer::Common;
use Dancer ':syntax';
use Exporter 'import';
our @EXPORT = qw(
    RepoPath
    Error404
);

sub RepoPath {
    my ($file) = @_;

    my $RepoPath = './repo';    # local symlink to repository
    $RepoPath = './t/testrepo' if ($file =~ /^test/ && $file ne 'testing');

    return $RepoPath;
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
