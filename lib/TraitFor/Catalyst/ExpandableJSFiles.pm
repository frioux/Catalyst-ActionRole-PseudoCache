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
          'MTSI/MTSI.' => [ qw{
             fn
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

=head1 METHODS

=head2 js_files

=end
