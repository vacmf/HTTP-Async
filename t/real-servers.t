use strict;
use warnings;

use Test::More;

plan skip_all => "enable these tests by setting REAL_SERVERS"
  unless $ENV{REAL_SERVERS};

use HTTP::Request;
use Time::HiRes 'usleep';

# Create requests for a few well known sites.
my @requests =
  map { HTTP::Request->new( GET => "http://www.$_" ) }
  sort qw( google.com yahoo.com ecclestoad.co.uk );

my $tests_per_request = 4;
plan tests => 3 + $tests_per_request * scalar @requests;

use_ok 'HTTP::Async';

my $q = HTTP::Async->new;
isa_ok $q, 'HTTP::Async';

# Put all of these onto the queue.
ok( $q->add($_), "Added request for " . $_->uri ) for @requests;

# Process the queue until they all complete.
my @responses = ();

while ( $q->not_empty ) {

    my $res = $q->next_response;
    if ($res) {
        pass "Got the response from " . $res->request->uri;
        push @responses, $res;
    }
    else {
        usleep( 1_000_000 * 0.1 );    # 0.1 seconds
        next;
    }

    ok $res->is_success, "is success";
}

# Check that we got the number needed and that all the responses are
# HTTP::Response objects.
is scalar @responses, scalar @requests, "Got the expected number of responses";
isa_ok( $_, 'HTTP::Response', "Got a HTTP::Response object" ) for @responses;

# print $_->content for @responses;
