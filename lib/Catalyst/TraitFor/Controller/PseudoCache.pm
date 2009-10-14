package Catalyst::TraitFor::Controller::PseudoCache;

use Moose::Role;
use List::Util 'first';

use MooseX::Types::Structured qw{Dict};
use MooseX::Types -declare => [qw{PseudoCacheConfig PseudoCacheItem
      PseudoCacheState}];
use MooseX::Types::Moose qw(Bool HashRef Str);


subtype PseudoCacheItem,
    as Dict[
      url    => Str,
      path   => Str,
    ];

subtype PseudoCacheConfig,
   as HashRef[PseudoCacheItem];

subtype PseudoCacheState,
   as HashRef[Bool];

no MooseX::Types::Structured;
no MooseX::Types;
no MooseX::Types::Moose;

has is_cached => (
   is      => 'rw',
   isa     => PseudoCacheState,
   lazy    => 1,
   builder => '_is_cached_builder',
);

has pseudo_cache_config => (
   is => 'ro',
   isa => PseudoCacheConfig,
);

#sub js : Local {
   #my ($self, $c) = @_;
   #$c->stash->{js} = [
      #'ext3/adapter/ext/ext-base',
      #$c->debug
         #? 'ext3/ext-all-debug'
         #: 'ext3/ext-all',
      #@{$c->config->{javascript}{files}}
   #];
   #$c->forward("View::JavaScript");
#}

sub BUILD {
   my $self = shift;
   # reset iterator
   keys %{$self->pseudo_cache_config};
   while ( my ($action, $data) = each %{$self->pseudo_cache_config}) {
      $self->meta->add_around_method_modifier( $action, sub {
            my $orig = shift;
            my $self = shift;
            my $c    = shift;
            return $self->$orig($c, @_)
            if ($c->debug);
            if (!$self->is_cached) {
               return if $c->debug;
               require File::Spec;
               # filename should be configurable
               my $filename = File::Spec->catfile($c->path_to('root'), 'static', 'js', 'all.js');
               unlink $filename if stat $filename;
               open my $js_fh, '>', $filename;
               $self->$orig($c, @_);
               print {$js_fh} $c->response->body;
               close $js_fh;
               $self->is_cached(1);
            } else {
               # this needs to be configurable too...
               $c->response->redirect('/static/js/all.js', 300);
            }
         });
   }
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
