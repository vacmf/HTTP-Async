use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'HTTP::Async',
    'VERSION_FROM' => 'lib/HTTP/Async.pm',
    'PREREQ_PM'    => {
        'Carp'                       => 0,
        'Data::Dumper'               => 0,
        'HTTP::Request'              => 0,
        'HTTP::Response'             => 0,
        'HTTP::Server::Simple::CGI'  => 0,
        'HTTP::Status'               => 0,
        'IO::Select'                 => 0,
        'LWP::UserAgent'             => 0,
        'Net::HTTP'                  => 0,
        'Net::HTTP::NB'              => 0,
        'Test::HTTP::Server::Simple' => 0,
        'Test::More'                 => 0,
        'Time::HiRes'                => 0,
        'URI'                        => 0,
        'URI::Escape'                => 0,
    },
);
