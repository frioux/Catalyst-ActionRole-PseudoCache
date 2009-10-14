#!perl

use strict;
use warnings;

use FindBin;
use JSON;
use Test::More;
use Test::Deep;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";
use Catalyst::Test 'TestApp';
{
   is get('/js'), '{"frew":1}';
   action_redirect('/js');
};
done_testing;

