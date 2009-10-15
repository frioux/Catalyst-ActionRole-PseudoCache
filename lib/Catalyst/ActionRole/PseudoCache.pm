package Catalyst::ActionRole::PseudoCache;

use Moose::Role;
use autodie;
use File::Spec;

has is_cached => (
   is      => 'rw',
   isa     => 'Bool',
   default => undef,
);

has path => (
   is => 'ro',
   isa => 'Str',
   builder => '_build_path',
   lazy => 1,
);

has url => (
   is => 'ro',
   isa => 'Str',
   required => 1,
);

sub _build_path {
   my $self = shift;
   my $url = $self->url;
   return File::Spec->catfile(split qr{/}, $url);
}

around BUILDARGS => sub {
   my $orig  = shift;
   my $class = shift;
   my ($args) = @_;
   if (my $attr = $args->{attributes}) {
      return $class->$orig( url => $attr->{PCUrl}->[0], %{$args} );
   } else {
      return $class->$orig(@_);
   }
};

around execute => sub {
   my $orig               = shift;
   my $self               = shift;
   my ( $controller, $c ) = @_;

   return $self->$orig(@_)
      if ($c->debug);

   if (!$self->is_cached) {
      my $filename = File::Spec->catfile($c->path_to('root'), $self->path);
      warn $filename;

      unlink $filename if stat $filename;
      open my $js_fh, '>', $filename;

      $self->$orig(@_);

      warn $c->response->body;
      print {$js_fh} $c->response->body;
      close $js_fh;

      $self->is_cached(1);
   } else {
      $c->response->redirect($self->url, 300);
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
