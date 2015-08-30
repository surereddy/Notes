#!/usr/bin/perl 
#testservers 
#servers.pl 
# 
use strict; 
my $face=qq~ 
########################################## 
#                                                              
#Perl_CMD                           
########################################## 
 ~; 
 print $face; 
 undef $face; 
 my $port=3032; 
 my $PF_INET=2; 
 my $SOCK_STREAM=1; 
 my $proto=getprotobyname("tcp"); 
 my $ADDR=pack ('SnC4x8',$PF_INET,$port,192,168,21,12); 
 my $command; 
 my $count=0;
 my $SERVERS;
 my $CLIENT;
 my $reply;
 $|=1; 
 socket ($SERVERS,$PF_INET,$SOCK_STREAM,$proto) or die "can't build a socket"; 
 bind ($SERVERS,$ADDR ) or die "can't bind a SOCK"; 
 listen($SERVERS,2); 
 for ( ;my $paddr=accept($CLIENT,$SERVERS) ;) { 
 $count++;
  recv ($CLIENT,$command,2048,0); 
  print ">>>>>>>>>>>>>>>>>>>>>>>\r\n";
  print $command."\r\n"; 
  if ($command and $command=~/^GET.*/i) {  
$reply=qq~
HTTP/1.1 200 OK
Pragma: No-cache
Cache-Control: no-cache,no-store,max-age=0
Expires: Thu, 01 Jan 1970 00:00:00 GMT
Content-Type: text/html;charset=GBK
Content-Length: 329
Date: Thu, 09 Oct 2008 06:37:55 GMT
Server: Apache-Coyote/1.1




<html>
<head>
<meta http-equiv="refresh" content="0;url=rtsp://218.80.215.213:554/media/service/000000192168021020-1.3gp?UserId=000000123456780002&&PUID-ChannelNo=000000192168021020-1&PlayMethod=0&StartTime=&PuProperty=1&VAUADD=218.80.215.198:2325&PUName=DVS2_???..????&hashtoken=10091437551402013458"/>
</head>
</html>
~;
   
   send ( $CLIENT ,$reply ,0);
   print "<<<<<<<<<<<<<<<<<<<<<<<<\r\n";
   print $reply."\r\n";
  }else{ 
   send ( $CLIENT ,"Error CMD format\n",0); 
   } 
   sleep(1);
 print "close client $count\n";
  close $CLIENT; 
 } #for
 print "close server....\n";

 close $SERVERS; 

