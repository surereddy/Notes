#!/usr/bin/perl 
#use strict; 
use Socket;
my $PF_INET=2; 
my $SOCK_DGRAM=2; 
my $port=40000; 
#my $ip=59.60.28.247; 
my $proto=getprotobyname('udp'); 
my $address=pack('SnC4x8',$PF_INET,$port,127,0,0,1);#change to the real ip
#my $address=sockaddr_in($port,inet_aton($ip));
my ($Cmd,$test); 
socket(SOCKET,$PF_INET,$SOCK_DGRAM,$proto) or die "Can't build a socket"; 
 bind (SOCKET,$address) or die "can't bind a SOCK"; 
 $reply="reply\r\n"; 
 while(1){ 
 my $rip=recv (SOCKET,$Cmd,2048,0); 
 print ">>>>>>>>>>>>>>>>>>>>>>>\r\n";
 print "$Cmd"."\r\n"; 
 send (SOCKET,$reply,0,$rip); 
 print "<<<<<<<<<<<<<<<<<<<<<<<<\r\n";
 print "$reply"."\r\n"; 
     } 
