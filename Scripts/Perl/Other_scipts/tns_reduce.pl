[root@mmicactive ~]# cat /usr/tns/reduce.sh
#!/bin/sh


PG_HOST_NAME=localhost
PG_DB_NAME=edib
PG_USER_NAME=postgres
PG_PASSWORD=password

STATS_ADMIN=stats
STATS_PASSWORD=314255


export PG_HOST_NAME PG_DB_NAME PG_USER_NAME PG_PASSWORD STATS_ADMIN STATS_PASSWORD

/usr/tns/reduce.pl
[root@mmicactive ~]# cat /usr/tns/reduce.pl
#!/usr/bin/perl
#
# $Id: reduce.pl,v 1.5 2004/06/07 18:12:22 aem Exp $
#
# Reduce data collected by the tp240dvr monitor
#
require "/usr/local/apache/cgi-bin/db_util.pl";
my $datafile = "/usr/eiab/data/trunkusage";
my $datafilecopy = "/usr/eiab/data/trunkusage.processing";
my $datafiletrimmed = "/usr/eiab/data/trunkusage.trimmed";
my $datafilereduced = "/usr/eiab/data/trunkusage.reduced";
my $lasttime=-1;
my $time=-1;
my $lastltime=-1;
my $ltime=-1;
my $starttime=-1;
my $endtime=-1;
my $trunk0=-1,$trunk0status=-1,$trunk0active=-1,$trunk0free=-1;
my $trunk1=-1,$trunk1status=-1,$trunk1active=-1,$trunk1free=-1;
my $trunk2=-1,$trunk2status=-1,$trunk2active=-1,$trunk2free=-1;
my $trunk3=-1,$trunk3status=-1,$trunk3active=-1,$trunk3free=-1;
my $voipstatus=-1,$voipactive=-1,$voipfree=-1;
my $lasttrunk0=-1,$lasttrunk0status=-1,$lasttrunk0active=-1,$lasttrunk0free=-1;
my $lasttrunk1=-1,$lasttrunk1status=-1,$lasttrunk1active=-1,$lasttrunk1free=-1;
my $lasttrunk2=-1,$lasttrunk2status=-1,$lasttrunk2active=-1,$lasttrunk2free=-1;
my $lasttrunk3=-1,$lasttrunk3status=-1,$lasttrunk3active=-1,$lasttrunk3free=-1;
my $lastvoipstatus=-1,$lastvoipactive=-1,$lastvoipfree=-1;
my $MAXTIME = 99999999999;
my $max0ports=0;
my $max1ports=0;
my $max2ports=0;
my $max3ports=0;
my $max4ports=0;
my $max5ports=0;
my $max6ports=0;
my $max7ports=0;
my $admin_name=$ENV{"STATS_ADMIN"};
my $admin_password=$ENV{"STATS_PASSWORD"};
my $star;
# `mv $datafile $datafilecopy`;
`cp $datafile $datafilecopy`;
open FILE,"<$datafilecopy" or die "Could not open $datafilecopy";
open REDUCEDFILE,">>$datafilereduced" or die "Could not open $datafilereduced";
sub my_die {}
sub getdata {
    $lasttime=$time;
    $lastltime=$ltime;
    $lastminutes=$minutes;
    $lastseconds=$lastseconds;
    $lasthours=$lasthours;

    $lasttrunk0=$trunk0;
    $lasttrunk0status=$trunk0status;
    $lasttrunkactive0=$trunk0active;
    $lasttrunk0free=$trunk0free;

    $lasttrunk1=$trunk1;
    $lasttrunk1status=$trunk1status;
    $lasttrunkactive1=$trunk1active;
    $lasttrunk1free=$trunk1free;

    $lasttrunk2=$trunk2;
    $lasttrunk2status=$trunk2status;
    $lasttrunkactive2=$trunk2active;
    $lasttrunk2free=$trunk2free;

    $lasttrunk3=$trunk3;
    $lasttrunk3status=$trunk3status;
    $lasttrunkactive3=$trunk3active;
    $lasttrunk3free=$trunk3free;

    $lastvoipstatus=$voipstatus;
    $lastvoipactive3=$voipactive;
    $lastvoipfree=$voipfree;

    while ( $line=<FILE> ) {
    chomp $line;
    last if (($line eq "###") and ($line = <FILE>));
}
    chomp $line;
    ($time,$ltime)=split('#', $line);
    if (eof(FILE)) {
        $time=$MAXTIME;$ltime=999912315959;
    }
    ($minutes,$seconds) = ($ltime =~ /\d{10}?(\d{2}?)(\d{2}?)/);
    $line=<FILE>;
    chomp $line;
    ($trunk0,$trunk0status,$trunk0active,$trunk0free) = split( '#', $line);
    $line=<FILE>;
    chomp $line;
    ($trunk1,$trunk1status,$trunk1active,$trunk1free) = split( '#', $line);
    $line=<FILE>;
    chomp $line;
    ($trunk2,$trunk2status,$trunk2active,$trunk2free) = split( '#', $line);
    $line=<FILE>;
    chomp $line;
    ($trunk3,$trunk3status,$trunk3active,$trunk3free) = split( '#', $line);
    $line=<FILE>;
    chomp $line;
    ($star, $voipstatus,$voipactive,$voipfree) = split( '#', $line);
}

