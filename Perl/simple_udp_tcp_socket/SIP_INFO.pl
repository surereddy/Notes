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
	my $ip='172.24.252.211';
	my $port=2325;
	my $url='rtsp://172.24.202.190:554/asset/service?USERID=320101312345670001&ChanelNo-PUID=0-320101000200000001&PlayMethod=0';

	my $address=sockaddr_in($port,inet_aton($ip));
	socket(sock1,AF_INET,SOCK_DGRAM,17)||die 'socket error:$!\n'; #17 UDP,0 IP/TCP
	connect(sock1,$address)||die 'socket error:$!\n';

		  $msg='INFO sip:mieye@172.24.252.211:2325 SIP/2.0'."\r\n".
           'Via: SIP/2.0/UDP 192.168.199.174:5062;branch=z9hG4bK3009d4f'."\r\n".
           'From: mieye <sip:mieyes@asb.com>;tag=03004cb0'."\r\n".
           'To: <sip:vau@192.168.21.10>'."\r\n".
           'Call-ID: 1188319282982@asb.com'."\r\n".
           'CSeq: 2540501 INFO'."\r\n".
           'User-Agent: Alcatel sbell/mieye2.0'."\r\n".
           'Max-Forwards: 70'."\r\n".
           'Content-Type: application/global_eye_v10+xml'."\r\n".
           'Content-Length:   309'."\r\n".
           ''."\r\n".
           '<?xml version=\'1.0\' encoding=\'GB2312\'?>'."\r\n".
           ' <Message Verison="1.0">'."\r\n".
           ' <Header Message_Type="MSG_PTZ_SET"'."\r\n".
           ' Sequence_Number="10000"'."\r\n".
           ' Session_ID="136817178941187992589664"'."\r\n".
           ' Destination_ID="1-000000192168021010"'."\r\n".
           ' User_ID="mieye1"'."\r\n".
           ' />'."\r\n".
           '<IE_PTZ nOpId="4"'."\r\n".
           '        nPara1="5"'."\r\n".
           '        nPara2="2"'."\r\n".
           '/>'."\r\n".
           '</Message>'."\r\n";
           		
			send(sock1,$msg,0);
			print $msg;

			recv(sock1,$result,1024,0);
			$print=$result;
			$print=~s/(^\w)/>>>$1/;
			$print=~s/\r\n(\w)/\r\n>>>$1/g;
			print $print;


	close(sock1);
}
