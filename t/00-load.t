#!perl -T

# Trap for these modules being avail or we can't do our tests...

use Test::More tests => 3;

BEGIN {
    use_ok( 'Net::Jabber::Bot' );
    use_ok( 'Config::Std' );
    use_ok( 'IO::Prompt' );
}

eval { require Net::Jabber::Bot };
BAIL_OUT("Net::Jabber::Bot not installed", 2) if $@;

eval { require Config::Std };
BAIL_OUT("Config::Std needed for tests!", 3) if $@;

eval { require IO::Prompt };
BAIL_OUT("IO::Prompt needed for tests!", 3) if $@;

diag( "Testing Net::Jabber::Bot $Net::Jabber::Bot::VERSION, Perl $], $^X" );
