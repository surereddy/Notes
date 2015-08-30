#! /usr/bin/perl -w
#use strict;
use Socket;
#$exe=$0;

	start();

sub start{
#test socket	
	my@msg;
	my $tmp;
	my $control;
	my $msg;
	my $print;
	my $result;
	my $len;
	my $len2;
	my $session=0;
	my $ip="61.132.247.133";
	my $port=2030;
	my $url="rtsp://172.24.202.190:554/asset/service?USERID=320101312345670001&ChanelNo-PUID=0-320101000200000001&PlayMethod=0";
	my $address=sockaddr_in($port,inet_aton($ip));
	socket(sock1,PF_INET,SOCK_STREAM,0)||die "socket error:$!\n";
	connect(sock1,$address)||die "socket error:$!\n";
	#while(1)
	{
		#foreach $tmp(@msg)
		{
		#There is one \0D\0A at the end of each line of $msg, so we don't add \r\n for them. 
		#\0d\0a is same as \r\n and is automaticallly added by UltraEdit. 	
		  $msg="GET /smp/user/PrepareVauUrl.do?UserId=575EC9A7522A492AB0A9FD17EC857DDB&PUID-ChannelNo=100551123456789002-1&PlayMethod=0&StartTime=0&PuProperty=1&VAUADD=61.132.247.132:5060& HTTP/1.1\r\n".
		  "Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, application/x-silverlight, */*\r\n".
      "Referer: http://218.80.215.196:8080/msp/business/business!eppulist.action?useraccount=asb1&id=68\r\nAccept-Language: zh-cn\r\n".
      "UA-CPU: x86\r\nAccept-Encoding: gzip, deflate\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Maxthon)\r\n".
      "Host: 218.80.215.213:2030\r\n".
      "Connection: Keep-Alive\r\nCookie: JSESSIONID=82FF1820062FC959B67F03BA4F257F06\r\n\r\n";
      	
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
