#!perl

use strict;
use warnings;
use autodie;

use FindBin;
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'TrueTestApp');
$mech->get_ok('/peek_cache', 'get works when uncached');
use Catalyst::Test 'TrueTestApp';
{
   my $empty_cache = get('/peek_cache');
   is ($empty_cache, '', 'cache is empty');
   get('/test');
   content_like('/peek_cache',qr{we cached your stuff},'something got cached');
   get('/test_key');
   content_like('/peek_cache',qr{we cached your stuff with your neat key},'something got cached with a custom key');
};
done_testing;
