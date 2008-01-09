package MockJabberClient;

use strict;
use warnings;
use Class::Std;

# NOTE: Need to inherit from Jabber bot object so we don't have to re-do message code, etc.

my %message_queue : ATTR;
my %session_id : ATTR;
my %presence_callback : ATTR;
my %iq_callback : ATTR;
my %message_callback : ATTR;
my %is_connected : ATTR;

sub BUILD {
    my ($self, $obj_ID, $arg_ref) = @_;
    
    my @empty_array;
    $message_queue{$obj_ID} = \@empty_array;

    $session_id{$obj_ID} = int(rand(9999)); # Gen a random session ID.

    $presence_callback{$obj_ID} = $arg_ref->{'presence_callback'};
    $iq_callback{$obj_ID}       = $arg_ref->{'iq_callback'};
    $message_callback{$obj_ID}  = $arg_ref->{'message_callback'};

    $is_connected{$obj_ID}  = 1;
}

# Read from array of messages and pass them to the message functions.
sub Process {
    my $self = shift;
    my $obj_ID = $self->_get_obj_id() or return;
    my $timeout = shift or 0;

    return if(!$is_connected{$obj_ID}); # Return undef if we're not connected.

    foreach my $message (@{$message_queue{$obj_ID}}) {
        $timeout = 0; # zero out sleep timer;
        next if(!defined $message_callback{$obj_ID});
        $message_callback{$obj_ID}->($message, $session_id{$obj_ID});
    }

    sleep $timeout;
    return 1; # undef means we lost connection.
}

sub _get_obj_id : PRIVATE {
    my $self = shift;
    my $obj_ID = ident($self);

    return $obj_ID if(defined $obj_ID);

    my ($package, $filename, $line) = caller(1);
    my ($package_caller, $filename_caller, $line_caller) = caller(2);

    $line_caller = 'unknown' if(!defined $line_caller);
    $filename_caller = 'unknown' if(!defined $filename_caller);
    $package = 'unknown' if(!defined $package);

    ERROR("$package called at line $line_caller in $filename_caller without a valid object!!");
    return;
}
1;
