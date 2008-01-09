#!perl -T

use Test::More tests => 118;# ok(1); exit; #Disable tests
use Config::Std; # Uses read_config to pull info from a config files. enhanced INI format.
use Net::Jabber::Bot;

#InitLog4Perl();

# Load config file.
my $config_file = 'test_config.cfg';
my %config_file_hash;
ok((read_config $config_file => %config_file_hash), "Load config file");

my $bot_alias = 'make_test_bot';
my $client_alias = 'bot_test_client';
my $loop_sleep_time = 5;
my $server_info_timeout = 5;

my %forums_and_responses;
$forums_and_responses{$config_file_hash{'main'}{'test_forum1'}} = ["jbot:", ""];
$forums_and_responses{$config_file_hash{'main'}{'test_forum2'}} = ["notjbot:"];

my $ignore_server_messages = 1;
my $ignore_self_messages = 1;
my $out_messages_per_second = 5;
my $max_message_size = 800;
my $long_message_test_messages = 6;
my $flood_messages_to_send = 40;
my $max_messages_per_hour = ($flood_messages_to_send*2 
			     + 2
			     + $long_message_test_messages
			     );

# Globals we'll keep track of variables we use each test.
our $messages_seen = 0;
our $initial_message_count = 0;
our $start_time = time;

my $personal_address = "$config_file_hash{'main'}{'username'}\@$config_file_hash{'main'}{'server'}/$bot_alias";

ok(1, "Object is about to be created");
my $bot = Net::Jabber::Bot->new({
				 server => $config_file_hash{'main'}{'server'}
				 , conference_server => $config_file_hash{'main'}{'conference'}
				 , port => $config_file_hash{'main'}{'port'}
				 , username => $config_file_hash{'main'}{'username'}
				 , password => $config_file_hash{'main'}{'password'}
				 , alias => $bot_alias
				 , message_callback => \&new_bot_message   # Called if new messages arrive.
				 , background_activity => \&background_checks # What the bot does outside jabber.
				 , loop_sleep_time => $loop_sleep_time # Minimum time before doing background function.
				 , process_timeout => $server_info_timeout # Time to wait for new jabber messages before doing background stuff
				 , forums_and_responses => \%forums_and_responses
				 , ignore_server_messages => $ignore_server_messages
				 , ignore_self_messages => $ignore_self_messages
				 , out_messages_per_second => $out_messages_per_second
				 , max_message_size => $max_message_size
				 , max_messages_per_hour => $max_messages_per_hour
				});
diag("got return value $result") if(defined $result);

ok(defined $bot, "Bot initialized and connected");

ok(1, "Sleeping 22 seconds to make sure we get past initializtion");
ok((sleep 22) > 20, "Making sure the bot get's past initialization (sleep 22)");
process_bot_messages();

# Test Group Message bursting is not possible
{
    start_new_test(); # Reset all my counter variables.
    for my $counter (1..$flood_messages_to_send) {
	my $result = $bot->SendGroupMessage($config_file_hash{'main'}{'test_forum1'}, "Testing message speed $counter");
	diag("got return value $result") if(defined $result);
	ok(!defined $result, "Sent group message $counter");
    }

     my $running_time = time - $start_time;
     my $expected_run_time = $flood_messages_to_send / $out_messages_per_second;
     cmp_ok($running_time, '>=', int($expected_run_time), "group Message burst: \$running_time ($running_time) >= \$expected_run_time ($expected_run_time)");

     process_bot_messages();
     verify_messages_sent($flood_messages_to_send);
     verify_messages_seen(0, "Didn't see the messages I sent to the group");
}


# Test PERSONAL_ADDRESS Message bursting is not possible
 {
     start_new_test();
     for my $counter (1..$flood_messages_to_send) {
	 my $result =  $bot->SendPersonalMessage($personal_address, "Testing personal_address message speed $counter");
	 diag("got return value $result") if(defined $result);
	 ok(!defined $result, "Sent personal message $counter");
     }

     my $running_time = time - $start_time;
     my $expected_run_time = $flood_messages_to_send / $out_messages_per_second;
     cmp_ok($running_time, '>=', int($expected_run_time), "group Message burst: \$running_time ($running_time) >= \$expected_run_time ($expected_run_time)");

     process_bot_messages();
     verify_messages_sent($flood_messages_to_send);
     verify_messages_seen(0, "Didn't see the messages I sent to myself...");
}