sub trimdatafile() {
    close FILE;
    open FILE,"<$datafilecopy" or die "Could not open $datafilecopy";
    open TRIMFILE,">$datafiletrimmed" or die "Could not open $datafiletrimmed";
    getdata();
    while ($time < $starttime) {getdata();}
    while (true) {
        print TRIMFILE "###\n";
        print TRIMFILE join("#", $time, $ltime) . "\n";
        print TRIMFILE join("#", $trunk0, $trunk0status, $trunk0active, $trunk0free) . "\n";
        print TRIMFILE join("#", $trunk1, $trunk1status, $trunk1active, $trunk1free) . "\n";
        print TRIMFILE join("#", $trunk2, $trunk2status, $trunk2active, $trunk2free) . "\n";
        print TRIMFILE join("#", $trunk3, $trunk3status, $trunk3active, $trunk3free) . "\n";
        print TRIMFILE join("#", "*", $voipstatus, $voipactive, $voipfree) . "\n";
        getdata();
        if ($time == $MAXTIME) {
            close TRIMFILE;
            close REDUCEDFILE;
            `cp -f $datafiletrimmed $datafile`;
            exit 0;
        }
    }
}


sub fixdatafile() {
    close FILE;
    open FILE,"<$datafilecopy" or die "Could not open $datafilecopy";
    open TRIMFILE,">$datafiletrimmed" or die "Could not open $datafiletrimmed";
    $lastbadtime=$lasttime;
    $firstgoodtime=$time;
    $time=0;
    getdata();
    while ($time != $firstgoodtime) {getdata();}
    while (true) {
        print TRIMFILE "###\n";
        print TRIMFILE join("#", $time, $ltime) . "\n";
        print TRIMFILE join("#", $trunk0, $trunk0status, $trunk0active, $trunk0free) . "\n";
        print TRIMFILE join("#", $trunk1, $trunk1status, $trunk1active, $trunk1free) . "\n";
        print TRIMFILE join("#", $trunk2, $trunk2status, $trunk2active, $trunk2free) . "\n";
        print TRIMFILE join("#", $trunk3, $trunk3status, $trunk3active, $trunk3free) . "\n";
        print TRIMFILE join("#",  $voipstatus, $voipactive, $voipfree) . "\n";
        getdata();
        if ($time == $MAXTIME) {
            close TRIMFILE;
            close REDUCEDFILE;
            `cp -f $datafiletrimmed $datafile`;
            exit 0;
        }
    }
}

#
# First, find the appropriate 15 minute period
#



while ($starttime==-1) {
    getdata();
#    print "time=$time ltime=$ltime minutes=$minutes seconds=$seconds\n";
    $result=(($minutes + 1) % 15 );
#    print "mod = $result\n";
    if ((($minutes + 1) % 15 ) <= 2 ) {
#       print "$minutes is close enough to start time to use\n";
        $starttime=$time;
        $startltime=$ltime;
    }

}

