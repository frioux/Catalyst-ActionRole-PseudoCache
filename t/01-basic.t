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
};
done_testing;

