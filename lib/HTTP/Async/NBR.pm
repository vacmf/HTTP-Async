use strict;
use warnings;

package HTTP::Async::NBR;
use base 'Net::HTTP::NB';

=head1 NAME

HTTP::Async::NBC - non-blocking connect for HTTP::Async

=head1 SYNOPSIS

Internal, do not use.

=head1 DESCRIPTION

C<Net::HTTP::NB> subclass used internally by C<HTTP::Async> to provide
non-blocking connect/write.

=head1 METHODS

=head2 peerport

Returns the peer port from the request parameters, to avoid a warning
in C<http_configure> that expects the socket to be fully connected.

=cut

sub peerport {
    my $self = shift;

    return ${*$self}{peerport};
}

=head2 http_configure

Override to save the C<PeerPort> value.

=cut

sub http_configure {
    my $self = shift;
    my $cnf  = shift;

    # required to avoid a warning in Net::HTTP::Methods
    ${*$self}{peerport} = $cnf->{PeerPort} || $self->http_default_port;

    return $self->SUPER::http_configure( $cnf );
}

=head2 write_request

Override to save the request in a buffer, to be written in chunks when
the socket becomes writable.

=cut

sub write_request {
    my $self = shift;
    my $req_s = $self->format_request( @_ );

    ${*$self}{buffer} = $req_s;
    ${*$self}{remaining} = length( $req_s );
    ${*$self}{position} = 0;

    return 1;
}

=head2 handle_write

To be called when the socket becomes writable, returns 0 on error, 1
on success, 2 when the buffer has been completely written.

=cut

sub handle_write {
    my $self = shift;

    return 2 if !${*$self}{remaining};

    my $written = syswrite $self, ${*$self}{buffer},
                           ${*$self}{remaining} - ${*$self}{position},
                           ${*$self}{position};

    if ( ( $written || 0 ) > 0 ) {

        ${*$self}{offset} += $written;
        ${*$self}{remaining} -= $written;

        return ${*$self}{remaining} ? 1 : 2;
    } else {
        return 0;
    }
}

1;
