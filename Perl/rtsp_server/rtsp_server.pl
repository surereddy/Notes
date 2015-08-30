#!/usr/bin/perl
use Socket;

#test socket

$SIG{CHLD} ="IGNORE";
print "vap server start...\n";
$\="\r\n";

my %map;

	open(fp1,"./rtsp_config");
	#$/="\r\n";
	while($a=<fp1>)
	{
		#print 'line##::'.$a."\n";
		if($a=~/cmd=/)
		{
		 	$a=~s/cmd=//;
			chomp($cmd=$a);
			$value="";
			while($b=<fp1>)
			{
				$b=~s/{//;
				$b=~s/\s*(\w*)\s*/$1/;
				chomp($b);
				if($b=~/}/)
				{
					$b=~s/}//;
					$value.=$b."\r\n\r\n";
					last;
				}
				if($b=~/[A-Za-z]/)
				{
					$value.=$b."\r\n";
				}
			}
			$map{$cmd}=$value;
			print $cmd."=".$value."\n";
		 }
		 if($a=~/port=/)
		 {
		 	$a=~s/port=//;
		 	chomp($port=$a);
		 	print "port=".$port;
		 }
	}
	
socket(sockmain,PF_INET,SOCK_STREAM,0)||die "socket error:$!\n";
setsockopt(sockmain, SOL_SOCKET, SO_REUSEADDR, pack("l", 1)) ||die "setsockopt: $!";
bind(sockmain, sockaddr_in($port, INADDR_ANY)) ||die "bind: $!";
listen(sockmain,15)|| die "listen: $!";
$count=0;
while (accept($new_sock,sockmain) )
{
	$count++;
	$pid = fork();
	die "cann't fork " unless defined($pid);
	if ($pid == 0)
	{
		close ($main_sock);
		print ">>>>>>>>>>>>>>>>\n";
		while(1)
		{
		$recv_reslut=recv($new_sock,$buf,2048,0);
		if(!defined($recv_reslut)||length($buf)==0)
		{
			close ($new_sock);
			print "recv connection[$count] closed \n";
			exit(0); 
		}
		print "connection[$count]\n$buf";

		
		$len=index($buf," rtsp://",0);
		$new_cmd=substr($buf,0,$len);

		print $new_cmd;

		$msg=$map{$new_cmd};
		$send_reslut=send($new_sock,$msg,0);
		if(!defined($send_reslut))
		{
			close ($new_sock);
			print "send connection[$count] error \n";
			exit(0); 
		}
		print "<<<<<<<<<<<<<<<<<\n";
		print $msg."\n";
		}  
       }
       close ($new_sock);
       #print "close connection[$count] by main process \n";

}
print "close....\n";
close ($main_sock);


