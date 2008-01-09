#!perl

use Test::More tests => 8;
use Net::Jabber::Bot;

use FindBin;
use lib "$FindBin::Bin/lib";
use MockJabberClient; # Test object
#use Log::Log4perl qw(:easy);

my $alias = 'make_test_bot';
my $loop_sleep_time = 5;
my $server_info_timeout = 5;

my %forums_and_responses;
$forums_and_responses{$config_file_hash{'main'}{'test_forum1'}} = ["jbot:", ""];
$forums_and_responses{$config_file_hash{'main'}{'test_forum2'}} = ["notjbot:"];

my $client = new MockJabberClient; # Set this to the test object.
isa_ok($client, "MockJabberClient");

diag("Server parameters required when client object fed in?!");
my $bot = Net::Jabber::Bot->new({
                                 server => 'server_not_used'
                                 , conference_server => 'conference_server not used'
                                 , port => 'port_not_used'
                                 , username => 'username_not_used'
                                 , password => 'password_not_used'
				 , alias => $alias
				 , forums_and_responses => \%forums_and_responses
				 , jabber_client => $client
});
isa_ok($bot, "Net::Jabber::Bot");

my @privates = qw(CreateJabberNamespaces
                  InitJabber
                  Version
                  _SendIndividualMessage
                  _get_obj_id
		  callback_maker
		 );

foreach $private_module (@privates) {
    my $call = "\$bot->$private_module()";
    eval $call;
    ok($@ =~ m/Can\'t call private method /, "Verify private sub $call can not be executed outside class"); # Expect this subroutine to fail...
}
