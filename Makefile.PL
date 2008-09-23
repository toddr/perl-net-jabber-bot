use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::Jabber::Bot',
    AUTHOR              => 'Todd E Rinaldo <perl-net-jabber-bot@googlegroups.com>',
    VERSION_FROM        => 'lib/Net/Jabber/Bot.pm',
    ABSTRACT_FROM       => 'lib/Net/Jabber/Bot.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Moose' => 0,  # Object Base
        'Moose::Util::TypeConstraints' => 0, # New variable types
        'Time::HiRes' => 0, # Partial second sleeping
        'Test::More' => 0,  # For testing
        'Test::NoWarnings' => 0,  # For testing
        'Net::Jabber' => 2.0,  # The whole thing is based on Net::Jabber. 
        'Log::Log4perl' => 0,  # We use log4perl. not sure how bad this'll screw people over... should consider removal later or make it optional
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-Jabber-Bot-*' },
);
