package TestApp;

use strict;
use warnings;

use Catalyst::Runtime 5.80;

use parent qw/Catalyst/;
use Catalyst qw/ Static::Simple Cache/;
use Cache::Bounded;


__PACKAGE__->config(
   name => 'TestApp',
   'Plugin::Cache' => {
      backend => {
         class => "Catalyst::Plugin::Cache::Backend::Memory",
      },
   },
);

__PACKAGE__->setup();

1;
