package Catalyst::ActionRole::PseudoCache;

use Moose::Role;
use autodie;

has is_cached => (
   is      => 'rw',
   isa     => 'Bool',
   default => undef,
);

after BUILD => sub {
   my $class = shift;
   my ($args) = @_;

   my $attr = $args->{attributes};

   unless (exists $attr->{PCUrl} && $attr->{PCPath}) {
      Catalyst::Exception->throw(
	 "Action '$args->{reverse}' requires the PCUrl(<url>) attribute and PCPath(<path>) attribute");
}
};


around execute => sub {
   my $orig               = shift;
   my $self               = shift;
   my ( $controller, $c ) = @_;

   return $self->$orig(@_)
      if ($c->debug);

   if (!$self->is_cached) {
      require File::Spec;
      # filename should be configurable
      my $filename = File::Spec->catfile($c->path_to('root'), 'static', 'js', 'all.js');

      unlink $filename if stat $filename;
      open my $js_fh, '>', $filename;

      $self->$orig(@_);

      warn $c->response->body;
      print {$js_fh} $c->response->body;
      close $js_fh;

      $self->is_cached(1);
   } else {
      # this needs to be configurable too...
      $c->response->redirect('/static/js/all.js', 300);
   }
};


1;

=pod

=head1 SYNOPSIS

sub js :Local {
   my ($self, $c) = @_;
   $c->stash->{js} = [
      'ext3/adapter/ext/ext-base',
      $c->debug
         ? 'ext3/ext-all-debug'
         : 'ext3/ext-all',
      @{$c->config->{javascript}{files}}
   ];

   $c->forward( 'js_file' );
}

=end
