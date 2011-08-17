#!perl

use strict;
use warnings;
use autodie;

use FindBin;
use Test::More;
use Test::WWW::Mechanize::Catalyst;
use lib "$FindBin::Bin/../lib", "$FindBin::Bin/lib";

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'TrueTestApp');
$mech->get_ok('/peek_cache_test', 'get test works when uncached');
$mech->get_ok('/peek_cache_key', 'get test_key works when uncached');
use Catalyst::Test 'TrueTestApp';
{
   my $empty_cache_test = get('/peek_cache_test');
   is ($empty_cache_test, '', 'test cache is empty');
   my $empty_cache_key = get('/peek_cache_key');
   is ($empty_cache_key, '', 'test cache is empty');
   get('/test');
   content_like('/peek_cache_test',qr{we cached your stuff},'something got cached');
   get('/test_key');
   content_like('/peek_cache_key',qr{we cached your stuff with your neat key},'something got cached with a custom key');
};
done_testing;
