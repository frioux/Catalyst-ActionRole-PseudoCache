package TestApp::Controller::Root;

use Moose;
BEGIN { extends 'Catalyst::Controller::ActionRole' };

__PACKAGE__->config->{namespace} = '';

__PACKAGE__->config->{pseudo_cache_config} = {
   js => {
      url   => 'frew',
      path   => 'frew',
   }
};

sub js :Local :Does(PseudoCache) {
    my ( $self, $c ) = @_;

    $c->stash->{js} = { frew => 1 };
    $c->forward('View::JSON');
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub end : Private {
   my ( $self, $c ) = @_;
   $c->forward( 'TestApp::View::JSON' );
}

1;
