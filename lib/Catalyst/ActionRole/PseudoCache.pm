package Catalyst::ActionRole::PseudoCache;

# ABSTRACT: Super simple caching for Catalyst actions

use Moose::Role;
use autodie;
use File::Spec;

has is_cached => (
   is      => 'rw',
   isa     => 'Bool',
   default => undef,
);

has path => (
   is      => 'ro',
   isa     => 'Str',
   builder => '_build_path',
   lazy    => 1,
);

has url => (
   is       => 'ro',
   isa      => 'Str',
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

 package MyApp::Controller::Root;

 use Moose;
 BEGIN { extends 'Catalyst::Controller::ActionRole' };

 sub all_js :Local :Does(PseudoCache) PCUrl(/static/js/all.js) {
    my ($self, $c) = @_;
    # Long running action to be cached
 }

=head1 DESCRIPTION

This module was originally made to take the output of
L<Catalyst::View::JavaScript::Minifier::XS> and store it in a file so that after
the server booted we would not need to generate it again and could let the
static web server serve up the static file.  Obviously it can be
used for much more than javascript, but it's mostly made with large, purely
javascript sites in mind.  It does not cache the output of the action when the
server is run in development mode.

=head1 ATTRIBUTES

=head2 PCUrl

Required.

After the action runs once it will redirect to C<$PCUrl>.

=head2 PCPath

When the action gets run the first time it will write it's output to C<$PCPath>.

Defaults to C<$c->path_to('root') . $PCUrl>

So using the example given above for the C<all_js> action, the path will be

 $MyAppLocation/root/static/js/all.js