TODO: { # Need a way to test for historical - up top or in diff code?
;#    cmp_ok($messages_seen, '==', 0, "Didn't see any historical messages...");
}

cmp_ok($bot->respond_to_self_messages( ), '==', 1, "no pass to respond_to_self_messages is 1");
cmp_ok($bot->respond_to_self_messages(0), '==', 0, "Ignore Self Messages");
cmp_ok($bot->respond_to_self_messages(2), '==', 2, "Respond to Self Messages");

# Test a successful message
start_new_test();
ok(!defined $bot->SendPersonalMessage($personal_address, "Testing message to myself"), "Testing message to myself");
process_bot_messages();
verify_messages_sent(1);
verify_messages_seen(1, "Got it!");

# Setup a really long message and make sure it's longer than 1 message.
my $repeating_string = 'Now is the time for all good men to come to the aide of their country ';
my $message_repeats = int( # Make it a whole number
			   ($max_message_size # Maximum size of 1 message
			    * $long_message_test_messages # How many messages we want to produce
			    - $max_message_size / 2) # Shorten it a little.
			   / length $repeating_string  # Length of our string we're going to repeat
			   );
my $long_message = $repeating_string x $message_repeats;
my $long_message_length = length $long_message;

cmp_ok(length($long_message), '>=' , $max_message_size , "Length of message is greater than 1 message chunk ($long_message_length bytes)");


# Test messages that will be split:
{
     start_new_test();
     cmp_ok($bot->respond_to_self_messages( ), '==', 1, "Make sure I'm responding to self messages.");

     # Group Test.
     ok(1, "Sending long message of " . length($long_message) . " bytes to forum");
     my $result = $bot->SendGroupMessage($config_file_hash{'main'}{'test_forum1'}, $long_message);
     diag("got return value $result\nWhile trying to send: $long_message") if(defined $result);
     ok(!defined $result, "Sent long message.");
     process_bot_messages();
     cmp_ok($messages_seen, '>=',$long_message_test_messages, "Saw $long_message_test_messages messages so we know it was chunked into messages smaller than $max_message_size");

     start_new_test();
     my $subject_change_result = $bot->SetForumSubject($config_file_hash{'main'}{'test_forum1'}, $long_message);
     is($subject_change_result, "Subject is too long!", 'Verify long subject changes are rejected.');
     verify_messages_sent(0);
     verify_messages_seen(0, "Bot should not have sent anything to the server.");
}

# Test a successful message with a panic
start_new_test();
ok(!defined $bot->SendPersonalMessage($personal_address, "Testing message to myself"), "Testing message to myself");
process_bot_messages();
verify_messages_sent(1);
verify_messages_seen(2, "With Panic");


# Test message limits
start_new_test();
my $failure_message = $bot->SendPersonalMessage($personal_address, "Testing message to myself that should fail");
ok(defined $failure_message, "Testing hourly message limits (failure to send)");
process_bot_messages();
verify_messages_seen(0, "Should be not have been sent to server");
verify_messages_seen(0, "Rejected by bot");

exit;

sub new_bot_message {
    our $messages_seen += 1;
}
sub background_checks {}

sub verify_messages_sent {
    my $expected_messages = shift;

    my $messages_sent = $bot->get_messages_this_hour() - $initial_message_count;
    cmp_ok($messages_sent, '==', $expected_messages, "Verify that $expected_messages were sent");
}

sub verify_messages_seen {
    my $expected_messages = shift;
    my $comment = shift;
    if(!defined $comment) {
	$comment = "";
    } else {
	$comment = "($comment)";
    }
    
    cmp_ok($messages_seen, '==', $expected_messages, "Verify that $expected_messages were seen $comment");
}

sub start_new_test {
    our $initial_message_count = $bot->get_messages_this_hour();
    our $messages_seen = 0;
    our $start_time = time;
}


sub process_bot_messages {
    sleep 2; # Pause a little to make sure message make it to the server and back.
    ok(defined $bot->Process(5), "Processed new messages and didn't lose connection.");
}

sub InitLog4Perl {

    $config_file .= <<'CONFIG_DATA';
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
