smg233@linux-viss2:~/smg212.17> cat watchdog_smg.pl 
#!/usr/bin/perl
use IO::Socket;

$checktime;
$command="smg";
$logfile="./watchdog.op";
$exe=$0;
$exe=~ s/.*\///;
$usage=
"
Usage:  $exe start                -- start watchdog and program
        $exe stop                 -- stop watchdog and program
";
$logrotatetime=60*60*24;
#$logrotatetime=6;
$logdir="history_log";
`mkdir -p $logdir`;


sub getserverport()
{
        $port = 9001;

        $config = "./config.xml";
        open CONFIG,"$config" or { return $port};
        while(<CONFIG>)
        {
               chomp($_);
                if (/.*ServerPort.*\>(.*)\</)
                {
                        $port = $1;
                       last;
                }
        }
        close CONFIG;
        return $port;
}

sub logmsg($)
{
      $msg = shift;
      `echo "$msg" | cat >> $logfile`;
}

sub stopsmg($)
{
        logmsg(shift);
        $deadcount++;
        if($deadcount gt 2)             
        {
              `pkill -9 -f ./$command`;
              $restarttime = `/bin/date`;
              chomp($restarttime);
              logmsg("[$restarttime] Warning1!!!smg is not alive,i will kill it!!!");
              $deadcount = 0;
        }
}


sub deadlockcheck($)
{
                my ($sock, $server_host, $msg, $port, $ipaddr, $hishost, 
                $max_len, $server_port, $timeout);

                $max_len  = 1024;

                #SMG server port refer to 'ServerPort' item of config.xml 
                $server_port  = shift; 
                #logmsg($server_port);
                $timeout = 5;

                #SMG server ip refer to 'LocalAddr' item of config.xml 
                $server_host = "127.0.0.1";
                $msg         = "\xfe\xfe\xfe\xfe\xfe\xfe\xfe\xfe";

                $sock = IO::Socket::INET->new(Proto     => 'udp',
                                              PeerPort  => $server_port,
                                              PeerAddr  => $server_host)
                or logmsg("creating socket: $!");

                $sock->send($msg) or 
                (
                        logmsg("send: $!") &&
                        return 1
                );

                eval
                {
                    local $SIG{ALRM} = sub { die "alarm time out" };
                    alarm $timeout;
                    $sock->recv($msg, $max_len) or
                    (
                        stopsmg("recv: $!") &&
                        return 1
                    );
                    $deadcount = 0;
                    #logmsg("smg server responded 'i am alive'");
                    alarm 0;
                    1;  # return value from eval on normalcy
                }
                or 
                (
                     stopsmg("recv from smg server timed out after $timeout seconds.") &&
                     return 1
                );

                #logmsg("smg server responded 'i am alive'");
}   



if ($ARGV[0] eq "stop")
{
        `pkill -9 -f /$command\$|pkill -9 -f $exe>/dev/null 2>&1`;
        exit;
}
if ($ARGV[0] eq "status")
{        
        $result1=`/usr/bin/pgrep $command\$|/usr/bin/wc -l`;
        if ($result1+0 gt 0)
        {
                        print "$exe                                               running \n";
                        exit 0;
        }else 
        { 
                        print "$exe                                               stopped \n";
                        exit 1;
        } 
         
        exit;    
}
elsif ($ARGV[0] eq "start")
{
        if ($ARGV[1]=~/d+/)
        {
                $checktime = $ARGV[1]+0;
        }
        else
        {
                $checktime = 10;
        }
}
else
{
        print $usage;
        exit;
}

$result=`pgrep -f $exe|wc -l`;
if ($result+0 gt 2)
{
        print "Watch dog is running now.\n";
        print $usage;
        exit;
}

$configlogfile=undef;
open FILE, "./config.xml" || die "open command file fail";
while(<FILE>)
{
        chomp($_);
        if (/.*LogFile.*\>(.*)\</)
        {
                $configlogfile = $1;
                last;
        }
}
close FILE;

print "Start stream media gateway...\n";
if (fork()!=0)
{
        exit;
}

if (fork() == 0) {
        while(1)
        {
                sleep($logrotatetime);                                            
                $time = `/bin/date +%y%m%d%H%M%S`;
                
                $filename = $configlogfile;
                $filename =~ s/(.*)\/(.*)$/$2/;;

                $newconfiglogfile = $filename.".".$time;                     
                $newlogfile = $logfile.".".$time;                                 
                `cat $logfile >./$logdir/$newlogfile`;                           
                `echo ""|cat > $logfile`;                                         
                if ($configlogfile == undef) {                                    
                        `cat $configlogfile > ./$logdir/$newconfiglogfile`;       
                        `echo ""|cat > $configlogfile`;                           
                }
        }
}

if(fork() == 0)
{
        $smg_port = getserverport();
        while(1)
        {
                sleep($checktime);
                deadlockcheck($smg_port);
        }
}

open LOG, ">>$logfile";

while(1)
{
#       $result = `pgrep $command`;
#       if ($result eq undef)
        {
                $date = `/bin/date`;
                chomp($date);

                print LOG "$date smg down, restart it\n";

                if (fork() == 0)
                {
                        `export PATH=.:$PATH`;
                        `./$command>>$logfile 2>&1`;
                        exit;
                }
                wait;
                sleep(1);
        }
#       sleep($checktime);
}




smg233@linux-viss2:~/smg212.17> ps -ef|grep smg
root      2500     1  0 Mar04 ?        00:00:00 /sbin/resmgrd
smg233   10049 10014  0 09:08 pts/0    00:00:00 su - smg233
smg233   10050 10049  0 09:08 pts/0    00:00:00 -bash
smg233   10311     1  0 09:27 pts/0    00:00:00 /usr/bin/perl ./watchdog_smg.pl start
smg233   10312 10311  0 09:27 pts/0    00:00:00 /usr/bin/perl ./watchdog_smg.pl start
smg233   10313 10311  0 09:27 pts/0    00:00:00 /usr/bin/perl ./watchdog_smg.pl start
smg233   10315 10311  0 09:27 pts/0    00:00:00 /usr/bin/perl ./watchdog_smg.pl start
smg233   10317 10315  0 09:27 pts/0    00:00:00 sh -c ./smg>>./watchdog.op 2>&1
smg233   10318 10317  0 09:27 pts/0    00:00:00 ./smg
smg233   10343 10050  0 09:29 pts/0    00:00:00 ps -ef
smg233   10344 10050  0 09:29 pts/0    00:00:00 grep smg