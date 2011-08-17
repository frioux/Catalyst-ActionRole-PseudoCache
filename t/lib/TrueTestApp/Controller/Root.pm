package TrueTestApp::Controller::Root;

use Moose;
BEGIN { extends 'Catalyst::Controller::ActionRole' };

__PACKAGE__->config->{namespace} = '';

sub test :Local :Does(PseudoCache) PCTrueCache(1) {
   my ( $self, $c ) = @_;

   $c->response->body('we cached your stuff');
}

sub test_key :Local :Does(PseudoCache) PCTrueCache(1) PCkey('neatkey') {
    my ( $self, $c ) = @_;

    $c->response->body('we cached your stuff with your neat key');
}

sub peek_cache :Local {
   my ( $self, $c ) = @_;

   my $cache = $c->cache->get('TestApp::Controller::Root/test3');

   $c->response->body($cache);
}

sub end : Private :ActionClass(RenderView) {}

1;
