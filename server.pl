#
# Server side script
#
use IO::Socket;
use Carp;

my $server_socket = IO::Socket::INET->new(
    LocalPort => 2525,
    Proto     => 'tcp',
    Listen    => 1,
    Reuse     => 1,
);

croak $! unless $server_socket;

while(1){
    my $client_socket = $server_socket->accept( );
	print "client accept\n";
    while(my $msg = <$client_socket>){
        last if $msg =~ /^QUIT$/i;
        $msg =~ s/\r|\n//g;

        print 'Client>> ', $msg, "\r\n"; 
        print $client_socket '>> ', $msg, "\r\n"; 
    }

	print "client close\n";
    $client_socket->close( );
}

print "server close\n";
$server_socket->close( );
