#!perl -T

use Test::More tests => 2;

my $config_file = 'test_config.cfg';

ok(unlink $config_file);
ok(!-e $config_file);