package SCGI;

use strict;
use warnings;

our $VERSION = 0.2;

use SCGI::Request;

=head1 NAME

SCGI

=head1 DESCRIPTION

This module is for implementing an SCGI interface for an application server.

=head1 SYNOPISIS

  use SCGI;
  use IO::Socket;
  
  my $socket = IO::Socket::INET->new(Listen => 5, ReuseAddr => 1, LocalPort => 8080)
    or die "cannot bind to port 8080: $!";
  
  my $scgi = SCGI->new($socket);
  
  while (my $request = $scgi->accept) {
    $request->read_env;
    read $request->connection, my $body, $request->env->{CONTENT_LENGTH};
    print $request->connection "HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\n\r\nHello!\n";
  }

=head2 public methods

=over

=item new

Takes a socket and returns a new SCGI listener.

=cut

sub new {
  my ($class, $socket, $blocking) = @_;
  bless {socket => $socket, blocking => $blocking ? 1 : 0}, $class;
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

Returns true if socket should block.

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
