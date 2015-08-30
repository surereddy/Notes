#! /usr/bin/perl -w
#use strict;
use Socket;
$exe=$0;
if ($ARGV[0] eq "stop")
{
         Stop();
}
elsif ($ARGV[0] eq "start")
{
	start();
}
sub Stop{
	`pkill -9 -f $exe|killall $exe>/dev/null 2>&1`;
         exit;
}
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
	my $ip="127.0.0.1";
	my $port=9115;
	my $url="rtsp://172.24.202.190:554/asset/service?USERID=320101312345670001&ChanelNo-PUID=0-320101000200000001&PlayMethod=0";
	open(fp1,$ARGV[1]);
	while($a=<fp1>){
		 if($a=~/url=/)
		 {
		 	chop($a);
		 	chop($a);
		 	$a=~s/url=//;
		 	$a=~s/>\s*$//;
		 	$url=$a;
		 }
		 if($a=~/ip=/)
		 {
		 	$a=~s/ip=//;
		 	$ip=$a;
		 }
		 if($a=~/port=/)
		 {
		 	$a=~s/port=//;
		 	$port=$a;
		 }
		 if($a=~/^</ && $a=~/>\s*$/)
		 {
		 	$a=~s/<//;
		 	$a=~s/>//;
		 	@data=split(/,/,$a);
		 	push(@msg,[@data]);
		 }
	}
	close(fp1);
	my $address=sockaddr_in($port,inet_aton($ip));
	socket(sock1,PF_INET,SOCK_STREAM,0)||die "socket error:$!\n";
	connect(sock1,$address)||die "socket error:$!\n";
	#while(1)
	{
		foreach $tmp(@msg)
		{
			if($$tmp[0] eq "d")
      {
				$msg="DESCRIBE \@2 RTSP/1.0\r\nCseq: 12\r\n\r\n";
			}
			elsif($$tmp[0] eq "s")
			{
				$msg="SETUP \@2/\@3 RTSP/1.0\r\nCseq: 90\r\nTransport: RTP/AVP/UDP;unicast;client_port=7866\r\n\r\n";
			}
			elsif($$tmp[0] eq "5")
			{
				$msg="SETUP \@2 RTSP/1.0\r\nCseq: 90\r\nTransport: RTP/AVP/UDP;client_port=7832-7835;\r\nAuthorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==\r\n\r\n";
			}
			elsif($$tmp[0] eq "a")
			{
				$msg="SETUP \@2 RTSP/1.0\r\nCseq: 90\r\nTransport: RTP/AVP/UDP;unicast;client_port=7832\r\nx-playNow:\r\n\r\n";
			}
			elsif($$tmp[0] eq "p")
			{
				$msg="PLAY \@2 RTSP/1.0\r\nCseq: 91\r\nRange: npt=0-\r\nscale: 1\r\nsession: \@1\r\n\r\n";
			}
			elsif($$tmp[0] eq "h")
			{
				$msg="PLAY \@2 RTSP/1.0\r\nCseq: 91\r\nRange: npt=200-100\r\nsession: \@1\r\n\r\n";
			}
			elsif($$tmp[0] eq "u")
			{
				$msg="PAUSE \@2 RTSP/1.0\r\nCseq: 92\r\nsession: \@1\r\n\r\n";
			}
			elsif($$tmp[0] eq "t")
			{
				$msg="TEARDOWN \@2 RTSP/1.0\r\nCseq: 93\r\nsession: \@1\r\n\r\n";
			}
			elsif($$tmp[0] eq "k")
			{
				$msg="Yooooo \@2 RTSP/1.0\r\nVia: 192.33.44.\r\nCseq: 93\r\nsession: \@1\r\n\r\n";
			}
			elsif($$tmp[0] eq "o")
			{
				$msg="OPTIONS \@2 RTSP/1.0\r\nCseq: 98\r\n\r\n";
			}
			$msg=~s/\@1/$session/;
			$msg=~s/\@2/$url/;
      $msg=~s/\@3/$control/;
			
			send(sock1,$msg,0);
			print $msg;

			recv(sock1,$result,1024,0);
			$print=$result;
			$print=~s/(^\w)/>>>$1/;
			$print=~s/\r\n(\w)/\r\n>>>$1/g;
			print $print;
			
			#200ok to Describe may be separated in two packets
			if($$tmp[0] eq "d")
			{
			recv(sock1,$result,1024,0);
			$print=$result;
			$print=~s/(^\w)/>>>$1/;
			$print=~s/\r\n(\w)/\r\n>>>$1/g;
			print $print;
			}

      #get a=control value in such as 'a=control:trackID=1'
			if($msg=~/^DESCRIBE/)
			{
				@lines=split(/\r\n/,$result);
				foreach $line(@lines)
				{
					if($line=~/^a=control:/)
					{			
							$control=substr($line,10,9);
					}
				}
			}
      
      #get session value in such as 'Session: 0000000000027263;timeout=5l'
			if($msg=~/^SETUP/)
			{
				@lines=split(/\r\n/,$result);
				foreach $line(@lines)
				{
					if($line=~/^Session: /)
					{
						$len=index($result,"Session",0);
						$len2=index($result,";timeout",$len);
						if($len2>0)
						{
							$session=substr($line,9,$len2-$len-9);
						}
						else
						{
							$session=substr($line,9,length($line)-9);
						}
						last;
					}
				}
			}

			if($$tmp[1]>0) {sleep($$tmp[1]);}
		}
	}
	close(sock1);
}
