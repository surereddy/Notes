#viss@ViSS:~/VissApp/bin> cat watchdog.pl
#!/usr/bin/perl
use IO::Socket;

$EMS_ADDR="192.168.50.243:2006";
$CATALINA_HOME="/home/viss/WebServer/apache-tomcat-5.5.23";

$command="$CATALINA_HOME/bin/startup.sh";
$LOG_DIR="$CATALINA_HOME/logs";
$logfile="$LOG_DIR/watchdog.log";

$exe=$0;
$exe=~ s/.*\///;
$usage=
"
Usage:  $exe start [time]               -- start watchdog and program
";
if ($ARGV[0] eq "start") {
                if ($ARGV[1]=~/\d+/) {
                        $checktime = $ARGV[1]+0;
                } else {
                        $checktime = 60;
                }
}else {
    print $usage;
    exit;
}

`cd $CATALINA_HOME/bin`;

$result=`pgrep $exe|wc -l`;
if ($result+0 gt 1) {
    print "Watch dog is running now.\n";
    print $usage;
    exit;
}
#print "Start stream media gateway...\n";
if (fork()!=0) {
                exit;
}

$time = `date +%Y%m%d`;
$logfile="$LOG_DIR/watchdog-$time.log";
open LOGGER, ">$logfile";
while(1){
        $time = `date +%Y%m%d`;
        $logfile="$LOG_DIR/watchdog-$time.log";
        $result = IO::Socket::INET->new($EMS_ADDR);
        #print "$time \n";
        if ($result eq undef)   {
                $date = `date`;
                #print "$date: EMS down, restart it ...\n";
                print LOGGER "$date: EMS down, restart it ...\n";
                if (fork() == 0) {
                        `export PATH=.:$PATH`;
                        `$command`;
                        exit;
                }
        }
        sleep($checktime);
}

viss@ViSS:~/VissApp/bin>
