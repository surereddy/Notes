#! /usr/bin/perl -w
#use strict;
use Socket;
#$exe=$0;
	start();

sub start{
#test socket	
	my @msg;
	my $tmp;
	my $control;
	my $msg;
	my $print;
	my $result;
	my $len;
	my $len2;
	my $session=0;
	my $ip='192.158.125.237';
	my $port=6000;
	my $url='rtsp://172.24.202.190:554/asset/service?USERID=320101312345670001&ChanelNo-PUID=0-320101000200000001&PlayMethod=0';

	my $address=sockaddr_in($port,inet_aton($ip));
	socket(sock1,AF_INET,SOCK_DGRAM,17)||die 'socket error:$!\n'; #17 UDP,0 IP/TCP
	connect(sock1,$address)||die 'socket error:$!\n';

		  $msg='Test Port 6000'."\r\n";
           		
			send(sock1,$msg,0);
			print $msg;

			recv(sock1,$result,1024,0);
			$print=$result;
			$print=~s/(^\w)/>>>$1/;
			$print=~s/\r\n(\w)/\r\n>>>$1/g;
			print $print;


	close(sock1);
}
