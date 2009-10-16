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
      my @args = (
         ($attr->{PCUrl}
            ? ( url => $attr->{PCUrl}->[0] )
            : ()
         ),
         ($attr->{PCPath}
            ? ( path => $attr->{PCPath}->[0] )
            : ()
         ),
         %{$args}
      );
      return $class->$orig( @args );
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

      unlink $filename if stat $filename;
      open my $js_fh, '>', $filename;

      $self->$orig(@_);

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

package TestApp::Controller::Root;

use Moose;
BEGIN { extends 'Catalyst::Controller::ActionRole' };

sub js :Local :Does(PseudoCache) PCUrl(/static/js/all.js) {
   my ($self, $c) = @_;
   $c->stash->{js} = [
      'ext3/adapter/ext/ext-base',
      $c->debug
         ? 'ext3/ext-all-debug'
         : 'ext3/ext-all',
      @{$c->config->{javascript}{files}}
   ];
}

sub some_other_action :Local :Does(PseudoCache) PCPath(foo/bar/baz) PCUrl(/static/js/all2.js) {
   my ($self, $c) = @_;
   $c->stash->{js} = [
      'ext3/adapter/ext/ext-base',
      $c->debug
         ? 'ext3/ext-all-debug'
         : 'ext3/ext-all',
      @{$c->config->{javascript}{files}}
   ];
}

=head1 DESCRIPTION

This module was originally made to take the output of
L<Catalyst::View::JavaScript::Minifier::XS> and store it in a file so that after
the server has booted once we won't need to generate it again and can let the
static web server serve up the static file much faster.  Obviously it can be
used for much more than javascript, but it's mostly made with large, purely
javascript sites in mind.

=head1 ATTRIBUTES

=head2 PCUrl

Required.

The url that the action will redirect to after it runs once.

=head2 PCPath

Not Required.

When the action gets run the first time it will write it's output to this path.

Defaults to C<$c->path_to('root') . $PCUrl> (roughty)

So using the example given above for the C<js> action, the path will be

 $MyAppLocation/root/static/js/all.js

=end
