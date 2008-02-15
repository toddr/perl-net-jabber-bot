#!perl

use strict;
use warnings;

use Test::More tests => 7;
use Net::Jabber::Bot;

# stuff for mock client object
use FindBin;
use lib "$FindBin::Bin/lib";
use MockJabberClient; # Test object

#InitLog4Perl(); # Use to debug test cases. Off normally.

my $alias = 'make_test_bot';
my $loop_sleep_time = 5;
my $server_info_timeout = 5;

my %forums_and_responses;
my $forum1 = 'test_forum1';
my $forum2 = 'test_forum2';
$forums_and_responses{$forum1} = ["jbot:", ""];
$forums_and_responses{$forum2} = ["notjbot:"];

ok(1, "Creating Net::Jabber::Bot object with Mock client library asserted in place of Net::Jabber::Client");
my $bot = Net::Jabber::Bot->new({
                                 server => 'server_not_used'
                                 , conference_server => 'conference_server not used'
                                 , port => 'port_not_used'
                                 , username => 'username_not_used'
                                 , password => 'password_not_used'
                                 , alias => $alias
                                 , forums_and_responses => \%forums_and_responses
                                });
isa_ok($bot, "Net::Jabber::Bot");

my @privates = qw(InitJabber
                  RequestVersion
                  _SendIndividualMessage
                  _get_obj_id
                  callback_maker
                  );

foreach my $private_module (@privates) {
    my $call = "\$bot->$private_module()";
    eval $call;
    ok($@ =~ m/Can\'t call private method /, "Verify private sub $call can not be executed outside class"); # Expect this subroutine to fail...
}

sub InitLog4Perl {
    use Log::Log4perl qw(:easy);
    my $config_file .= <<'CONFIG_DATA';
# Regular Screen Appender
log4perl.appender.Screen           = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.stderr    = 0
log4perl.appender.Screen.layout    = PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = %d %p (%L): %m%n
log4perl.category = ALL, Screen
CONFIG_DATA

Log::Log4perl->init(\$config_file);
    $| = 1; #unbuffer stdout!


}