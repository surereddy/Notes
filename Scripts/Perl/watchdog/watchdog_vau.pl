vau233@linux-viss2:~/VissApp> cat ./watchdog_vau.pl 
#!/usr/bin/perl
$command="vau.exe";
$exe=$0;
$exe=~ s/.*\///;
$usage=
"
Usage:  $exe start                -- start watchdog and program
        $exe stop                 -- stop watchdog and program
";

if ($ARGV[0] eq "stop")
{
                 print "kill mi vau process. pls waiting .....\n";
                `pkill -2 -f $command >/dev/null 2>&1`;
                sleep(2);
                print "mi vau process has quit.\n";
                `pkill -9 -f $exe>/dev/null 2>&1`;
                `pkill -9 -f $exe>/dev/null 2>&1`;
                `pkill -9 -f $command >/dev/null 2>&1`;
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

if ($result+0 gt 3)
{
        print "Watch dog is running now.\n";
        print $usage;
        exit;
}


print "Start mi vau  process...\n";
if (fork()!=0)
{
        exit;
}
else
{
        while(1)
        {
                print LOG "mi vau process down, restart it\n";
                if (fork() == 0)
                {
                        `./$command`;
                        print "vau receive kill signal \n";
                        exit;
                }
                else
                {
                        wait;
                        sleep(3);
                }
        }
}