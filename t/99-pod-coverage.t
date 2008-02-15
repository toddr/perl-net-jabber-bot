#!perl

use Test::More;

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

plan tests => 1;

my $private_subs = { private => [qr/^(BUILD|InitJabber|RequestVersion|callback_maker|_SendIndividualMessage|_get_obj_id)$/] };
pod_coverage_ok('Net::Jabber::Bot', $private_subs, "Test Net::Jabber::Bot for docs. Private functions not listed in docs");