while (true) {

    $endtime=$starttime+900;
    if (($minutes % 15) == 1) {
        $endtime -= 60;
    }
    if (($minutes % 15) == 2) {
        $endtime -= 120;
    }
    if (($minutes % 15) == 14) {
        $endtime += 60;
    }

    $trunk0statusSeconds=0;
    $trunk1statusSeconds=0;
    $trunk2statusSeconds=0;
    $trunk3statusSeconds=0;
    $voipstatusSeconds=0;

    $trunk0portSeconds=0;
    $trunk1portSeconds=0;
    $trunk2portSeconds=0;
    $trunk3portSeconds=0;
    $voipportSeconds=0;

    $max0ports=0;
    $max1ports=0;
    $max2ports=0;
    $max3ports=0;
    $max4ports=0;
    $max5ports=0;
    $max6ports=0;
    $max7ports=0;
    $maxvports=0;

#    print "endtime=$endtime starttime=$starttime $startltime\n";
    while($time <= $endtime) {
        getdata();
        if ($time == $MAXTIME) {
#           print "reached eof, won't use the data. Starttime=$starttime $startltime \n";
            trimdatafile();
            exit 0;
        }
        if ($time > $endtime) {last;}
        if ($time < $lasttime) {
            print "time goes backwards! We go from $lasttime to $time. Fixing things up\n";
            fixdatafile();
            exit 1;
        }
        $deltaseconds=$time-$lasttime;
#       print "time=$time; ltime=$ltime deltaseconds=$deltaseconds\n";

        $trunk0statusSeconds += $trunk0status * $deltaseconds;
        $trunk1statusSeconds += $trunk1status * $deltaseconds;
        $trunk2statusSeconds += $trunk2status * $deltaseconds;
        $trunk3statusSeconds += $trunk3status * $deltaseconds;
        $voipstatusSeconds += $voipstatus * $deltaseconds;

        $trunk0portSeconds += $trunk0active * $deltaseconds;
        $trunk1portSeconds += $trunk1active * $deltaseconds;
        $trunk2portSeconds += $trunk2active * $deltaseconds;
        $trunk3portSeconds += $trunk3active * $deltaseconds;
        $voipportSeconds += $voipactive * $deltaseconds;

        if ($trunk0active > $max0ports) {$max0ports = $trunk0active;}
        if ($trunk1active > $max1ports) {$max1ports = $trunk1active;}
        if ($trunk2active > $max2ports) {$max2ports = $trunk2active;}
        if ($trunk3active > $max3ports) {$max3ports = $trunk3active;}
        if ($voipactive > $maxvports) {$maxvports = $voipactive;}

    }

    $fulldeltaseconds = $lasttime - $starttime;
    if ($fulldeltaseconds == 0 ) {$fulldeltaseconds = 1;}
    $normalizefactor= 900/$fulldeltaseconds ;
    $t0sm=int($trunk0statusSeconds * $normalizefactor + .5);
    $t1sm=int($trunk1statusSeconds * $normalizefactor + .5);
    $t2sm=int($trunk2statusSeconds * $normalizefactor + .5);
    $t3sm=int($trunk3statusSeconds * $normalizefactor+ .5);
    $vsm=int($voipstatusSeconds * $normalizefactor+ .5);

    $t0pm=int($trunk0portSeconds * $normalizefactor + .5);
    $t1pm=int($trunk1portSeconds * $normalizefactor + .5);
    $t2pm=int($trunk2portSeconds * $normalizefactor + .5);
    $t3pm=int($trunk3portSeconds * $normalizefactor + .5);
    $vpm=int($voipportSeconds * $normalizefactor + .5);

#     print "fulldeltaseconds=$fulldeltaseconds normalizefactor=$normalizefactor t0ss=$trunk0statusSeconds\n";
#    print "uptime(trunk seconds): $t0sm $t1sm $t2sm $t3sm $vsm\n";
#    print "porttime(port seconds): $t0pm $t1pm $t2pm $t3pm $vpm\n";
#    print "max port usage:$max0ports $max1ports $max2ports $max3ports $maxvports\n";
    $db=open_db();
    $result=record_trunk_stats($db, $admin_name, $admin_password, 1, "pstn", $starttime, $t0sm, $t0pm, $max0ports);
#    print "result=$result\n";
    $result=record_trunk_stats($db, $admin_name, $admin_password, 2, "pstn", $starttime, $t1sm, $t1pm, $max1ports);
#    print "result=$result\n";
    $result=record_trunk_stats($db, $admin_name, $admin_password, 3, "pstn", $starttime, $t2sm, $t2pm, $max2ports);
#    print "result=$result\n";
    $result=record_trunk_stats($db, $admin_name, $admin_password, 4, "pstn", $starttime, $t3sm, $t3pm, $max3ports);
#    print "result=$result\n";
    $result=record_trunk_stats($db, $admin_name, $admin_password, 2, "voip", $starttime, $vsm, $vpm, $maxvports);
#    print "result=$result\n";
    print REDUCEDFILE "endtime=$endtime starttime=$starttime $startltime\n";
    print REDUCEDFILE "uptime(trunk seconds): $t0sm $t1sm $t2sm $t3sm $vsm\n";
    print REDUCEDFILE "porttime(port seconds): $t0pm $t1pm $t2pm $t3pm $vpm\n";
    print REDUCEFILE "max port usage:$max0ports $max1ports $max2ports $max3ports $maxvports\n";
    $starttime=$time;
    $startltime=$ltime;
}
[root@mmicactive ~]#
