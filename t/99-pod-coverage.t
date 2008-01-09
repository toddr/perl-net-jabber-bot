#!perl -T

use Test::More tests => 1;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

my $private_subs = { private => [qr/^(CreateJabberNamespaces|InitJabber|SendJabberMessage|_SendIndividualMessage|_get_obj_id|_which_object_am_i|BUILD|Version|callback_maker)$/] };
pod_coverage_ok('Net::Jabber::Bot', $private_subs, "Test Net::Jabber::Bot for docs. Private functions not listed in docs");
