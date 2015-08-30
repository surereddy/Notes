#! /usr/bin/perl -w
#----------------------------------
#Usage:
#    1. Modify my $ip,server IP.
#    2. Modify my $port,server port.
#----------------------------------
#use strict;
use Socket;
#$exe=$0;

	start();

sub start{
#test socket
	my $tmp;
	my $msg;
	my $print;
	my $result;
	my $ip="192.168.50.85"; #Modify 
	my $port=2345; #Modify
#	my $url="rtsp://172.24.202.190:554/asset/service?USERID=320101312345670001&ChanelNo-PUID=0-320101000200000001&PlayMethod=0";
	my $address=sockaddr_in($port,inet_aton($ip));
	socket(sock1,PF_INET,SOCK_STREAM,0)||die "socket error:$!\n";
	connect(sock1,$address)||die "socket error:$!\n";
	#while(1)
	{
		#foreach $tmp(@msg)
		{
		#There is one \0D\0A at the end of each line of $msg, so we don't add \r\n for them. 
		#\0d\0a is same as \r\n and is automaticallly added by UltraEdit. 	
		  $msg="hello world.\r\n";
      	
			send(sock1,$msg,0);
			print $msg;

			recv(sock1,$result,1024,0);
			$print=$result;
			$print=~s/(^\w)/>>>$1/;
			$print=~s/\r\n(\w)/\r\n>>>$1/g;
			print $print;
			
		}
	}
	close(sock1);
}
