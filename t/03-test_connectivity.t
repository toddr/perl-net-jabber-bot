#!perl -T

use Test::More tests => 7;
use Test::NoWarnings;
use Net::Jabber::Bot;
use Log::Log4perl qw(:easy);

SKIP:{
    skip "Set 'AUTHOR' and have a valid t/test_Config.cfg file", 6 unless(defined $ENV{AUTHOR});

    
    # Load config file.
    use Config::Std; # Uses read_config to pull info from a config files. enhanced INI format.
    my $config_file = 't/test_config.cfg';
    my %config_file_hash;
    ok((read_config($config_file => %config_file_hash)), "Load config file");

    my $alias = 'make_test_bot';
    my $loop_sleep_time = 5;
    my $server_info_timeout = 5;

    my %forums_and_responses;
    $forums_and_responses{$config_file_hash{'main'}{'test_forum1'}} = ["jbot:", ""];
    $forums_and_responses{$config_file_hash{'main'}{'test_forum2'}} = ["notjbot:"];

    my $bot = Net::Jabber::Bot->new(
        server => $config_file_hash{'main'}{'server'}
        , conference_server => $config_file_hash{'main'}{'conference'}
        , port => $config_file_hash{'main'}{'port'}
        , username => $config_file_hash{'main'}{'username'}
        , password => $config_file_hash{'main'}{'password'}
        , alias => $alias
        , forums_and_responses => \%forums_and_responses
    );

    isa_ok($bot, "Net::Jabber::Bot");

    ok(defined $bot->Process(), "Bot connected to server");
    sleep 5;
    ok($bot->Disconnect() > 0, "Bot successfully disconnects"); # Disconnects
    is($bot->Disconnect(), undef,  "Bot fails to disconnect cause it already is"); # If already disconnected, we get a negative number
    
    eval{Net::Jabber::Bot->Disconnect()};
    like($@, qr/^\QCan't use string ("Net::Jabber::Bot") as a HASH ref while "strict refs" in use\E/, "Error when trying to disconnect not as an object");    
}
