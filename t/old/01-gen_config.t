#!perl -T

#use Test::More tests => 1; ok(1); exit;  # Uncomment me to prevent config file from being re-genned
use Test::More tests => 10;
use IO::Prompt;
$^W = 0; # Warnings on line 91 in IO::Prompt;

my $config_file = 'test_config.cfg';
unlink($config_file); # Can't test it cause it may not exist.

ok(!-e $config_file, 'config file is removed');

my $server     = prompt ("In order to complete tests, I must have server information:\n"
			 . "Please enter jabber server: ", '-tty');
my $port       = prompt ("Server Port: ", '-default' => "5222" , '-tty' );
my $conference  = "conference.$server";
$conference     = prompt ("Please enter jabber conference server: ", -default => $conference, -tty);
my $username   = prompt ("\nPlease enter the jabber username: ", -tty);
my $password   = prompt ("Password: ", -echo => ".", -tty );
my $test_forum1 = prompt ("Please enter a forum name I will test with you in: ", -tty );
my $test_forum2 = prompt ("Please enter a second forum name I will test with you in: ", -tty );

ok(defined $server && $server =~ m/\S\.\S/, '\$server supplied');
ok(defined $port && $port > 10, '\$port supplied');
ok(defined $conference && $conference =~ m/\S\.\S/, '\$conference supplied');
ok(defined $username && $username =~ m/\S/, '\$username supplied');
ok(defined $password && $password =~ m/\S/, '\$password supplied');
ok(defined $test_forum1 && $test_forum1 =~ m/\S/, '\$test_forum1 supplied');
ok(defined $test_forum2 && $test_forum2 =~ m/\S/, '\$test_forum2 supplied');

my $fh;
ok(open($fh, ">", $config_file), "Open $config_file");
print $fh <<"CONFIG_CONTENTS";
[main]
    server:$server
      port:$port
 conference:$conference
  username:$username
  password:$password
test_forum1:$test_forum1
test_forum2:$test_forum2

CONFIG_CONTENTS

ok(close $fh, "Close $config_file");

