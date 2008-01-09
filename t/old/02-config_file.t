#!perl -T

use Test::More tests => 15;
use Config::Std; # Uses read_config to pull info from a config files. enhanced INI format.

my $config_file = 'test_config.cfg';


my %config_file_hash;
ok((read_config $config_file => %config_file_hash), "Load config file");

my @values = qw(server port conference username password test_forum1 test_forum2 );
foreach my $value (@values) {
    my $is_defined = defined $config_file_hash{main}{$value};
    ok($is_defined, "$value set in file");
    BAIL_OUT("$value set in file") if(!$is_defined);

    my $no_specials = scalar  $config_file_hash{main}{$value} !~ m/[^ -~]/;
    ok($no_specials, "No special characters in string");
    BAIL_OUT("$no_specials special charcters found in file.") if(!$no_specials);
}
