package TraitFor::Catalyst::ExpandableJSFiles;

use Moose::Role;
use Perl6::Gather;

sub js_files {
   my $self = shift;
   my @js_files = @{shift(@_)};

   my @filenames = gather {
      while (my ($dir, $paths) = splice(@js_files, 0, 2)) {
         take map "$dir$_.js", @$paths
      }
   };

   return \@filenames;
}

1;

=pod

=head1 SYNOPSIS

 __PACKAGE__->config(
    javascript => {
       files_expanded => [
          'MTSI/' => [ qw{
             Foo.fn
             ui.Grid
             }],
          'ACDRI/ACDRI.' => [ qw{
             fn
             overrides
             }],
       ],
    },
 );

 __PACKAGE__->config->{javascript}{files} =
    __PACKAGE__->js_files(__PACKAGE__->{javascript}{files_expanded});
 # Yields: [qw{MTSI/Foo.fn.js ui.Grid.js ACDRI/ACDRI.fn.js
 # ACDRI/ACDRI.overrides.js}

=head1 DESCRIPTION

This role is mostly just a small afordance to help with large lists of
javascript files.

=head1 METHODS

=head2 js_files

This method takes an arrayref of strings pointing to arrayrefs of strings.
See the synonsis for how that should look.

=end
