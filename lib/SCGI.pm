package SCGI;

use strict;
use warnings;

our $VERSION = 0.4;

use SCGI::Request;

use Carp;

=head1 NAME

SCGI

=head1 DESCRIPTION

This module is for implementing an SCGI interface for an application server.

=head1 SYNOPISIS

  use SCGI;
  use IO::Socket;
  
  my $socket = IO::Socket::INET->new(Listen => 5, ReuseAddr => 1, LocalPort => 8080)
    or die "cannot bind to port 8080: $!";
  
  my $scgi = SCGI->new($socket, blocking => 1);
  
  while (my $request = $scgi->accept) {
    $request->read_env;
    read $request->connection, my $body, $request->env->{CONTENT_LENGTH};
    print $request->connection "HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\n\r\nHello!\n";
  }

=head2 public methods

=over

=item new

Takes a socket followed by a set of options (key value pairs) and returns a new SCGI listener. Currently the only supported option is blocking, to indicate that the socket blocks and that the library should not treat it accordingly. By default blocking is false. (NOTE: blocking is now a named rather than positional parameter. Using as a positional parameter will produce a warning in this version and will throw an exception in the next version).

=cut

sub new {
  my ($class, $socket) = (shift, shift);
  my %options;
  if (@_ == 1) { # this will go away in the next release
    warn "deprecated way of calling SCGI->new used. Parameters after socket are now named (use blocking => 1)";
    $options{blocking} = shift() ? 1 : 0;
  }
  elsif (@_ % 2) {
    croak "key without value passed to SCGI->new";
  }
  else {
    %options = @_;
  }
  for my $option (keys %options) {
    croak "unknown option $option" unless grep $_ eq $option, qw(blocking);
  }
  bless {socket => $socket, blocking => $options{blocking} ? 1 : 0}, $class;
}

=item accept

Accepts a connection from the socket and returns an C<L<SCGI::Request>> for it.

=cut

sub accept {
  my ($this) = @_;
  my $connection = $this->socket->accept or return;
  $connection->blocking(0) unless $this->blocking;
  SCGI::Request->_new($connection, $this->blocking);
}

=item socket

Returns the socket that was passed to the constructor.

=cut

sub socket {
  my ($this) = @_;
  $this->{socket};
}

=item blocking

Returns true if it was indicated that the socket should be blocking when the SCGI object was created.

=cut

sub blocking {
  my ($this) = @_;
  $this->{blocking};
}

1;

__END__

=back

=head1 AUTHOR

Thomas Yandell L<mailto:tom+scgi@vipercode.com>

=head1 COPYRIGHT

Copyright 2005 Viper Code Limited. All rights reserved.

=head1 LICENSE

This file is part of SCGI (perl SCGI library).

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
