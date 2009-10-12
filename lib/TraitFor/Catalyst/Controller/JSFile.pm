package ACD::Controller::Root;

use Moose::Role;
use List::Util 'first';

has is_cached => (
   is => 'rw',
   isa => 'Bool',
   default => undef,
);

sub js_file : Local {
   my ($self, $c) = @_;
   if ($c->debug or !$self->is_cached) {
      # view should be configurable
      $c->forward("View::JavaScript");
      return if $c->debug;
      require File::Spec;
      # filename should be configurable
      my $filename = File::Spec->catfile($c->path_to('root'), 'static', 'js', 'all.js');
      unlink $filename if stat $filename;
      open my $js_fh, '>', $filename;
      print $js_fh $c->response->body;
      close $js_fh;
      $self->is_cached(1);
   }
   # this needs to be configurable too...
   $c->response->redirect('/static/js/all.js', 300);
}

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
