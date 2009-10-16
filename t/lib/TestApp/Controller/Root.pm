package TestApp::Controller::Root;

use Moose;
BEGIN { extends 'Catalyst::Controller::ActionRole' };

__PACKAGE__->config->{namespace} = '';

sub test :Local :Does(PseudoCache) PCUrl(/foo.txt) {
    my ( $self, $c ) = @_;

    $c->response->body('big fat output');
}

sub end : Private :ActionClass(RenderView) {}

1;
