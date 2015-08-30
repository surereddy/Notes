#!/usr/bin/perl
#----------------------------------
#Usage:
#    1. Modify my $port,server port.
#---------------------------------- 
#testservers 
#servers.pl 
# 
use strict; 
my $face=qq~ 
########################################## 
#                                                              
#Perl TCP Server
#      - Hello world                           
########################################## 
 ~; 
 print $face; 
 undef $face; 
 my $port=2345; # MODIFY
 my $PF_INET=2; 
 my $SOCK_STREAM=1; 
 my $proto=getprotobyname("tcp"); 
 my $ADDR=pack ('SnC4x8',$PF_INET,$port,0,0,0,0); 
 my $command; 
 my $count=0;
 my $SERVERS;
 my $CLIENT;
 $|=1; 
 socket ($SERVERS,$PF_INET,$SOCK_STREAM,$proto) or die "can't build a socket"; 
 bind ($SERVERS,$ADDR ) or die "can't bind a SOCK"; 
 listen($SERVERS,2); 
 for ( ;my $paddr=accept($CLIENT,$SERVERS) ;) { 
 $count++;
  recv ($CLIENT,$command,2048,0); 
  print $command."\r\n"; 
  #incoming message is hello leading.
  if ($command and $command=~/^hello.*/i) {  
   send ( $CLIENT ,"reply" ,0);
  }else{ 
   send ( $CLIENT ,"Error CMD format\n",0); 
   } 
 sleep(1);
 print "close client $count\n";
  close $CLIENT; 
 } #for
 print "close server....\n";

 close $SERVERS; 

