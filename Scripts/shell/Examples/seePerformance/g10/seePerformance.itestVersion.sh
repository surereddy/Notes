#!/bin/bash
#!/usr/bin/perl -w

reset
clear
echo "####################################################################"
echo "# AVERAGE-PACKET-SIZE (BYTES)"
echo "####################################################################"

cat `ls -rt ./IICPortStats* | tail -1` | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile



# #Statistic: "aggregatePacketCount" (Packets-Per-Second) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$aggregatePacketCount=0;
$aggregateByteCount = 0;
$period = 0;
$time = 0;
$tmp =0;
foreach $field (@fields)
{
    if ($field eq "\"aggregatePacketCount\"")
    {
        $aggregatePacketCount = $tmp;
    }
    elsif ($field eq "\"aggregateByteCount\"")
    {
        $aggregateByteCount = $tmp;
    }

    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentAggregatePacket = 0;
my $currentAggregateByte = 0;
my $totalPackets;
my $totalBytes;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        my $rate = $currentAggregateByte / $currentAggregatePacket;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
	$totalBytes += $currentAggregateByte;
        $totalPackets += $currentAggregatePacket;
        $currentAggregatePacket = 0;
	$currentAggregateByte = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentAggregatePacket += $fields[$aggregatePacketCount];
    $currentAggregateByte   += $fields[$aggregateByteCount];
}
my $rate =  $currentAggregatePacket / $currentAggregatePacket;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalPackets += $currentAggregatePacket;
$totalBytes += $currentAggregateByte;
printf "AVERAGE-PACKET-SIZE-Avg:%.0f\n", ($totalBytes/$totalPackets);
'   



rm -rf ./myFile
echo "####################################################################"
echo "# PACKETS-PER-SECOND-IIC"
echo "####################################################################"

cat `ls -rt ./IICPortStats* | tail -1` | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


## Statistic: "aggregatePacketCount" (Packets-Per-Second) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$aggregatePacketCount = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"aggregatePacketCount\"")
    {
        $aggregatePacketCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentAggregatePacket = 0;
my $totalPackets;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        #print "$currentTime,$currentPeriod,$currentAggregatePacket\n";
        my $rate = 1000* $currentAggregatePacket / $currentPeriod;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalPackets += $currentAggregatePacket;
        $currentAggregatePacket = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentAggregatePacket += $fields[$aggregatePacketCount];
}
#print "$currentTime,$currentPeriod,$currentAggregatePacket\n";
my $rate = 1000* $currentAggregatePacket / $currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalPackets += $currentAggregatePacket;

printf "PACKETS-PER-SECOND-IIC-Avg:%.0f\n", (1000*$totalPackets/$totalPeriod);


if (defined $minRate)
{


    printf "PACKETS-PER-SECOND-IIC-Min:%.0f\n", $minRate;
    printf "PACKETS-PER-SECOND-IIC-Max:%.0f\n", $maxRate;
}
'

totalPkts=0
##########################################################################
## Statistic: "aggregatePacketCount" (totalPackets) AVG
##########################################################################
totalPkts=`cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$aggregatePacketCount = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"aggregatePacketCount\"")
    {
        $aggregatePacketCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentAggregatePacket = 0;
my $totalPackets;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        #print "$currentTime,$currentPeriod,$currentAggregatePacket\n";
        my $rate = 1000* $currentAggregatePacket / $currentPeriod;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalPackets += $currentAggregatePacket;
        $currentAggregatePacket = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentAggregatePacket += $fields[$aggregatePacketCount];
}
#print "$currentTime,$currentPeriod,$currentAggregatePacket\n";
my $rate = 1000* $currentAggregatePacket / $currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalPackets += $currentAggregatePacket;
#printf "TOTAL-NUMBER-OF-PACKETS-Avg:%.0f\n", $totalPackets;
printf "PACKETS-PER-SECOND-IIC-Avg:%.0f\n", (1000*$totalPackets/$totalPeriod);
'` 
echo "#################################################################################################"
echo "# TOTAL NUMBER OF PACKETS:"
echo "#################################################################################################"
echo $totalPkts



rm -rf ~/myFile
echo "#################################################################################################"
echo "# DPI Statistics:"
echo "#################################################################################################"
cat `ls -rt ./DpiStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$dpiOutOfMemoryCount = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"dpiOutOfMemoryCount\"")
    {
        $dpiOutOfMemoryCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaldpiOutOfMemoryCount;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentdpiOutOfMemoryCount/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaldpiOutOfMemoryCount += $currentdpiOutOfMemoryCount;
        $currentdpiOutOfMemoryCount = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentdpiOutOfMemoryCount += $fields[$dpiOutOfMemoryCount];
}
my $drops = $currentdpiOutOfMemoryCount/$currentPeriod;

$totaldpiOutOfMemoryCount += $currentdpiOutOfMemoryCount;


printf "Total (DPI STATS- Out of Memory Count):%.0f\n", ($totaldpiOutOfMemoryCount);
'


rm -rf ./myFile


echo "####################################################################"
echo "# PACKETS-PER-SECOND-DPI (DPI)"
echo "####################################################################"

cat `ls -rt ./DpiStats* | tail -1` | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


## Statistic: "dpiRecvPacketCount" (Packets-Per-Second) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$dpiRecvPacketCount= 0;
$period = 0;
$time = 0;
$tmp =0;
foreach $field (@fields)
{
    if ($field eq "\"dpiRecvPacketCount\"")
    {
        $dpiRecvPacketCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentDpiRecvPacketCount = 0;
my $totalPackets;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        #print "$currentTime,$currentPeriod,$currentDpiRecvPacketCount\n";
        my $rate = 1000* $currentDpiRecvPacketCount / $currentPeriod;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalPackets += $currentDpiRecvPacketCount;
        $currentDpiRecvPacketCount = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentDpiRecvPacketCount += $fields[$dpiRecvPacketCount];
}
#print "$currentTime,$currentPeriod,$currentDpiRecvPacketCount\n";
my $rate = 1000* $currentDpiRecvPacketCount / $currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalPackets += $currentDpiRecvPacketCount;


printf "PACKETS-PER-SECOND-DPI-Avg:%.0f\n", (1000*$totalPackets/$totalPeriod);

if (defined $minRate)
{


    printf "PACKETS-PER-SECOND-DPI-Min:%.0f\n", $minRate;
    printf "PACKETS-PER-SECOND-DPI-Max:%.0f\n", $maxRate;
}
'



rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# DPI-PROCESSOR-CPU-UTILIZATION (%)"
echo "####################################################################"


cat `ls -rt ./AppUsage* | tail -1` | egrep 'DpiProcessor|cpuTime' | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "cpuTime" (CPU Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
my $cpuTime;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"cpuTime\"")
    {
        $cpuTime = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($cpuTime) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentCpu;
my %totalCpu;
my $totalPeriod;
my %minRate;
my %maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentCpu))
        {
            my $rate = $currentCpu{$key}/$currentPeriod;

            if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
            {
                $minRate{$key} = $rate;
            }
            if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
            {
                $maxRate{$key} = $rate;
            }
            $totalCpu{$key} += $currentCpu{$key};
            $currentCpu{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentCpu{$fields[$blade]} += $fields[$cpuTime]*$currentPeriod;
}

foreach $key (keys(%currentCpu))
{
    my $rate = $currentCpu{$key}/$currentPeriod;

    if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
    {
        $minRate{$key} = $rate;
    }
    if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
    {
        $maxRate{$key} = $rate;
    }
    $totalCpu{$key} += $currentCpu{$key};
    $currentCpu{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentCpu))
{

    printf "$key DPI-PROCESSOR-CPU-UTILIZATION-Avg:%.3f\n", ($totalCpu{$key}/$totalPeriod*100);

    if (exists $minRate{$key})
    {
        printf "$key DPI-PROCESSOR-CPU-UTILIZATION-Min:%.3f\n", ($minRate{$key})*100;
        printf "$key DPI-PROCESSOR-CPU-UTILIZATION-Max:%.3f\n", ($maxRate{$key})*100;
    }
}
'








rm -rf ./myFile
echo "####################################################################"
echo "# BITS-PER-SECOND-IIC (IIC)"
echo "####################################################################"

cat `ls -rt ./IICPortStats* | tail -1` | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

## Statistic: "Bits Per Second" AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$aggregateByteCount = 0;
$period = 0;
$time = 0;
$tmp =0;
foreach $field (@fields)
{
    if ($field eq "\"aggregateByteCount\"")
    {
        $aggregateByteCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentAggregateByte = 0;
my $totalPackets;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        my $rate = (1000*8* ($currentAggregateByte / $currentPeriod));

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalPackets += $currentAggregateByte;
        $currentAggregateByte = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentAggregateByte += $fields[$aggregateByteCount];
}
my $rate = 1000*8* $currentAggregateByte / $currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalPackets += $currentAggregateByte;


printf "BITS-PER-SECOND-IIC-Avg:%.0f\n", (1000*8*$totalPackets/$totalPeriod);

if (defined $minRate)
{


    printf "BITS-PER-SECOND-IIC-Min:%.0f\n", $minRate;
    printf "BITS-PER-SECOND-IIC-Max:%.0f\n", $maxRate;
}
'


rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# PER-BLADE-PACKETS-PER-SECOND-CRX (CRX)"
echo "####################################################################"


cat `ls -rt ./CrxStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "controlPlanePdusPerSecond" (Packet-Per-Second) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
my $pdusPerSecond;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"controlPlanePdusPerSecond\"")
    {
        $pdusPerSecond = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($pdusPerSecond) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentPdus;
my %totalPackets;
my $totalPeriod;
my %minRate;
my %maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentPdus))
        {
            my $rate = $currentPdus{$key}/$currentPeriod;

            if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
            {
                $minRate{$key} = $rate;
            }
            if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
            {
                $maxRate{$key} = $rate;
            }
            $totalPackets{$key} += $currentPdus{$key};
            $currentPdus{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus{$fields[$blade]} += $fields[$pdusPerSecond]*$currentPeriod;
}

foreach $key (keys(%currentPdus))
{
    my $rate = $currentPdus{$key}/$currentPeriod;

    if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
    {
        $minRate{$key} = $rate;
    }
    if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
    {
        $maxRate{$key} = $rate;
    }
    $totalPackets{$key} += $currentPdus{$key};
    $currentPdus{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentPdus))
{

    printf "$key PER-BLADE-PACKETS-PER-SECOND-CRX-Avg:%.0f\n", ($totalPackets{$key}/$totalPeriod);

    if (exists $minRate{$key})
    {
        printf "$key PER-BLADE-PACKETS-PER-SECOND-CRX-Min:%.0f\n", $minRate{$key};
        printf "$key PER-BLADE-PACKETS-PER-SECOND-CRX-Max:%.0f\n", $maxRate{$key};
    }
}
'







rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-PACKETS-PER-SECOND-CRX (CRX)"
echo "####################################################################"


cat `ls -rt ./CrxStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "controlPlanePdusPerSecond" (Packets-Per-Second) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$pdusPerSecond = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"controlPlanePdusPerSecond\"")
    {
        $pdusPerSecond = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalPackets;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalPackets += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$pdusPerSecond]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalPackets += $currentPdus;


printf "TOTAL-PACKETS-PER-SECOND-CRX-Avg:%.0f\n", ($totalPackets/$totalPeriod);

if (defined $minRate)
{


    printf "TOTAL-PACKETS-PER-SECOND-CRX-Min:%.0f\n", $minRate;
    printf "TOTAL-PACKETS-PER-SECOND-CRX-Max:%.0f\n", $maxRate;
}
'



rm -rf ./myFile
##############################################################################################################
#controlPlaneBandwidth
echo "####################################################################"
echo "# PER-BLADE CONTROL-PLANE BANDWIDTH - INCLUDING DNS (Kbps)"
echo "# NOTE: Ignore these stats on Stacked Probes."
echo "####################################################################"


cat `ls -rt ./CrxStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "controlPlaneBandwidth" (Mbps) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
my $controlPlaneBandwidth;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"controlPlaneBandwidth\"")
    {
        $controlPlaneBandwidth = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($controlPlaneBandwidth) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentPdus;
my %totalPackets;
my $totalPeriod;
my %minRate;
my %maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentBW))
        {
            my $rate = $currentBW{$key}/$currentPeriod;

            if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
            {
                $minRate{$key} = $rate;
            }
            if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
            {
                $maxRate{$key} = $rate;
            }
            $totalPackets{$key} += $currentBW{$key};
            $currentBW{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentBW{$fields[$blade]} += $fields[$controlPlaneBandwidth]*$currentPeriod;
}

foreach $key (keys(%currentBW))
{
    my $rate = $currentBW{$key}/$currentPeriod;

    if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
    {
        $minRate{$key} = $rate;
    }
    if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
    {
        $maxRate{$key} = $rate;
    }
    $totalPackets{$key} += $currentBW{$key};
    $currentBW{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentBW))
{

    printf "$key PER-BLADE-CONTROL-PLANE-BANDWIDTH-INCLUDING-DNS-Avg:%.0f\n", ($totalPackets{$key}/$totalPeriod);

    if (exists $minRate{$key})
    {
        printf "$key PER-BLADE-CONTROL-PLANE-BANDWIDTH-INCLUDING-DNS-Avg-Min:%.0f\n", $minRate{$key};
        printf "$key PER-BLADE-CONTROL-PLANE-BANDWIDTH-INCLUDING-DNS-Avg-Max:%.0f\n", $maxRate{$key};
    }
}
'







rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-CONTROL-PLANE-BANDWIDTH-INCLUDING-DNS (Kbps)"
echo "# NOTE: Ignore these stats on Stacked Probes."
echo "####################################################################"


cat `ls -rt ./CrxStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "controlPlaneBandwidth" (Packets-Per-Second) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$controlPlaneBandwidth = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"controlPlaneBandwidth\"")
    {
        $controlPlaneBandwidth = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentBW = 0;
my $totalPackets;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentBW/$currentPeriod;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalPackets += $currentBW;
        $currentBW = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentBW += $fields[$controlPlaneBandwidth]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentBW\n";
my $rate = $currentBW/$currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalPackets += $currentBW;


printf "TOTAL-CONTROL-PLANE-BANDWIDTH-INCLUDING-DNS-Avg:%.0f\n", ($totalPackets/$totalPeriod);

if (defined $minRate)
{


    printf "TOTAL-CONTROL-PLANE-BANDWIDTH-INCLUDING-DNS-Min:%.0f\n", $minRate;
    printf "TOTAL-CONTROL-PLANE-BANDWIDTH-INCLUDING-DNS-Max:%.0f\n", $maxRate;
}
'



rm -rf ./myFile
##############################################################################################################
#controlPlaneBandwidth
echo "####################################################################"
echo "# PER-BLADE CONTROL-PLANE-BANDWIDTH-EXCLUDING-DNS (Kbps)"
echo "# NOTE: Includes OverHead Headers From IIC"
echo "# NOTE: Ignore these stats on Stacked Probes."
echo "####################################################################"


cat `ls -rt ./CrxStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "pdyBandwidth" (Kbps) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
my $pduBandwidth;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"pduBandwidth\"")
    {
        $pduBandwidth = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($pduBandwidth) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentPdus;
my %totalPackets;
my $totalPeriod;
my %minRate;
my %maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentBW))
        {
            my $rate = $currentBW{$key}/$currentPeriod;

            if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
            {
                $minRate{$key} = $rate;
            }
            if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
            {
                $maxRate{$key} = $rate;
            }
            $totalPackets{$key} += $currentBW{$key};
            $currentBW{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentBW{$fields[$blade]} += $fields[$pduBandwidth]*$currentPeriod;
}

foreach $key (keys(%currentBW))
{
    my $rate = $currentBW{$key}/$currentPeriod;

    if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
    {
        $minRate{$key} = $rate;
    }
    if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
    {
        $maxRate{$key} = $rate;
    }
    $totalPackets{$key} += $currentBW{$key};
    $currentBW{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentBW))
{

    printf "$key PER-BLADE CONTROL-PLANE-BANDWIDTH-EXCLUDING-DNS-Avg:%.0f\n", ($totalPackets{$key}/$totalPeriod);

    if (exists $minRate{$key})
    {
        printf "$key PER-BLADE CONTROL-PLANE-BANDWIDTH-EXCLUDING-DNS-Min:%.0f\n", $minRate{$key};
        printf "$key PER-BLADE CONTROL-PLANE-BANDWIDTH-EXCLUDING-DNS-Max:%.0f\n", $maxRate{$key};
    }
}
'







rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-CONTROL-PLANE-BANDWIDTH-EXCLUDING-DNS (Kbps)"
echo "# NOTE: Includes OverHead Headers From IIC"
echo "# NOTE: Ignore these stats on Stacked Probes."
echo "####################################################################"


cat `ls -rt ./CrxStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "pduBandwidth" (Packets-Per-Second) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$pduBandwidth = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"pduBandwidth\"")
    {
        $pduBandwidth = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentBW = 0;
my $totalPackets;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentBW/$currentPeriod;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalPackets += $currentBW;
        $currentBW = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentBW += $fields[$pduBandwidth]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentBW\n";
my $rate = $currentBW/$currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalPackets += $currentBW;


printf "TOTAL-CONTROL-PLANE-BANDWIDTH-EXCLUDING-DNS-Avg:%.0f\n", ($totalPackets/$totalPeriod);

if (defined $minRate)
{


    printf "TOTAL-CONTROL-PLANE-BANDWIDTH-EXCLUDING-DNS-Min:%.0f\n", $minRate;
    printf "TOTAL-CONTROL-PLANE-BANDWIDTH-EXCLUDING-DNS-Max:%.0f\n", $maxRate;
}
'




rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# Per-Blade-Total-Open-Sessions"
echo "####################################################################"


cat `ls -rt ./SessionTrackingStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "totalOpenSessions" (Total Open Sessions) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
my $openSessions;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"totalOpenSessions\"")
    {
        $openSessions = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($openSessions) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentOpenSessions;
my %totalOpenSessions;
my $totalPeriod;
my %minOpenSessions;
my %maxOpenSessions;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentOpenSessions))
        {
            my $rate = $currentOpenSessions{$key}/$currentPeriod;

            if (! exists($minOpenSessions{$key}) || ($rate < $minOpenSessions{$key}))
            {
                $minOpenSessions{$key} = $rate;
            }
            if (! exists($maxOpenSessions{$key}) || ($rate > $maxOpenSessions{$key}))
            {
                $maxOpenSessions{$key} = $rate;
            }
            $totalOpenSessions{$key} += $currentOpenSessions{$key};
            $currentOpenSessions{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentOpenSessions{$fields[$blade]} += $fields[$openSessions]*$currentPeriod;
}

foreach $key (keys(%currentOpenSessions))
{
    my $rate = $currentOpenSessions{$key}/$currentPeriod;

    if (! exists($minOpenSessions{$key}) || ($rate < $minOpenSessions{$key}))
    {
        $minOpenSessions{$key} = $rate;
    }
    if (! exists($maxOpenSessions{$key}) || ($rate > $maxOpenSessions{$key}))
    {
        $maxOpenSessions{$key} = $rate;
    }
    $totalOpenSessions{$key} += $currentOpenSessions{$key};
    $currentOpenSessions{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentOpenSessions))
{

    printf "$key Per-Blade-Total-Open-Sessions-Avg:%.0f\n", ($totalOpenSessions{$key}/$totalPeriod);

    if (exists $minOpenSessions{$key})
    {
        #printf "$key Min:%.3f\n", ((($minOpenSessions{$key})/1024)/1024)/1000 ;
        #printf "$key Max:%.3f\n", ((($maxOpenSessions{$key})/1024)/1024)/1000 ;

        printf "$key Per-Blade-Total-Open-Sessions-Min:%.0f\n", $minOpenSessions{$key};
        printf "$key Per-Blade-Total-Open-Sessions-Max:%.0f\n", $maxOpenSessions{$key};

    }
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-OPEN-SESSIONS"
echo "####################################################################"


cat `ls -rt ./SessionTrackingStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "totalOpenSessions"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$openSessions = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalOpenSessions\"")
    {
        $openSessions = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalSessions;
my $totalPeriod;
my $minSessions;
my $maxSessions;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minSessions) || ($rate < $minSessions))
        {
            $minSessions = $rate;
        }
        if (!defined($maxSessions) || ($rate > $maxSessions))
        {
            $maxSessions = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalSessions += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openSessions]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minSessions) || ($rate < $minSessions))
{
    $minSessions = $rate;
}
if (!defined($maxSessions) || ($rate > $maxSessions))
{
    $maxSessions = $rate;
}
$totalPeriod += $currentPeriod;
$totalSessions += $currentPdus;


printf "TOTAL-OPEN-SESSIONS-Avg:%.0f\n", ($totalSessions/$totalPeriod);

if (defined $minSessions)
{


    printf "TOTAL-OPEN-SESSIONS-Min:%.0f\n", $minSessions;
    printf "TOTAL-OPEN-SESSIONS-Max:%.0f\n", $maxSessions;
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# Per-Blade-Total-XDRs-Generated"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "numXdrsGenerated" (Total Number of XDR's Generated
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
my $numXdrsGenerated;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"numXdrsGenerated\"")
    {
        $numXdrsGenerated = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($numXdrsGenerated) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentNumXdrsGenerated;
my %totalNumXdrsGenerated;
my $totalPeriod;
my %minNumXdrsGenerated;
my %maxNumXdrsGenerated;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentNumXdrsGenerated))
        {
            my $rate = $currentNumXdrsGenerated{$key}/$currentPeriod;

            if (! exists($minNumXdrsGenerated{$key}) || ($rate < $minNumXdrsGenerated{$key}))
            {
                $minNumXdrsGenerated{$key} = $rate;
            }
            if (! exists($maxNumXdrsGenerated{$key}) || ($rate > $maxNumXdrsGenerated{$key}))
            {
                $maxNumXdrsGenerated{$key} = $rate;
            }
            $totalNumXdrsGenerated{$key} += $currentNumXdrsGenerated{$key};
            $currentNumXdrsGenerated{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentNumXdrsGenerated{$fields[$blade]} += $fields[$numXdrsGenerated]*$currentPeriod;
}

foreach $key (keys(%currentNumXdrsGenerated))
{
    my $rate = $currentNumXdrsGenerated{$key}/$currentPeriod;

    if (! exists($minNumXdrsGenerated{$key}) || ($rate < $minNumXdrsGenerated{$key}))
    {
        $minNumXdrsGenerated{$key} = $rate;
    }
    if (! exists($maxNumXdrsGenerated{$key}) || ($rate > $maxNumXdrsGenerated{$key}))
    {
        $maxNumXdrsGenerated{$key} = $rate;
    }
    $totalNumXdrsGenerated{$key} += $currentNumXdrsGenerated{$key};
    $currentNumXdrsGenerated{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentNumXdrsGenerated))
{

    printf "$key Per-Blade-Total-XDRs-Generated-Avg:%.0f\n", ($totalNumXdrsGenerated{$key}/$totalPeriod);

    if (exists $minNumXdrsGenerated{$key})
    {
        #printf "$key Min:%.3f\n", ((($minNumXdrsGenerated{$key})/1024)/1024)/1000 ;
        #printf "$key Max:%.3f\n", ((($maxNumXdrsGenerated{$key})/1024)/1024)/1000 ;

        printf "$key Per-Blade-Total-XDRs-Generated-Min:%.0f\n", $minNumXdrsGenerated{$key};
        printf "$key Per-Blade-Total-XDRs-Generated-Max:%.0f\n", $maxNumXdrsGenerated{$key};

    }
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-XDRs-Generated"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "totalOpenSessions"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numXdrsGenerated = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numXdrsGenerated\"")
    {
        $numXdrsGenerated = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentNumXdrsGenerated = 0;
my $totalNumXdrsGenerated;
my $totalPeriod;
my $minNumXdrsGenerated;
my $maxNumXdrsGenerated;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentNumXdrsGenerated/$currentPeriod;

        if (!defined($minNumXdrsGenerated) || ($rate < $minNumXdrsGenerated))
        {
            $minNumXdrsGenerated = $rate;
        }
        if (!defined($maxNumXdrsGenerated) || ($rate > $maxNumXdrsGenerated))
        {
            $maxNumXdrsGenerated = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalNumXdrsGenerated += $currentNumXdrsGenerated;
        $currentNumXdrsGenerated = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentNumXdrsGenerated += $fields[$numXdrsGenerated]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentNumXdrsGenerated\n";
my $rate = $currentNumXdrsGenerated/$currentPeriod;

if (!defined($minNumXdrsGenerated) || ($rate < $minNumXdrsGenerated))
{
    $minNumXdrsGenerated = $rate;
}
if (!defined($maxNumXdrsGenerated) || ($rate > $maxNumXdrsGenerated))
{
    $maxNumXdrsGenerated = $rate;
}
$totalPeriod += $currentPeriod;
$totalNumXdrsGenerated += $currentNumXdrsGenerated;


printf "TOTAL-XDRs-Generated-Avg:%.0f\n", ($totalNumXdrsGenerated/$totalPeriod);

if (defined $minNumXdrsGenerated)
{


    printf "TOTAL-XDRs-Generated-Min:%.0f\n", $minNumXdrsGenerated;
    printf "TOTAL-XDRs-Generated-Max:%.0f\n", $maxNumXdrsGenerated;
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# Per-Blade-Total-XDRs-Sent"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "numXdrsSent" (Total Number of XDR's Generated
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
my $numXdrsSent;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"numXdrsSent\"")
    {
        $numXdrsSent = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($numXdrsSent) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentNumXdrsSent;
my %totalNumXdrsSent;
my $totalPeriod;
my %minNumXdrsSent;
my %maxNumXdrsSent;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentNumXdrsSent))
        {
            my $rate = $currentNumXdrsSent{$key}/$currentPeriod;

            if (! exists($minNumXdrsSent{$key}) || ($rate < $minNumXdrsSent{$key}))
            {
                $minNumXdrsSent{$key} = $rate;
            }
            if (! exists($maxNumXdrsSent{$key}) || ($rate > $maxNumXdrsSent{$key}))
            {
                $maxNumXdrsSent{$key} = $rate;
            }
            $totalNumXdrsSent{$key} += $currentNumXdrsSent{$key};
            $currentNumXdrsSent{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentNumXdrsSent{$fields[$blade]} += $fields[$numXdrsSent]*$currentPeriod;
}

foreach $key (keys(%currentNumXdrsSent))
{
    my $rate = $currentNumXdrsSent{$key}/$currentPeriod;

    if (! exists($minNumXdrsSent{$key}) || ($rate < $minNumXdrsSent{$key}))
    {
        $minNumXdrsSent{$key} = $rate;
    }
    if (! exists($maxNumXdrsSent{$key}) || ($rate > $maxNumXdrsSent{$key}))
    {
        $maxNumXdrsSent{$key} = $rate;
    }
    $totalNumXdrsSent{$key} += $currentNumXdrsSent{$key};
    $currentNumXdrsSent{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentNumXdrsSent))
{

    printf "$key Per-Blade-Total-XDRs-Sent-Avg:%.0f\n", ($totalNumXdrsSent{$key}/$totalPeriod);

    if (exists $minNumXdrsSent{$key})
    {
        #printf "$key Min:%.3f\n", ((($minNumXdrsSent{$key})/1024)/1024)/1000 ;
        #printf "$key Max:%.3f\n", ((($maxNumXdrsSent{$key})/1024)/1024)/1000 ;

        printf "$key Per-Blade-Total-XDRs-Sent-Min:%.0f\n", $minNumXdrsSent{$key};
        printf "$key Per-Blade-Total-XDRs-Sent-Max:%.0f\n", $maxNumXdrsSent{$key};

    }
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-XDRs-Sent"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "numXdrsSent"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numXdrsSent = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numXdrsSent\"")
    {
        $numXdrsSent = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentNumXdrsSent = 0;
my $totalNumXdrsSent;
my $totalPeriod;
my $minNumXdrsSent;
my $maxNumXdrsSent;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentNumXdrsSent/$currentPeriod;

        if (!defined($minNumXdrsSent) || ($rate < $minNumXdrsSent))
        {
            $minNumXdrsSent = $rate;
        }
        if (!defined($maxNumXdrsSent) || ($rate > $maxNumXdrsSent))
        {
            $maxNumXdrsSent = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalNumXdrsSent += $currentNumXdrsSent;
        $currentNumXdrsSent = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentNumXdrsSent += $fields[$numXdrsSent]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentNumXdrsSent\n";
my $rate = $currentNumXdrsSent/$currentPeriod;

if (!defined($minNumXdrsSent) || ($rate < $minNumXdrsSent))
{
    $minNumXdrsSent = $rate;
}
if (!defined($maxNumXdrsSent) || ($rate > $maxNumXdrsSent))
{
    $maxNumXdrsSent = $rate;
}
$totalPeriod += $currentPeriod;
$totalNumXdrsSent += $currentNumXdrsSent;


printf "TOTAL-XDRs-Sent-Avg:%.0f\n", ($totalNumXdrsSent/$totalPeriod);

if (defined $minNumXdrsSent)
{


    printf "TOTAL-XDRs-Sent-Min:%.0f\n", $minNumXdrsSent;
    printf "TOTAL-XDRs-Sent-Max:%.0f\n", $maxNumXdrsSent;
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# Per-Blade-Total-XDRs-Dropped"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "numXdrsDropped" (Total Number of XDR's Dropped)
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
my $numXdrsDropped;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"numXdrsDropped\"")
    {
        $numXdrsDropped = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($numXdrsDropped) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentNumXdrsDropped;
my %totalNumXdrsDropped;
my $totalPeriod;
my %minNumXdrsDropped;
my %maxNumXdrsDropped;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentNumXdrsDropped))
        {
            my $rate = $currentNumXdrsDropped{$key}/$currentPeriod;

            if (! exists($minNumXdrsDropped{$key}) || ($rate < $minNumXdrsDropped{$key}))
            {
                $minNumXdrsDropped{$key} = $rate;
            }
            if (! exists($maxNumXdrsDropped{$key}) || ($rate > $maxNumXdrsDropped{$key}))
            {
                $maxNumXdrsDropped{$key} = $rate;
            }
            $totalNumXdrsDropped{$key} += $currentNumXdrsDropped{$key};
            $currentNumXdrsDropped{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentNumXdrsDropped{$fields[$blade]} += $fields[$numXdrsDropped]*$currentPeriod;
}

foreach $key (keys(%currentNumXdrsDropped))
{
    my $rate = $currentNumXdrsDropped{$key}/$currentPeriod;

    if (! exists($minNumXdrsDropped{$key}) || ($rate < $minNumXdrsDropped{$key}))
    {
        $minNumXdrsDropped{$key} = $rate;
    }
    if (! exists($maxNumXdrsDropped{$key}) || ($rate > $maxNumXdrsDropped{$key}))
    {
        $maxNumXdrsDropped{$key} = $rate;
    }
    $totalNumXdrsDropped{$key} += $currentNumXdrsDropped{$key};
    $currentNumXdrsDropped{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentNumXdrsDropped))
{

    printf "$key Per-Blade-Total-XDRs-Dropped-Avg:%.0f\n", ($totalNumXdrsDropped{$key}/$totalPeriod);

    if (exists $minNumXdrsDropped{$key})
    {
        #printf "$key Min:%.3f\n", ((($minNumXdrsDropped{$key})/1024)/1024)/1000 ;
        #printf "$key Max:%.3f\n", ((($maxNumXdrsDropped{$key})/1024)/1024)/1000 ;

        printf "$key Per-Blade-Total-XDRs-Dropped-Min:%.0f\n", $minNumXdrsDropped{$key};
        printf "$key Per-Blade-Total-XDRs-Dropped-Max:%.0f\n", $maxNumXdrsDropped{$key};

    }
}
'


rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-XDRs-Dropped"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "numXdrsDropped"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numXdrsDropped = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numXdrsDropped\"")
    {
        $numXdrsDropped = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentNumXdrsDropped = 0;
my $totalNumXdrsDropped;
my $totalPeriod;
my $minNumXdrsDropped;
my $maxNumXdrsDropped;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentNumXdrsDropped/$currentPeriod;

        if (!defined($minNumXdrsDropped) || ($rate < $minNumXdrsDropped))
        {
            $minNumXdrsDropped = $rate;
        }
        if (!defined($maxNumXdrsDropped) || ($rate > $maxNumXdrsDropped))
        {
            $maxNumXdrsDropped = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalNumXdrsDropped += $currentNumXdrsDropped;
        $currentNumXdrsDropped = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentNumXdrsDropped += $fields[$numXdrsDropped]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentNumXdrsDropped\n";
my $rate = $currentNumXdrsDropped/$currentPeriod;

if (!defined($minNumXdrsDropped) || ($rate < $minNumXdrsDropped))
{
    $minNumXdrsDropped = $rate;
}
if (!defined($maxNumXdrsDropped) || ($rate > $maxNumXdrsDropped))
{
    $maxNumXdrsDropped = $rate;
}
$totalPeriod += $currentPeriod;
$totalNumXdrsDropped += $currentNumXdrsDropped;


printf "TOTAL-XDRs-Dropped-Avg:%.0f\n", ($totalNumXdrsDropped/$totalPeriod);

if (defined $minNumXdrsDropped)
{


    printf "TOTAL-XDRs-Dropped-Min:%.0f\n", $minNumXdrsDropped;
    printf "TOTAL-XDRs-Dropped-Max:%.0f\n", $maxNumXdrsDropped;
}
'


rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# Per-Blade-XDRs-Per-Second"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Per Blade Statistic: "xdrsPerSec" (XDR's Per Second)
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
my $xdrsPerSec;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"xdrsPerSec\"")
    {
        $xdrsPerSec = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($xdrsPerSec) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentXdrsPerSec;
my %totalXdrsPerSec;
my $totalPeriod;
my %minXdrsPerSec;
my %maxXdrsPerSec;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentXdrsPerSec))
        {
            my $rate = $currentXdrsPerSec{$key}/$currentPeriod;

            if (! exists($minXdrsPerSec{$key}) || ($rate < $minXdrsPerSec{$key}))
            {
                $minXdrsPerSec{$key} = $rate;
            }
            if (! exists($maxXdrsPerSec{$key}) || ($rate > $maxXdrsPerSec{$key}))
            {
                $maxXdrsPerSec{$key} = $rate;
            }
            $totalXdrsPerSec{$key} += $currentXdrsPerSec{$key};
            $currentXdrsPerSec{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentXdrsPerSec{$fields[$blade]} += $fields[$xdrsPerSec]*$currentPeriod;
}

foreach $key (keys(%currentXdrsPerSec))
{
    my $rate = $currentXdrsPerSec{$key}/$currentPeriod;

    if (! exists($minXdrsPerSec{$key}) || ($rate < $minXdrsPerSec{$key}))
    {
        $minXdrsPerSec{$key} = $rate;
    }
    if (! exists($maxXdrsPerSec{$key}) || ($rate > $maxXdrsPerSec{$key}))
    {
        $maxXdrsPerSec{$key} = $rate;
    }
    $totalXdrsPerSec{$key} += $currentXdrsPerSec{$key};
    $currentXdrsPerSec{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentXdrsPerSec))
{

    printf "$key Per-Blade-XDRs-Per-Second-Avg:%.0f\n", ($totalXdrsPerSec{$key}/$totalPeriod);

    if (exists $minXdrsPerSec{$key})
    {
        #printf "$key Min:%.3f\n", ((($minXdrsPerSec{$key})/1024)/1024)/1000 ;
        #printf "$key Max:%.3f\n", ((($maxXdrsPerSec{$key})/1024)/1024)/1000 ;

        printf "$key Per-Blade-XDRs-Per-Second-Min:%.0f\n", $minXdrsPerSec{$key};
        printf "$key Per-Blade-XDRs-Per-Second-Max:%.0f\n", $maxXdrsPerSec{$key};

    }
}
'



rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-XDRs-Per-Sec"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "xdrsPerSec"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$xdrsPerSec = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"xdrsPerSec\"")
    {
        $xdrsPerSec = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentXdrsPerSec = 0;
my $totalXdrsPerSec;
my $totalPeriod;
my $minXdrsPerSec;
my $maxXdrsPerSec;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentXdrsPerSec/$currentPeriod;

        if (!defined($minXdrsPerSec) || ($rate < $minXdrsPerSec))
        {
            $minXdrsPerSec = $rate;
        }
        if (!defined($maxXdrsPerSec) || ($rate > $maxXdrsPerSec))
        {
            $maxXdrsPerSec = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalXdrsPerSec += $currentXdrsPerSec;
        $currentXdrsPerSec = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentXdrsPerSec += $fields[$xdrsPerSec]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentXdrsPerSec\n";
my $rate = $currentXdrsPerSec/$currentPeriod;

if (!defined($minXdrsPerSec) || ($rate < $minXdrsPerSec))
{
    $minXdrsPerSec = $rate;
}
if (!defined($maxXdrsPerSec) || ($rate > $maxXdrsPerSec))
{
    $maxXdrsPerSec = $rate;
}
$totalPeriod += $currentPeriod;
$totalXdrsPerSec += $currentXdrsPerSec;


printf "TOTAL-XDRs-Per-Sec-Avg:%.0f\n", ($totalXdrsPerSec/$totalPeriod);

if (defined $minXdrsPerSec)
{


    printf "TOTAL-XDRs-Per-Sec-Min:%.0f\n", $minXdrsPerSec;
    printf "TOTAL-XDRs-Per-Sec-Max:%.0f\n", $maxXdrsPerSec;
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# Per-Blade-XDRs-Dropped-Per-Second"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Per Blade Statistic: "xdrsDroppedPerSec" (XDR's Dropped Per Second)
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
my $xdrsDroppedPerSec;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"xdrsDroppedPerSec\"")
    {
        $xdrsDroppedPerSec = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($xdrsDroppedPerSec) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentXdrsDroppedPerSec;
my %totalXdrsDroppedPerSec;
my $totalPeriod;
my %minXdrsDroppedPerSec;
my %maxXdrsDroppedPerSec;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentXdrsDroppedPerSec))
        {
            my $rate = $currentXdrsDroppedPerSec{$key}/$currentPeriod;

            if (! exists($minXdrsDroppedPerSec{$key}) || ($rate < $minXdrsDroppedPerSec{$key}))
            {
                $minXdrsDroppedPerSec{$key} = $rate;
            }
            if (! exists($maxXdrsDroppedPerSec{$key}) || ($rate > $maxXdrsDroppedPerSec{$key}))
            {
                $maxXdrsDroppedPerSec{$key} = $rate;
            }
            $totalXdrsDroppedPerSec{$key} += $currentXdrsDroppedPerSec{$key};
            $currentXdrsDroppedPerSec{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period];
    $currentXdrsDroppedPerSec{$fields[$blade]} += $fields[$xdrsDroppedPerSec]*$currentPeriod;
}

foreach $key (keys(%currentXdrsDroppedPerSec))
{
    my $rate = $currentXdrsDroppedPerSec{$key}/$currentPeriod;

    if (! exists($minXdrsDroppedPerSec{$key}) || ($rate < $minXdrsDroppedPerSec{$key}))
    {
        $minXdrsDroppedPerSec{$key} = $rate;
    }
    if (! exists($maxXdrsDroppedPerSec{$key}) || ($rate > $maxXdrsDroppedPerSec{$key}))
    {
        $maxXdrsDroppedPerSec{$key} = $rate;
    }
    $totalXdrsDroppedPerSec{$key} += $currentXdrsDroppedPerSec{$key};
    $currentXdrsDroppedPerSec{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentXdrsDroppedPerSec))
{

    printf "$key Per-Blade-XDRs-Dropped-Per-Second-Avg:%.0f\n", ($totalXdrsDroppedPerSec{$key}/$totalPeriod);

    if (exists $minXdrsDroppedPerSec{$key})
    {
        #printf "$key Min:%.3f\n", ((($minXdrsDroppedPerSec{$key})/1024)/1024)/1000 ;
        #printf "$key Max:%.3f\n", ((($maxXdrsDroppedPerSec{$key})/1024)/1024)/1000 ;

        printf "$key Per-Blade-XDRs-Dropped-Per-Second-Min:%.0f\n", $minXdrsDroppedPerSec{$key};
        printf "$key Per-Blade-XDRs-Dropped-Per-Second-Max:%.0f\n", $maxXdrsDroppedPerSec{$key};

    }
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TOTAL-XDRs-Dropped-Per-Sec"
echo "####################################################################"


cat `ls -rt ./XdrHealthStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "xdrsDroppedPerSec"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$xdrsDroppedPerSec = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"xdrsDroppedPerSec\"")
    {
        $xdrsDroppedPerSec = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentXdrsDroppedPerSec = 0;
my $totalXdrsDroppedPerSec;
my $totalPeriod;
my $minXdrsDroppedPerSec;
my $maxXdrsDroppedPerSec;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentXdrsDroppedPerSec/$currentPeriod;

        if (!defined($minXdrsDroppedPerSec) || ($rate < $minXdrsDroppedPerSec))
        {
            $minXdrsDroppedPerSec = $rate;
        }
        if (!defined($maxXdrsDroppedPerSec) || ($rate > $maxXdrsDroppedPerSec))
        {
            $maxXdrsDroppedPerSec = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalXdrsDroppedPerSec += $currentXdrsDroppedPerSec;
        $currentXdrsDroppedPerSec = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentXdrsDroppedPerSec += $fields[$xdrsDroppedPerSec]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentXdrsDroppedPerSec\n";
my $rate = $currentXdrsDroppedPerSec/$currentPeriod;

if (!defined($minXdrsDroppedPerSec) || ($rate < $minXdrsDroppedPerSec))
{
    $minXdrsDroppedPerSec = $rate;
}
if (!defined($maxXdrsDroppedPerSec) || ($rate > $maxXdrsDroppedPerSec))
{
    $maxXdrsDroppedPerSec = $rate;
}
$totalPeriod += $currentPeriod;
$totalXdrsDroppedPerSec += $currentXdrsDroppedPerSec;


printf "TOTAL-XDRs-Dropped-Per-Sec-Avg:%.0f\n", ($totalXdrsDroppedPerSec/$totalPeriod);

if (defined $minXdrsDroppedPerSec)
{


    printf "TOTAL-XDRs-Dropped-Per-Sec-Min:%.0f\n", $minXdrsDroppedPerSec;
    printf "TOTAL-XDRs-Dropped-Per-Sec-Max:%.0f\n", $maxXdrsDroppedPerSec;
}
'




rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# Per-Blade TrafficProcessor-CPU-UTILIZATION (%)"
echo "####################################################################"


cat `ls -rt ./TrafficProcessorSystemStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "trafficprocessorCapacity" (CPU Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
my $trafficprocessorCapacity;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"trafficprocessorCapacity\"")
    {
        $trafficprocessorCapacity = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($trafficprocessorCapacity) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentCpu;
my %totalCpu;
my $totalPeriod;
my %minRate;
my %maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentCpu))
        {
            my $rate = $currentCpu{$key}/$currentPeriod;

            if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
            {
                $minRate{$key} = $rate;
            }
            if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
            {
                $maxRate{$key} = $rate;
            }
            $totalCpu{$key} += $currentCpu{$key};
            $currentCpu{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentCpu{$fields[$blade]} += $fields[$trafficprocessorCapacity]*$currentPeriod;
}

foreach $key (keys(%currentCpu))
{
    my $rate = $currentCpu{$key}/$currentPeriod;

    if (! exists($minRate{$key}) || ($rate < $minRate{$key}))
    {
        $minRate{$key} = $rate;
    }
    if (! exists($maxRate{$key}) || ($rate > $maxRate{$key}))
    {
        $maxRate{$key} = $rate;
    }
    $totalCpu{$key} += $currentCpu{$key};
    $currentCpu{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentCpu))
{

    printf "$key Per-Blade TrafficProcessor-CPU-UTILIZATION-Avg:%.3f\n", ($totalCpu{$key}/$totalPeriod*100);

    if (exists $minRate{$key})
    {
        printf "$key Per-Blade TrafficProcessor-CPU-UTILIZATION-Min:%.3f\n", ($minRate{$key})*100;
        printf "$key Per-Blade TrafficProcessor-CPU-UTILIZATION-Max:%.3f\n", ($maxRate{$key})*100;
    }
}
'

rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TrafficProcessor-Virtual-Memory-Utilization (GigaBytes)"
echo "####################################################################"


cat `ls -rt ./TrafficProcessorSystemStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "vmSize" (Virtual Memory Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
my $vmSize;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"vmSize\"")
    {
        $vmSize = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($vmSize) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentVmSize;
my %totalVmSize;
my $totalPeriod;
my %minVmSize;
my %maxVmSize;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentVmSize))
        {
            my $rate = $currentVmSize{$key}/$currentPeriod;

            if (! exists($minVmSize{$key}) || ($rate < $minVmSize{$key}))
            {
                $minVmSize{$key} = $rate;
            }
            if (! exists($maxVmSize{$key}) || ($rate > $maxVmSize{$key}))
            {
                $maxVmSize{$key} = $rate;
            }
            $totalVmSize{$key} += $currentVmSize{$key};
            $currentVmSize{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentVmSize{$fields[$blade]} += $fields[$vmSize]*$currentPeriod;
}

foreach $key (keys(%currentVmSize))
{
    my $rate = $currentVmSize{$key}/$currentPeriod;

    if (! exists($minVmSize{$key}) || ($rate < $minVmSize{$key}))
    {
        $minVmSize{$key} = $rate;
    }
    if (! exists($maxVmSize{$key}) || ($rate > $maxVmSize{$key}))
    {
        $maxVmSize{$key} = $rate;
    }
    $totalVmSize{$key} += $currentVmSize{$key};
    $currentVmSize{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentVmSize))
{

    printf "$key TrafficProcessor-Virtual-Memory-Utilization-Avg:%.3f\n", ((($totalVmSize{$key}/$totalPeriod/1024)/1024)/1000);
     #printf "$key Avg:%.1f\n", ((((($totalVmSize{key})/$totalPeriod)/1024)/1024)/1000);

    if (exists $minVmSize{$key})
    {
        printf "$key TrafficProcessor-Virtual-Memory-Utilization-Min:%.3f\n", ((($minVmSize{$key})/1024)/1024)/1000 ;
        printf "$key TrafficProcessor-Virtual-Memory-Utilization-Max:%.3f\n", ((($maxVmSize{$key})/1024)/1024)/1000 ;

        #printf "$key Min:%.1f\n", $minVmSize{$key}/1024/1024/1000;
        #printf "$key Max:%.1f\n", $maxVmSize{$key}/1024/1024/1000;

    }
}
'


rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# TrafficProcessor-Current-Memory-Utilization (GigaBytes)"
echo "####################################################################"


cat `ls -rt ./TrafficProcessorSystemStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"   > ~/myFile

##########################################################################
## Statistic: "generic_current_allocated_bytes" (Current Memory Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
my $gcab;
my $period;
my $time;
my $tmp;
my $blade;
foreach $field (@fields)
{
    if ($field eq "\"generic_current_allocated_bytes\"")
    {
        $gcab = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    elsif ($field eq "blade")
    {
        $blade = $tmp;
    }

    $tmp++;
}
if (! (defined($gcab) && defined ($period) && defined($time) && defined($blade)))
{
    die("Could not find some field");
}

my $currentTime;
my $currentPeriod;
my %currentGcab;
my %totalGcab;
my $totalPeriod;
my %minGcab;
my %maxGcab;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime )
    {
        foreach $key (keys(%currentGcab))
        {
            my $rate = $currentGcab{$key}/$currentPeriod;

            if (! exists($minGcab{$key}) || ($rate < $minGcab{$key}))
            {
                $minGcab{$key} = $rate;
            }
            if (! exists($maxGcab{$key}) || ($rate > $maxGcab{$key}))
            {
                $maxGcab{$key} = $rate;
            }
            $totalGcab{$key} += $currentGcab{$key};
            $currentGcab{$key} = 0;
        }
        $totalPeriod += $currentPeriod;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentGcab{$fields[$blade]} += $fields[$gcab]*$currentPeriod;
}

foreach $key (keys(%currentGcab))
{
    my $rate = $currentGcab{$key}/$currentPeriod;

    if (! exists($minGcab{$key}) || ($rate < $minGcab{$key}))
    {
        $minGcab{$key} = $rate;
    }
    if (! exists($maxGcab{$key}) || ($rate > $maxGcab{$key}))
    {
        $maxGcab{$key} = $rate;
    }
    $totalGcab{$key} += $currentGcab{$key};
    $currentGcab{$key} = 0;
}
$totalPeriod += $currentPeriod;

foreach $key (keys(%currentGcab))
{

    printf "$key TrafficProcessor-Current-Memory-Utilization-Avg:%.3f\n", ((($totalGcab{$key}/$totalPeriod/1024)/1024)/1000);
     #printf "$key Avg:%.1f\n", ((((($totalGcab{key})/$totalPeriod)/1024)/1024)/1000);

    if (exists $minGcab{$key})
    {
        printf "$key TrafficProcessor-Current-Memory-Utilization-Min:%.3f\n", ((($minGcab{$key})/1024)/1024)/1000 ;
        printf "$key TrafficProcessor-Current-Memory-Utilization-Max:%.3f\n", ((($maxGcab{$key})/1024)/1024)/1000 ;

        #printf "$key Min:%.1f\n", $minGcab{$key}/1024/1024/1000;
        #printf "$key Max:%.1f\n", $maxGcab{$key}/1024/1024/1000;

    }
}
'



echo "#################################################################################################"
echo "# IIC (EzChip-TPrs-CPU-Utilization (%)"
echo "# TOPparse - Parses and verifies the packet."
echo "# Collects state for the OPPL to use later (l2Type, l3Type, l4Type, tunnelType, fragment, etc)."
echo "# Generates key information for the table and tree searches."
echo "# (Avg) should not exceed 85%."
echo "#################################################################################################"


cat `ls -rt ./IICDdmOpplCpuStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile
##########################################################################
## Statistic: "TPrsCpuUsageAvg" (TOPparse CPU Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cpuUsage = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"TPrsCpuUsageAvg\"")
    {
        $cpuUsage = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentCpuUsage = 0;
my $totalCpuUsage;
my $totalPeriod;
my $minCpuUsage;
my $maxCpuUsage;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $size = $currentCpuUsage/$currentPeriod;

        if (!defined($minCpuUsage) || ($size < $minCpuUsage))
        {
            $minCpuUsage = $size;
        }
        if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
        {
            $maxCpuUsage = $size;
        }
        $totalPeriod += $currentPeriod;
        $totalCpuUsage += $currentCpuUsage;
        $currentCpuUsage = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentCpuUsage += $fields[$cpuUsage]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentCpuUsage\n";
my $size = $currentCpuUsage/$currentPeriod;

if (!defined($minCpuUsage) || ($size < $minCpuUsage))
{
    $minCpuUsage = $size;
}
if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
{
    $maxCpuUsage = $size;
}
$totalPeriod += $currentPeriod;
$totalCpuUsage += $currentCpuUsage;


printf "EzChip-TPrs-CPU-Utilization-Avg:%.0f\n", ($totalCpuUsage/$totalPeriod);

if (defined $minCpuUsage)
{


    printf "EzChip-TPrs-CPU-Utilization-Min:%.0f\n", $minCpuUsage;
    printf "EzChip-TPrs-CPU-Utilization-Max:%.0f\n", $maxCpuUsage;
}
'
echo "#################################################################################################"
echo "# IIC (EzChip-TRsv-CPU-Utilization (%)"
echo "# TOPresolve - Takes the results from all the table and tree lookups and classifies the packet."
echo "# Adds entries to the flow table."
echo "# (Avg) should not exceed 85%."
echo "#################################################################################################"


cat `ls -rt ./IICDdmOpplCpuStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile
##########################################################################
## Statistic: "TRsvCpuUsageAvg" (TOPresolve CPU Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cpuUsage = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"TRsvCpuUsageAvg\"")
    {
        $cpuUsage = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentCpuUsage = 0;
my $totalCpuUsage;
my $totalPeriod;
my $minCpuUsage;
my $maxCpuUsage;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $size = $currentCpuUsage/$currentPeriod;

        if (!defined($minCpuUsage) || ($size < $minCpuUsage))
        {
            $minCpuUsage = $size;
        }
        if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
        {
            $maxCpuUsage = $size;
        }
        $totalPeriod += $currentPeriod;
        $totalCpuUsage += $currentCpuUsage;
        $currentCpuUsage = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentCpuUsage += $fields[$cpuUsage]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentCpuUsage\n";
my $size = $currentCpuUsage/$currentPeriod;

if (!defined($minCpuUsage) || ($size < $minCpuUsage))
{
    $minCpuUsage = $size;
}
if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
{
    $maxCpuUsage = $size;
}
$totalPeriod += $currentPeriod;
$totalCpuUsage += $currentCpuUsage;


printf "EzChip-TRsv-CPU-Utilization-Avg:%.1f\n", ($totalCpuUsage/$totalPeriod);

if (defined $minCpuUsage)
{


    printf "EzChip-TRsv-CPU-Utilization-Min:%.1f\n", $minCpuUsage;
    printf "EzChip-TRsv-CPU-Utilization-Max:%.1f\n", $maxCpuUsage;
}
'

echo "##############################################################################################################"
echo "# IIC (EzChip-TMdf-CPU-Utilization (%)"
echo "# TOPmodify - Adds a descriptor to the front of the packet with all the packet information needed by the OPPL."
echo "# Generates key information for the table and tree searches."
echo "# (Avg) should not exceed 85%."
echo "##############################################################################################################"


cat `ls -rt ./IICDdmOpplCpuStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile
##########################################################################
## Statistic: "TMdfCpuUsageAvg" (TOPmodify CPU Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cpuUsage = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"TMdfCpuUsageAvg\"")
    {
        $cpuUsage = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentCpuUsage = 0;
my $totalCpuUsage;
my $totalPeriod;
my $minCpuUsage;
my $maxCpuUsage;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $size = $currentCpuUsage/$currentPeriod;

        if (!defined($minCpuUsage) || ($size < $minCpuUsage))
        {
            $minCpuUsage = $size;
        }
        if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
        {
            $maxCpuUsage = $size;
        }
        $totalPeriod += $currentPeriod;
        $totalCpuUsage += $currentCpuUsage;
        $currentCpuUsage = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentCpuUsage += $fields[$cpuUsage]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentCpuUsage\n";
my $size = $currentCpuUsage/$currentPeriod;

if (!defined($minCpuUsage) || ($size < $minCpuUsage))
{
    $minCpuUsage = $size;
}
if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
{
    $maxCpuUsage = $size;
}
$totalPeriod += $currentPeriod;
$totalCpuUsage += $currentCpuUsage;


printf "EzChip-TMdf-CPU-Utilization-Avg:%.1f\n", ($totalCpuUsage/$totalPeriod);

if (defined $minCpuUsage)
{


    printf "EzChip-TMdf-CPU-Utilization-Min:%.1f\n", $minCpuUsage;
    printf "EzChip-TMdf-CPU-Utilization-Max:%.1f\n", $maxCpuUsage;
}
'

rm -rf ./myFile
echo "####################################################################"
echo "# IIC (Hornet-OPPL-CPU-Utilization (%)"
echo "# OPPL: Processing Code on the Hornet."
echo "# (Avg) should not exceed 85%."
echo "####################################################################"


cat `ls -rt ./IICDdmOpplCpuStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

rm -rf ./myFile
##########################################################################
## Statistic: "OpplCpuUsageAvg" (OPPL CPU Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cpuUsage = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"OpplCpuUsageAvg\"")
    {
        $cpuUsage = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentCpuUsage = 0;
my $totalCpuUsage;
my $totalPeriod;
my $minCpuUsage;
my $maxCpuUsage;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $size = $currentCpuUsage/$currentPeriod;

        if (!defined($minCpuUsage) || ($size < $minCpuUsage))
        {
            $minCpuUsage = $size;
        }
        if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
        {
            $maxCpuUsage = $size;
        }
        $totalPeriod += $currentPeriod;
        $totalCpuUsage += $currentCpuUsage;
        $currentCpuUsage = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentCpuUsage += $fields[$cpuUsage]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentCpuUsage\n";
my $size = $currentCpuUsage/$currentPeriod;

if (!defined($minCpuUsage) || ($size < $minCpuUsage))
{
    $minCpuUsage = $size;
}
if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
{
    $maxCpuUsage = $size;
}
$totalPeriod += $currentPeriod;
$totalCpuUsage += $currentCpuUsage;


printf "Hornet-OPPL-CPU-Utilization-Avg:%.1f\n", ($totalCpuUsage/$totalPeriod);

if (defined $minCpuUsage)
{


    printf "Hornet-OPPL-CPU-Utilization-Min:%.1f\n", $minCpuUsage;
    printf "Hornet-OPPL-CPU-Utilization-Max:%.1f\n", $maxCpuUsage;
}
'

rm -rf ./myFile
echo "####################################################################"
echo "# IIC (Hornet-DDM-CPU-Utilization (%)"
echo "# DDM: Distribution Code on the Hornet."
echo "# (Avg) should not exceed 85%."
echo "####################################################################"


cat `ls -rt ./IICDdmOpplCpuStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile
##########################################################################
## Statistic: "DDMCpuUsageAvg" (OPPL CPU Utilization) AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cpuUsage = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"DDMCpuUsageAvg\"")
    {
        $cpuUsage = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentCpuUsage = 0;
my $totalCpuUsage;
my $totalPeriod;
my $minCpuUsage;
my $maxCpuUsage;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $size = $currentCpuUsage/$currentPeriod;

        if (!defined($minCpuUsage) || ($size < $minCpuUsage))
        {
            $minCpuUsage = $size;
        }
        if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
        {
            $maxCpuUsage = $size;
        }
        $totalPeriod += $currentPeriod;
        $totalCpuUsage += $currentCpuUsage;
        $currentCpuUsage = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentCpuUsage += $fields[$cpuUsage]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentCpuUsage\n";
my $size = $currentCpuUsage/$currentPeriod;

if (!defined($minCpuUsage) || ($size < $minCpuUsage))
{
    $minCpuUsage = $size;
}
if (!defined($maxCpuUsage) || ($size > $maxCpuUsage))
{
    $maxCpuUsage = $size;
}
$totalPeriod += $currentPeriod;
$totalCpuUsage += $currentCpuUsage;


printf "Hornet-DDM-CPU-Utilization-Avg:%.1f\n", ($totalCpuUsage/$totalPeriod);

if (defined $minCpuUsage)
{


    printf "Hornet-DDM-CPU-Utilization-Min:%.1f\n", $minCpuUsage;
    printf "Hornet-DDM-CPU-Utilization-Max:%.1f\n", $maxCpuUsage;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Dropped-Packets: (Packets)"
echo "#################################################################################################"


cat `ls -rt ./DropStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" | egrep -i 'element|EzChip-1-2-1' >  ~/myFile
##########################################################################
## Statistic: "dropCount" (EzChip: Dropped Packets ) TOTAL
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$dropCount = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"dropCount\"")
    {
        $dropCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentDropCount = 0;
my $totalDropCount;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentDropCount/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalDropCount += $currentDropCount;
        $currentDropCount = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
	$currentDropCount += $fields[$dropCount];
}
my $drops = $currentDropCount/$currentPeriod;

$totalDropCount += $currentDropCount;


printf "Total (EzChip) :%.0f\n", ($totalDropCount);
'

rm -rf ~/myFile

cat `ls -rt ./DropStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" | egrep -i 'element|Cavium-1-2-1' >  ~/myFile
##########################################################################
## Statistic: "dropCount" (Cavium: Dropped Packets ) TOTAL
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$dropCount = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"dropCount\"")
    {
        $dropCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentDropCount = 0;
my $totalDropCount;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentDropCount/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalDropCount += $currentDropCount;
        $currentDropCount = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentDropCount += $fields[$dropCount];
}
my $drops = $currentDropCount/$currentPeriod;

$totalDropCount += $currentDropCount;


printf "Total (Cavium) :%.0f\n", ($totalDropCount);
'

rm -rf ~/myFile

cat `ls -rt ./DropStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" | egrep -i 'element|Bcm-1-2-1' >  ~/myFile
##########################################################################
## Statistic: "dropCount" (Bcm: Dropped Packets ) TOTAL
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$dropCount = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"dropCount\"")
    {
        $dropCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentDropCount = 0;
my $totalDropCount;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentDropCount/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalDropCount += $currentDropCount;
        $currentDropCount = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentDropCount += $fields[$dropCount];
}
my $drops = $currentDropCount/$currentPeriod;

$totalDropCount += $currentDropCount;


printf "Total (Bcm) :%.0f\n", ($totalDropCount);
'

rm -rf ~/myFile

cat `ls -rt ./DropStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" | egrep -i 'element|BackPlane-1-2-1' >  ~/myFile
##########################################################################
## Statistic: "dropCount" (BackPlane: Dropped Packets ) TOTAL
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$dropCount = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"dropCount\"")
    {
        $dropCount = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentDropCount = 0;
my $totalDropCount;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentDropCount/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalDropCount += $currentDropCount;
        $currentDropCount = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentDropCount += $fields[$dropCount];
}
my $drops = $currentDropCount/$currentPeriod;

$totalDropCount += $currentDropCount;


printf "Total (BackPlane) :%.0f\n", ($totalDropCount);
'



rm -rf ~/myFile
echo "#################################################################################################"
echo "# FSPP (Flow State Packet Processing) Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$dasaAllocFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"dasaAllocFailures\"")
    {
        $dasaAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaldasaAllocFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentdasaAllocFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaldasaAllocFailures += $currentdasaAllocFailures;
        $currentdasaAllocFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentdasaAllocFailures += $fields[$dasaAllocFailures];
}
my $drops = $currentdasaAllocFailures/$currentPeriod;

$totaldasaAllocFailures += $currentdasaAllocFailures;


printf "Total (FSPP- DASA Allocation Failures):%.0f\n", ($totaldasaAllocFailures);
'

rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$frAllocFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"frAllocFailures\"")
    {
        $frAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalfrAllocFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentfrAllocFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalfrAllocFailures += $currentfrAllocFailures;
        $currentfrAllocFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentfrAllocFailures += $fields[$frAllocFailures];
}
my $drops = $currentfrAllocFailures/$currentPeriod;

$totalfrAllocFailures += $currentfrAllocFailures;


printf "Total (FSPP- Flow Record Allocation Failures):%.0f\n", ($totalfrAllocFailures);
'

rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$fsbProtAllocFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"fsbProtAllocFailures\"")
    {
        $fsbProtAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalfsbProtAllocFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentfsbProtAllocFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalfsbProtAllocFailures += $currentfsbProtAllocFailures;
        $currentfsbProtAllocFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentfsbProtAllocFailures += $fields[$fsbProtAllocFailures];
}
my $drops = $currentfsbProtAllocFailures/$currentPeriod;

$totalfsbProtAllocFailures += $currentfsbProtAllocFailures;


printf "Total (FSPP- FSB (Flow State Block) Protocol Allocation Failures):%.0f\n", ($totalfsbProtAllocFailures);
'


rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numFsbsCreatNoClass = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numFsbsCreatNoClass\"")
    {
        $numFsbsCreatNoClass = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumFsbsCreatNoClass;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumFsbsCreatNoClass/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumFsbsCreatNoClass += $currentnumFsbsCreatNoClass;
        $currentnumFsbsCreatNoClass = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumFsbsCreatNoClass += $fields[$numFsbsCreatNoClass];
}
my $drops = $currentnumFsbsCreatNoClass/$currentPeriod;

$totalnumFsbsCreatNoClass += $currentnumFsbsCreatNoClass;


printf "Total (FSPP- Number of FSBs Create No Class):%.0f\n", ($totalnumFsbsCreatNoClass);
'

rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$pduClassAllocError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"pduClassAllocError\"")
    {
        $pduClassAllocError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalpduClassAllocError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentpduClassAllocError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalpduClassAllocError += $currentpduClassAllocError;
        $currentpduClassAllocError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentpduClassAllocError += $fields[$pduClassAllocError];
}
my $drops = $currentpduClassAllocError/$currentPeriod;

$totalpduClassAllocError += $currentpduClassAllocError;


printf "Total (FSPP- PDU Class Alloc Error):%.0f\n", ($totalpduClassAllocError);
'

rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$protoMsgAllocFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"protoMsgAllocFailures\"")
    {
        $protoMsgAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalprotoMsgAllocFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentprotoMsgAllocFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalprotoMsgAllocFailures += $currentprotoMsgAllocFailures;
        $currentprotoMsgAllocFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentprotoMsgAllocFailures += $fields[$protoMsgAllocFailures];
}
my $drops = $currentprotoMsgAllocFailures/$currentPeriod;

$totalprotoMsgAllocFailures += $currentprotoMsgAllocFailures;


printf "Total (FSPP- Protocol Message Allocation Failures):%.0f\n", ($totalprotoMsgAllocFailures);
'

rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$timerFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"timerFailures\"")
    {
        $timerFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltimerFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttimerFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltimerFailures += $currenttimerFailures;
        $currenttimerFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttimerFailures += $fields[$timerFailures];
}
my $drops = $currenttimerFailures/$currentPeriod;

$totaltimerFailures += $currenttimerFailures;


printf "Total (FSPP- Timer Failures):%.0f\n", ($totaltimerFailures);
'

rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalNonTcpFlows = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalNonTcpFlows\"")
    {
        $totalNonTcpFlows = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltotalNonTcpFlows;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttotalNonTcpFlows/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltotalNonTcpFlows += $currenttotalNonTcpFlows;
        $currenttotalNonTcpFlows = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttotalNonTcpFlows += $fields[$totalNonTcpFlows];
}
my $drops = $currenttotalNonTcpFlows/$currentPeriod;

$totaltotalNonTcpFlows += $currenttotalNonTcpFlows;


printf "Total (FSPP- Non TCP Flows):%.0f\n", ($totaltotalNonTcpFlows);
'


rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalPkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalPkts\"")
    {
        $totalPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltotalPkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttotalPkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltotalPkts += $currenttotalPkts;
        $currenttotalPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttotalPkts += $fields[$totalPkts];
}
my $drops = $currenttotalPkts/$currentPeriod;

$totaltotalPkts += $currenttotalPkts;


printf "Total (FSPP- Packets):%.0f\n", ($totaltotalPkts);
'


rm -rf ~/myFile

cat `ls -rt ./IicFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalTcpFlows = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalTcpFlows\"")
    {
        $totalTcpFlows = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltotalTcpFlows;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttotalTcpFlows/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltotalTcpFlows += $currenttotalTcpFlows;
        $currenttotalTcpFlows = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttotalTcpFlows += $fields[$totalTcpFlows];
}
my $drops = $currenttotalTcpFlows/$currentPeriod;

$totaltotalTcpFlows += $currenttotalTcpFlows;


printf "Total (FSPP- TCP Flows):%.0f\n", ($totaltotalTcpFlows);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) Active Flows:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenactiveFlows"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$activeFlows = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"activeFlows\"")
    {
        $openactiveFlows = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalactiveFlows;
my $totalPeriod;
my $minactiveFlows;
my $maxactiveFlows;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minactiveFlows) || ($rate < $minactiveFlows))
        {
            $minactiveFlows = $rate;
        }
        if (!defined($maxactiveFlows) || ($rate > $maxactiveFlows))
        {
            $maxactiveFlows = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalactiveFlows += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openactiveFlows]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minactiveFlows) || ($rate < $minactiveFlows))
{
    $minactiveFlows = $rate;
}
if (!defined($maxactiveFlows) || ($rate > $maxactiveFlows))
{
    $maxactiveFlows = $rate;
}
$totalPeriod += $currentPeriod;
$totalactiveFlows += $currentPdus;


printf "FSPP-Active-flows-Avg:%.0f\n", ($totalactiveFlows/$totalPeriod);

if (defined $minactiveFlows)
{


    printf "FSPP-Active-flows-Min:%.0f\n", $minactiveFlows;
        printf "FSPP-Active-flows-Max:%.0f\n", $maxactiveFlows;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSPP-Flow-Record-Alloc-Failures:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenfrAllocFailures"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$frAllocFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"frAllocFailures\"")
    {
        $openfrAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalfrAllocFailures;
my $totalPeriod;
my $minfrAllocFailures;
my $maxfrAllocFailures;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minfrAllocFailures) || ($rate < $minfrAllocFailures))
        {
            $minfrAllocFailures = $rate;
        }
        if (!defined($maxfrAllocFailures) || ($rate > $maxfrAllocFailures))
        {
            $maxfrAllocFailures = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalfrAllocFailures += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openfrAllocFailures]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minfrAllocFailures) || ($rate < $minfrAllocFailures))
{
    $minfrAllocFailures = $rate;
}
if (!defined($maxfrAllocFailures) || ($rate > $maxfrAllocFailures))
{
    $maxfrAllocFailures = $rate;
}
$totalPeriod += $currentPeriod;
$totalfrAllocFailures += $currentPdus;


printf "FSPP-Flow-Record-Alloc-Failures-Avg:%.0f\n", ($totalfrAllocFailures/$totalPeriod);

if (defined $minfrAllocFailures)
{


    printf "FSPP-Flow-Record-Alloc-Failures-Min:%.0f\n", $minfrAllocFailures;
    printf "FSPP-Flow-Record-Alloc-Failures-Max:%.0f\n", $maxfrAllocFailures;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSPP-FSB-Alloc-Failures:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenfsbAllocFailures"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$fsbAllocFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"fsbAllocFailures\"")
    {
        $openfsbAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalfsbAllocFailures;
my $totalPeriod;
my $minfsbAllocFailures;
my $maxfsbAllocFailures;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minfsbAllocFailures) || ($rate < $minfsbAllocFailures))
        {
            $minfsbAllocFailures = $rate;
        }
        if (!defined($maxfsbAllocFailures) || ($rate > $maxfsbAllocFailures))
        {
            $maxfsbAllocFailures = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalfsbAllocFailures += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openfsbAllocFailures]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minfsbAllocFailures) || ($rate < $minfsbAllocFailures))
{
    $minfsbAllocFailures = $rate;
}
if (!defined($maxfsbAllocFailures) || ($rate > $maxfsbAllocFailures))
{
    $maxfsbAllocFailures = $rate;
}
$totalPeriod += $currentPeriod;
$totalfsbAllocFailures += $currentPdus;


printf "FSPP-FSB-Alloc-Failures-Avg:%.0f\n", ($totalfsbAllocFailures/$totalPeriod);

if (defined $minfsbAllocFailures)
{


    printf "FSPP-FSB-Alloc-Failures-Min:%.0f\n", $minfsbAllocFailures;
    printf "FSPP-FSB-Alloc-Failures-Max:%.0f\n", $maxfsbAllocFailures;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSPP-FSB-Out-Of-Sync:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenfsbOutOfSync"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$fsbOutOfSync = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"fsbOutOfSync\"")
    {
        $openfsbOutOfSync = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalfsbOutOfSync;
my $totalPeriod;
my $minfsbOutOfSync;
my $maxfsbOutOfSync;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minfsbOutOfSync) || ($rate < $minfsbOutOfSync))
        {
            $minfsbOutOfSync = $rate;
        }
        if (!defined($maxfsbOutOfSync) || ($rate > $maxfsbOutOfSync))
        {
            $maxfsbOutOfSync = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalfsbOutOfSync += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openfsbOutOfSync]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minfsbOutOfSync) || ($rate < $minfsbOutOfSync))
{
    $minfsbOutOfSync = $rate;
}
if (!defined($maxfsbOutOfSync) || ($rate > $maxfsbOutOfSync))
{
    $maxfsbOutOfSync = $rate;
}
$totalPeriod += $currentPeriod;
$totalfsbOutOfSync += $currentPdus;


printf "FSPP-FSB-Out-Of-Sync-Avg:%.0f\n", ($totalfsbOutOfSync/$totalPeriod);

if (defined $minfsbOutOfSync)
{


    printf "FSPP-FSB-Out-Of-Sync-Min:%.0f\n", $minfsbOutOfSync;
        printf "FSPP-FSB-Out-Of-Sync-Max:%.0f\n", $maxfsbOutOfSync;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSP-FSB-Search-Failures:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenfsbSrchFails"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$fsbSrchFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"fsbSrchFails\"")
    {
        $openfsbSrchFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalfsbSrchFails;
my $totalPeriod;
my $minfsbSrchFails;
my $maxfsbSrchFails;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minfsbSrchFails) || ($rate < $minfsbSrchFails))
        {
            $minfsbSrchFails = $rate;
        }
        if (!defined($maxfsbSrchFails) || ($rate > $maxfsbSrchFails))
        {
            $maxfsbSrchFails = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalfsbSrchFails += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openfsbSrchFails]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minfsbSrchFails) || ($rate < $minfsbSrchFails))
{
    $minfsbSrchFails = $rate;
}
if (!defined($maxfsbSrchFails) || ($rate > $maxfsbSrchFails))
{
    $maxfsbSrchFails = $rate;
}
$totalPeriod += $currentPeriod;
$totalfsbSrchFails += $currentPdus;


printf "FSP-FSB-Search-Failures-Avg:%.0f\n", ($totalfsbSrchFails/$totalPeriod);

if (defined $minfsbSrchFails)
{


    printf "FSP-FSB-Search-Failures-Min:%.0f\n", $minfsbSrchFails;
    printf "FSP-FSB-Search-Failures-Max:%.0f\n", $maxfsbSrchFails;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSPP-Hash-Table-Insert-Fails:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenhashTableInsertFails"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$hashTableInsertFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"hashTableInsertFails\"")
    {
        $openhashTableInsertFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalhashTableInsertFails;
my $totalPeriod;
my $minhashTableInsertFails;
my $maxhashTableInsertFails;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minhashTableInsertFails) || ($rate < $minhashTableInsertFails))
        {
            $minhashTableInsertFails = $rate;
        }
        if (!defined($maxhashTableInsertFails) || ($rate > $maxhashTableInsertFails))
        {
            $maxhashTableInsertFails = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalhashTableInsertFails += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openhashTableInsertFails]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minhashTableInsertFails) || ($rate < $minhashTableInsertFails))
{
    $minhashTableInsertFails = $rate;
}
if (!defined($maxhashTableInsertFails) || ($rate > $maxhashTableInsertFails))
{
    $maxhashTableInsertFails = $rate;
}
$totalPeriod += $currentPeriod;
$totalhashTableInsertFails += $currentPdus;


printf "FSPP-Hash-Table-Insert-Fails-Avg:%.0f\n", ($totalhashTableInsertFails/$totalPeriod);

if (defined $minhashTableInsertFails)
{


    printf "FSPP-Hash-Table-Insert-Fails-Min:%.0f\n", $minhashTableInsertFails;
    printf "FSPP-Hash-Table-Insert-Fails-Max:%.0f\n", $maxhashTableInsertFails;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSPP-Hash-Table-Remove-Fails:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenhashTableRemoveFails"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$hashTableRemoveFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"hashTableRemoveFails\"")
    {
        $openhashTableRemoveFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalhashTableRemoveFails;
my $totalPeriod;
my $minhashTableRemoveFails;
my $maxhashTableRemoveFails;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minhashTableRemoveFails) || ($rate < $minhashTableRemoveFails))
        {
            $minhashTableRemoveFails = $rate;
        }
        if (!defined($maxhashTableRemoveFails) || ($rate > $maxhashTableRemoveFails))
        {
            $maxhashTableRemoveFails = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalhashTableRemoveFails += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openhashTableRemoveFails]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minhashTableRemoveFails) || ($rate < $minhashTableRemoveFails))
{
    $minhashTableRemoveFails = $rate;
}
if (!defined($maxhashTableRemoveFails) || ($rate > $maxhashTableRemoveFails))
{
    $maxhashTableRemoveFails = $rate;
}
$totalPeriod += $currentPeriod;
$totalhashTableRemoveFails += $currentPdus;


printf "FSPP-Hash-Table-Remove-Fails-Avg:%.0f\n", ($totalhashTableRemoveFails/$totalPeriod);

if (defined $minhashTableRemoveFails)
{


    printf "FSPP-Hash-Table-Remove-Fails-Min:%.0f\n", $minhashTableRemoveFails;
    printf "FSPP-Hash-Table-Remove-Fails-Max:%.0f\n", $maxhashTableRemoveFails;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSPP-Timer-Failures:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpentimerFailures"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$timerFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"timerFailures\"")
    {
        $opentimerFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totaltimerFailures;
my $totalPeriod;
my $mintimerFailures;
my $maxtimerFailures;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($mintimerFailures) || ($rate < $mintimerFailures))
        {
            $mintimerFailures = $rate;
        }
        if (!defined($maxtimerFailures) || ($rate > $maxtimerFailures))
        {
            $maxtimerFailures = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totaltimerFailures += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$opentimerFailures]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($mintimerFailures) || ($rate < $mintimerFailures))
{
    $mintimerFailures = $rate;
}
if (!defined($maxtimerFailures) || ($rate > $maxtimerFailures))
{
    $maxtimerFailures = $rate;
}
$totalPeriod += $currentPeriod;
$totaltimerFailures += $currentPdus;


printf "FSPP-Timer-Failures-Avg:%.0f\n", ($totaltimerFailures/$totalPeriod);

if (defined $mintimerFailures)
{


    printf "FSPP-Timer-Failures-Min:%.0f\n", $mintimerFailures;
    printf "FSPP-Timer-Failures-Max:%.0f\n", $maxtimerFailures;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSPP-Tunnel-Update-Fails:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpentunnelUpdateFails"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$tunnelUpdateFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"tunnelUpdateFails\"")
    {
        $opentunnelUpdateFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totaltunnelUpdateFails;
my $totalPeriod;
my $mintunnelUpdateFails;
my $maxtunnelUpdateFails;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($mintunnelUpdateFails) || ($rate < $mintunnelUpdateFails))
        {
            $mintunnelUpdateFails = $rate;
        }
        if (!defined($maxtunnelUpdateFails) || ($rate > $maxtunnelUpdateFails))
        {
            $maxtunnelUpdateFails = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totaltunnelUpdateFails += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$opentunnelUpdateFails]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($mintunnelUpdateFails) || ($rate < $mintunnelUpdateFails))
{
    $mintunnelUpdateFails = $rate;
}
if (!defined($maxtunnelUpdateFails) || ($rate > $maxtunnelUpdateFails))
{
    $maxtunnelUpdateFails = $rate;
}
$totalPeriod += $currentPeriod;
$totaltunnelUpdateFails += $currentPdus;


printf " FSPP-Tunnel-Update-Fails-Avg:%.0f\n", ($totaltunnelUpdateFails/$totalPeriod);

if (defined $mintunnelUpdateFails)
{


    printf " FSPP-Tunnel-Update-Fails-Min:%.0f\n", $mintunnelUpdateFails;
    printf " FSPP-Tunnel-Update-Fails-Max:%.0f\n", $maxtunnelUpdateFails;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# Tunnel FSPP (Flow State Packet Processing) FSPP-Total-Packets:"
echo "#################################################################################################"
cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalPkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalPkts\"")
    {
        $totalPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltotalPkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttotalPkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltotalPkts += $currenttotalPkts;
        $currenttotalPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttotalPkts += $fields[$totalPkts];
}
my $drops = $currenttotalPkts/$currentPeriod;

$totaltotalPkts += $currenttotalPkts;


printf "Total (Tunnel FSPP- Packets):%.0f\n", ($totaltotalPkts);
'

rm -rf ~/myFile

cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalStatsMsgs = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalStatsMsgs\"")
    {
        $totalStatsMsgs = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltotalStatsMsgs;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttotalStatsMsgs/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltotalStatsMsgs += $currenttotalStatsMsgs;
        $currenttotalStatsMsgs = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttotalStatsMsgs += $fields[$totalStatsMsgs];
}
my $drops = $currenttotalStatsMsgs/$currentPeriod;

$totaltotalStatsMsgs += $currenttotalStatsMsgs;


printf "Total (Tunnel FSPP- Stats Msgs):%.0f\n", ($totaltotalStatsMsgs);
'


rm -rf ~/myFile

cat `ls -rt ./IicTunnelFsppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalTunnelErrors = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalTunnelErrors\"")
    {
        $totalTunnelErrors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltotalTunnelErrors;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttotalTunnelErrors/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltotalTunnelErrors += $currenttotalTunnelErrors;
        $currenttotalTunnelErrors = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttotalTunnelErrors += $fields[$totalTunnelErrors];
}
my $drops = $currenttotalTunnelErrors/$currentPeriod;

$totaltotalTunnelErrors += $currenttotalTunnelErrors;


printf "Total (Tunnel FSPP- Tunnel Errors):%.0f\n", ($totaltotalTunnelErrors);
'




rm -rf ./myFile
##############################################################################################################

echo "####################################################################"
echo "# RTP-ACTIVE-STREAMS"
echo "####################################################################"


cat `ls -rt ./IicRtpStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "rtpActiveStreams"  AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$rtpActiveStreams = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rtpActiveStreams\"")
    {
        $rtpActiveStreams = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentStreams = 0;
my $totalStreams;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentStreams/$currentPeriod;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalStreams += $currentStreams;
        $currentStreams = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentStreams += $fields[$rtpActiveStreams]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentStreams\n";
my $rate = $currentStreams/$currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalStreams += $currentStreams;


printf "RTP-ACTIVE-STREAMS-Avg:%.0f\n", ($totalStreams/$totalPeriod);

if (defined $minRate)
{


    printf "RTP-ACTIVE-STREAMS-Min:%.0f\n", $minRate;
        printf "RTP-ACTIVE-STREAMS-Max:%.0f\n", $maxRate;
}
'

rm -rf ./myFile
##############################################################################################################
echo "####################################################################"
echo "# RTP-ACTIVE-FLOWS"
echo "####################################################################"


cat `ls -rt ./IicRtpStats* | tail -1` | grep -v Master | perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile

##########################################################################
## Statistic: "rtpActiveFlows"  AVG
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$rtpActiveFlows = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rtpActiveFlows\"")
    {
        $rtpActiveFlows = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentFlows = 0;
my $totalFlows;
my $totalPeriod;
my $minRate;
my $maxRate;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentFlows/$currentPeriod;

        if (!defined($minRate) || ($rate < $minRate))
        {
            $minRate = $rate;
        }
        if (!defined($maxRate) || ($rate > $maxRate))
        {
            $maxRate = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalFlows += $currentFlows;
        $currentFlows = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentFlows += $fields[$rtpActiveFlows]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentFlows\n";
my $rate = $currentFlows/$currentPeriod;

if (!defined($minRate) || ($rate < $minRate))
{
    $minRate = $rate;
}
if (!defined($maxRate) || ($rate > $maxRate))
{
    $maxRate = $rate;
}
$totalPeriod += $currentPeriod;
$totalFlows += $currentFlows;


printf "RTP-ACTIVE-FLOWS-Avg:%.0f\n", ($totalFlows/$totalPeriod);

if (defined $minRate)
{


    printf "RTP-ACTIVE-FLOWS-Min:%.0f\n", $minRate;
    printf "RTP-ACTIVE-FLOWS-Max:%.0f\n", $maxRate;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# RTP-Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicRtpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rtpBadTimestamp = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rtpBadTimestamp\"")
    {
        $rtpBadTimestamp = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrtpBadTimestamp;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrtpBadTimestamp/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrtpBadTimestamp += $currentrtpBadTimestamp;
        $currentrtpBadTimestamp = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrtpBadTimestamp += $fields[$rtpBadTimestamp];
}
my $drops = $currentrtpBadTimestamp/$currentPeriod;

$totalrtpBadTimestamp += $currentrtpBadTimestamp;


printf "Total (RTP- Bad Timestamp):%.0f\n", ($totalrtpBadTimestamp);
'

rm -rf ~/myFile

cat `ls -rt ./IicRtpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rtpVbrOverflow = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rtpVbrOverflow\"")
    {
        $rtpVbrOverflow = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrtpVbrOverflow;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrtpVbrOverflow/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrtpVbrOverflow += $currentrtpVbrOverflow;
        $currentrtpVbrOverflow = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrtpVbrOverflow += $fields[$rtpVbrOverflow];
}
my $drops = $currentrtpVbrOverflow/$currentPeriod;

$totalrtpVbrOverflow += $currentrtpVbrOverflow;


printf "Total (RTP- Variable Bitrate Overflow):%.0f\n", ($totalrtpVbrOverflow);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# RTSP Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicProtoRtspStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rtspAborts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rtspAborts\"")
    {
        $rtspAborts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrtspAborts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrtspAborts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrtspAborts += $currentrtspAborts;
        $currentrtspAborts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrtspAborts += $fields[$rtspAborts];
}
my $drops = $currentrtspAborts/$currentPeriod;

$totalrtspAborts += $currentrtspAborts;


printf "Total (RTSP- Aborts):%.0f\n", ($totalrtspAborts);
'

rm -rf ~/myFile
cat `ls -rt ./IicProtoRtspStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rtspAsciiMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rtspAsciiMessages\"")
    {
        $rtspAsciiMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrtspAsciiMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrtspAsciiMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrtspAsciiMessages += $currentrtspAsciiMessages;
        $currentrtspAsciiMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrtspAsciiMessages += $fields[$rtspAsciiMessages];
}
my $drops = $currentrtspAsciiMessages/$currentPeriod;

$totalrtspAsciiMessages += $currentrtspAsciiMessages;


printf "Total (RTSP- Ascii Messages):%.0f\n", ($totalrtspAsciiMessages);
'

rm -rf ~/myFile
cat `ls -rt ./IicProtoRtspStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rtspBinaryMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rtspBinaryMessages\"")
    {
        $rtspBinaryMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrtspBinaryMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrtspBinaryMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrtspBinaryMessages += $currentrtspBinaryMessages;
        $currentrtspBinaryMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrtspBinaryMessages += $fields[$rtspBinaryMessages];
}
my $drops = $currentrtspBinaryMessages/$currentPeriod;

$totalrtspBinaryMessages += $currentrtspBinaryMessages;


printf "Total (RTSP- Binary Messages):%.0f\n", ($totalrtspBinaryMessages);
'

rm -rf ~/myFile
cat `ls -rt ./IicProtoRtspStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rtspIntoSync = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rtspIntoSync\"")
    {
        $rtspIntoSync = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrtspIntoSync;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrtspIntoSync/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrtspIntoSync += $currentrtspIntoSync;
        $currentrtspIntoSync = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrtspIntoSync += $fields[$rtspIntoSync];
}
my $drops = $currentrtspIntoSync/$currentPeriod;

$totalrtspIntoSync += $currentrtspIntoSync;


printf "Total (RTSP- Into Sync):%.0f\n", ($totalrtspIntoSync);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# PPP Statistics:"
echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##########################################################################
## Statistic: "discardedPkts" (PPP: Discarded Pkts) TOTAL
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$discardedPkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"discardedPkts\"")
    {
        $discardedPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentDropCount = 0;
my $totalDiscardedPkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentDiscardedPkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalDiscardedPkts += $currentDiscardedPkts;
        $currentDiscardedPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentDiscardedPkts += $fields[$discardedPkts];
}
my $drops = $currentDiscardedPkts/$currentPeriod;

$totalDiscardedPkts += $currentDiscardedPkts;


printf "Total (PPP- Discarded Packets):%.0f\n", ($totalDiscardedPkts);
'

rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: Loopback Buffer Allocation Failed Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "loopbackBufAllocFailed" (PPP: Loopback Buffer Allocation Failed Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$loopbackBufAllocFailed = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"loopbackBufAllocFailed\"")
    {
        $loopbackBufAllocFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalLoopbackBufAllocFailed;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentLoopbackBufAllocFailed/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalLoopbackBufAllocFailed += $currentLoopbackBufAllocFailed;
        $currentLoopbackBufAllocFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentLoopbackBufAllocFailed += $fields[$loopbackBufAllocFailed];
}
my $drops = $currentLoopbackBufAllocFailed/$currentPeriod;

$totalLoopbackBufAllocFailed += $currentLoopbackBufAllocFailed;


printf "Total (PPP- Loopback Buffer Allocation Failed) :%.0f\n", ($totalLoopbackBufAllocFailed);
'


rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: Loopback Buffer TX Failed Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "loopbackBufTxFailed" (PPP: Loopback Buffer TX Failed Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$loopbackBufTxFailed = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"loopbackBufTxFailed\"")
    {
        $loopbackBufTxFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalLoopbackBufTxFailed;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentLoopbackBufTxFailed/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalLoopbackBufTxFailed += $currentLoopbackBufTxFailed;
        $currentLoopbackBufTxFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentLoopbackBufTxFailed += $fields[$loopbackBufTxFailed];
}
my $drops = $currentLoopbackBufTxFailed/$currentPeriod;

$totalLoopbackBufTxFailed += $currentLoopbackBufTxFailed;


printf "Total (PPP- Loopback Buffer Tx Failed):%.0f\n", ($totalLoopbackBufTxFailed);
'



rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: Loopback Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "loopbackPkts" (PPP: Loopback Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$loopbackPkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"loopbackPkts\"")
    {
        $loopbackPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalLoopbackPkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentLoopbackPkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalLoopbackPkts += $currentLoopbackPkts;
        $currentLoopbackPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentLoopbackPkts += $fields[$loopbackPkts];
}
my $drops = $currentLoopbackPkts/$currentPeriod;

$totalLoopbackPkts += $currentLoopbackPkts;


printf "Total (PPP- Loopback Packets):%.0f\n", ($totalLoopbackPkts);
'


rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: maxBufferSizeExceeded Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "maxBufferSizeExceeded" (PPP: Max Buffer Size Exceeded Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$maxBufferSizeExceeded = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"maxBufferSizeExceeded\"")
    {
        $maxBufferSizeExceeded = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalMaxBufferSizeExceeded;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentMaxBufferSizeExceeded/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalMaxBufferSizeExceeded += $currentMaxBufferSizeExceeded;
        $currentMaxBufferSizeExceeded = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentMaxBufferSizeExceeded += $fields[$maxBufferSizeExceeded];
}
my $drops = $currentMaxBufferSizeExceeded/$currentPeriod;

$totalMaxBufferSizeExceeded += $currentMaxBufferSizeExceeded;


printf "Total (PPP- Max Buffer-Size Exceeded Packets):%.0f\n", ($totalMaxBufferSizeExceeded);
'


rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: reassemblyCreateFailed Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "reassemblyCreateFailed" (PPP: Max Buffer Size Exceeded Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$reassemblyCreateFailed = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"reassemblyCreateFailed\"")
    {
        $reassemblyCreateFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalReassemblyCreateFailed;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentReassemblyCreateFailed/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalReassemblyCreateFailed += $currentReassemblyCreateFailed;
        $currentReassemblyCreateFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentReassemblyCreateFailed += $fields[$reassemblyCreateFailed];
}
my $drops = $currentReassemblyCreateFailed/$currentPeriod;

$totalReassemblyCreateFailed += $currentReassemblyCreateFailed;


printf "Total (PPP- Reassembly Create Failed Packets):%.0f\n", ($totalReassemblyCreateFailed);
'



rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: totalCompletePkts Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "totalCompletePkts" (PPP: Max Buffer Size Exceeded Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalCompletePkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalCompletePkts\"")
    {
        $totalCompletePkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalTotalCompletePkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentTotalCompletePkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalTotalCompletePkts += $currentTotalCompletePkts;
        $currentTotalCompletePkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentTotalCompletePkts += $fields[$totalCompletePkts];
}
my $drops = $currentTotalCompletePkts/$currentPeriod;

$totalTotalCompletePkts += $currentTotalCompletePkts;


printf "Total (PPP- Total Complete Packets):%.0f\n", ($totalTotalCompletePkts);
'


rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: totalFragments Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "totalFragments" (PPP: Max Buffer Size Exceeded Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalFragments = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalFragments\"")
    {
        $totalFragments = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalTotalFragments;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentTotalFragments/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalTotalFragments += $currentTotalFragments;
        $currentTotalFragments = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentTotalFragments += $fields[$totalFragments];
}
my $drops = $currentTotalFragments/$currentPeriod;

$totalTotalFragments += $currentTotalFragments;


printf "Total (PPP- Total Fragments ):%.0f\n", ($totalTotalFragments);
'

rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: totalSyntheticPkts Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "totalSyntheticPkts" (PPP: Max Buffer Size Exceeded Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$totalSyntheticPkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"totalSyntheticPkts\"")
    {
        $totalSyntheticPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalTotalSyntheticPkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentTotalSyntheticPkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalTotalSyntheticPkts += $currentTotalSyntheticPkts;
        $currentTotalSyntheticPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentTotalSyntheticPkts += $fields[$totalSyntheticPkts];
}
my $drops = $currentTotalSyntheticPkts/$currentPeriod;

$totalTotalSyntheticPkts += $currentTotalSyntheticPkts;


printf "Total (PPP- Total Synthetic Packets ):%.0f\n", ($totalTotalSyntheticPkts);
'


rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: unClassifiedPkts Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "unClassifiedPkts" (PPP: UnClassified Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$unClassifiedPkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"unClassifiedPkts\"")
    {
        $unClassifiedPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalUnClassifiedPkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentUnClassifiedPkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalUnClassifiedPkts += $currentUnClassifiedPkts;
        $currentUnClassifiedPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentUnClassifiedPkts += $fields[$unClassifiedPkts];
}
my $drops = $currentUnClassifiedPkts/$currentPeriod;

$totalUnClassifiedPkts += $currentUnClassifiedPkts;


printf "Total (PPP- Total UnClassified Packets ):%.0f\n", ($totalUnClassifiedPkts);
'

rm -rf ~/myFile
# echo "#################################################################################################"
# echo "# PPP: unsupportedType Packets"
# echo "#################################################################################################"


cat `ls -rt ./IicPppStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "unsupportedType" (PPP: unsupportedType Packets) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$unsupportedType = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"unsupportedType\"")
    {
        $unsupportedType = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
if (! (defined($unsupportedType) && defined ($period) && defined($time)))
{
    die("Could not find some field");
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalUnsupportedType;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentUnsupportedType/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalUnsupportedType += $currentUnsupportedType;
        $currentUnsupportedType = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentUnsupportedType += $fields[$unsupportedType];
}
my $drops = $currentUnsupportedType/$currentPeriod;

$totalUnsupportedType += $currentUnsupportedType;


printf "Total (PPP- Total UnsupportedType Packets ) :%.0f\n", ($totalUnsupportedType);
'
rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP Defrag: Active-Defrags"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenactiveDefrags"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$activeDefrags = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"activeDefrags\"")
    {
        $openactiveDefrags = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalactiveDefrags;
my $totalPeriod;
my $minactiveDefrags;
my $maxactiveDefrags;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minactiveDefrags) || ($rate < $minactiveDefrags))
        {
            $minactiveDefrags = $rate;
        }
        if (!defined($maxactiveDefrags) || ($rate > $maxactiveDefrags))
        {
            $maxactiveDefrags = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalactiveDefrags += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openactiveDefrags]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minactiveDefrags) || ($rate < $minactiveDefrags))
{
    $minactiveDefrags = $rate;
}
if (!defined($maxactiveDefrags) || ($rate > $maxactiveDefrags))
{
    $maxactiveDefrags = $rate;
}
$totalPeriod += $currentPeriod;
$totalactiveDefrags += $currentPdus;


printf "Active-Defrags-Avg:%.0f\n", ($totalactiveDefrags/$totalPeriod);

if (defined $minactiveDefrags)
{


    printf "Active-Defrags-Min:%.0f\n", $minactiveDefrags;
        printf "Active-Defrags-Max:%.0f\n", $maxactiveDefrags;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-Aged-Out-Contexts"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenagedOutContexts"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$agedOutContexts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"agedOutContexts\"")
    {
        $openagedOutContexts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalagedOutContexts;
my $totalPeriod;
my $minagedOutContexts;
my $maxagedOutContexts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minagedOutContexts) || ($rate < $minagedOutContexts))
        {
            $minagedOutContexts = $rate;
        }
        if (!defined($maxagedOutContexts) || ($rate > $maxagedOutContexts))
        {
            $maxagedOutContexts = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalagedOutContexts += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openagedOutContexts]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minagedOutContexts) || ($rate < $minagedOutContexts))
{
    $minagedOutContexts = $rate;
}
if (!defined($maxagedOutContexts) || ($rate > $maxagedOutContexts))
{
    $maxagedOutContexts = $rate;
}
$totalPeriod += $currentPeriod;
$totalagedOutContexts += $currentPdus;


printf "IP-Defrag-Aged-Out-Contexts-Avg:%.0f\n", ($totalagedOutContexts/$totalPeriod);

if (defined $minagedOutContexts)
{


    printf "IP-Defrag-Aged-Out-Contexts-Min:%.0f\n", $minagedOutContexts;
        printf "IP-Defrag-Aged-Out-Contexts-Max:%.0f\n", $maxagedOutContexts;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-Buffers-In-Use"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenbuffersInUse"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$buffersInUse = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"buffersInUse\"")
    {
        $openbuffersInUse = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalbuffersInUse;
my $totalPeriod;
my $minbuffersInUse;
my $maxbuffersInUse;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minbuffersInUse) || ($rate < $minbuffersInUse))
        {
            $minbuffersInUse = $rate;
        }
        if (!defined($maxbuffersInUse) || ($rate > $maxbuffersInUse))
        {
            $maxbuffersInUse = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalbuffersInUse += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openbuffersInUse]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minbuffersInUse) || ($rate < $minbuffersInUse))
{
    $minbuffersInUse = $rate;
}
if (!defined($maxbuffersInUse) || ($rate > $maxbuffersInUse))
{
    $maxbuffersInUse = $rate;
}
$totalPeriod += $currentPeriod;
$totalbuffersInUse += $currentPdus;


printf "IP-Defrag-Buffers-In-Use-Avg:%.0f\n", ($totalbuffersInUse/$totalPeriod);

if (defined $minbuffersInUse)
{


    printf "IP-Defrag-Buffers-In-Use-Min:%.0f\n", $minbuffersInUse;
    printf "IP-Defrag-Buffers-In-Use-Max:%.0f\n", $maxbuffersInUse;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-Frag-List-Insert-Fails"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenfragListInsertFails"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$fragListInsertFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"fragListInsertFails\"")
    {
        $openfragListInsertFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalfragListInsertFails;
my $totalPeriod;
my $minfragListInsertFails;
my $maxfragListInsertFails;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minfragListInsertFails) || ($rate < $minfragListInsertFails))
        {
            $minfragListInsertFails = $rate;
        }
        if (!defined($maxfragListInsertFails) || ($rate > $maxfragListInsertFails))
        {
            $maxfragListInsertFails = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalfragListInsertFails += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openfragListInsertFails]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minfragListInsertFails) || ($rate < $minfragListInsertFails))
{
    $minfragListInsertFails = $rate;
}
if (!defined($maxfragListInsertFails) || ($rate > $maxfragListInsertFails))
{
    $maxfragListInsertFails = $rate;
}
$totalPeriod += $currentPeriod;
$totalfragListInsertFails += $currentPdus;


printf "IP-Defrag-Frag-List-Insert-Fails-Avg:%.0f\n", ($totalfragListInsertFails/$totalPeriod);

if (defined $minfragListInsertFails)
{


    printf "IP-Defrag-Frag-List-Insert-Fails-Min:%.0f\n", $minfragListInsertFails;
    printf "IP-Defrag-Frag-List-Insert-Fails-Max:%.0f\n", $maxfragListInsertFails;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-Hash-Table-Insert-Fails"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenhashTableInsertFails"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$hashTableInsertFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"hashTableInsertFails\"")
    {
        $openhashTableInsertFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalhashTableInsertFails;
my $totalPeriod;
my $minhashTableInsertFails;
my $maxhashTableInsertFails;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minhashTableInsertFails) || ($rate < $minhashTableInsertFails))
        {
            $minhashTableInsertFails = $rate;
        }
        if (!defined($maxhashTableInsertFails) || ($rate > $maxhashTableInsertFails))
        {
            $maxhashTableInsertFails = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalhashTableInsertFails += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openhashTableInsertFails]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minhashTableInsertFails) || ($rate < $minhashTableInsertFails))
{
    $minhashTableInsertFails = $rate;
}
if (!defined($maxhashTableInsertFails) || ($rate > $maxhashTableInsertFails))
{
    $maxhashTableInsertFails = $rate;
}
$totalPeriod += $currentPeriod;
$totalhashTableInsertFails += $currentPdus;


printf "IP-Defrag-Hash-Table-Insert-Fails-Avg:%.0f\n", ($totalhashTableInsertFails/$totalPeriod);

if (defined $minhashTableInsertFails)
{


    printf "IP-Defrag-Hash-Table-Insert-Fails-Min:%.0f\n", $minhashTableInsertFails;
    printf "IP-Defrag-Hash-Table-Insert-Fails-Max:%.0f\n", $maxhashTableInsertFails;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-IP-Frag-Aborts"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenipFragAborts"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$ipFragAborts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ipFragAborts\"")
    {
        $openipFragAborts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalipFragAborts;
my $totalPeriod;
my $minipFragAborts;
my $maxipFragAborts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minipFragAborts) || ($rate < $minipFragAborts))
        {
            $minipFragAborts = $rate;
        }
        if (!defined($maxipFragAborts) || ($rate > $maxipFragAborts))
        {
            $maxipFragAborts = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalipFragAborts += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openipFragAborts]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minipFragAborts) || ($rate < $minipFragAborts))
{
    $minipFragAborts = $rate;
}
if (!defined($maxipFragAborts) || ($rate > $maxipFragAborts))
{
    $maxipFragAborts = $rate;
}
$totalPeriod += $currentPeriod;
$totalipFragAborts += $currentPdus;


printf "IP-Defrag-IP-Frag-Aborts-Avg:%.0f\n", ($totalipFragAborts/$totalPeriod);

if (defined $minipFragAborts)
{


    printf "IP-Defrag-IP-Frag-Aborts-Min:%.0f\n", $minipFragAborts;
    printf "IP-Defrag-IP-Frag-Aborts-Max:%.0f\n", $maxipFragAborts;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-IP Fragments"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenipFragments"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$ipFragments = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ipFragments\"")
    {
        $openipFragments = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalipFragments;
my $totalPeriod;
my $minipFragments;
my $maxipFragments;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minipFragments) || ($rate < $minipFragments))
        {
            $minipFragments = $rate;
        }
        if (!defined($maxipFragments) || ($rate > $maxipFragments))
        {
            $maxipFragments = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalipFragments += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openipFragments]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minipFragments) || ($rate < $minipFragments))
{
    $minipFragments = $rate;
}
if (!defined($maxipFragments) || ($rate > $maxipFragments))
{
    $maxipFragments = $rate;
}
$totalPeriod += $currentPeriod;
$totalipFragments += $currentPdus;


printf "IP-Defrag-IP Fragments-Avg:%.0f\n", ($totalipFragments/$totalPeriod);
if (defined $minipFragments)
{


    printf "IP-Defrag-IP Fragments-Min:%.0f\n", $minipFragments;
    printf "IP-Defrag-IP Fragments-Max:%.0f\n", $maxipFragments;
}
'


totalFrags=0
##########################################################################
## Statistic: "totalOpenipFragments"
##########################################################################
totalFrags=`cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$ipFragments = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ipFragments\"")
    {
        $openipFragments = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalipFragments;
my $totalPeriod;
my $minipFragments;
my $maxipFragments;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minipFragments) || ($rate < $minipFragments))
        {
            $minipFragments = $rate;
        }
        if (!defined($maxipFragments) || ($rate > $maxipFragments))
        {
            $maxipFragments = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalipFragments += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openipFragments]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minipFragments) || ($rate < $minipFragments))
{
    $minipFragments = $rate;
}
if (!defined($maxipFragments) || ($rate > $maxipFragments))
{
    $maxipFragments = $rate;
}
$totalPeriod += $currentPeriod;
$totalipFragments += $currentPdus;


printf "IP-Defrag-IP Fragments-Avg:%.0f\n", ($totalipFragments/$totalPeriod/300);
#printf "IP-Defrag-IP Fragments-Avg:%.0f\n", ($totalipFragments/300);
'`


echo "#################################################################################################"
echo "# Percentage of Fragmented Packets"
echo "#################################################################################################"
echo $totalPkts;
echo $totalFrags;
fragTotal=`echo $totalFrags | awk -F: '/IP-Defrag-IP Fragments-Avg/ {print $2}'`
packetsPerSecond=`echo $totalPkts | awk -F: '/PACKETS-PER-SECOND-IIC-Avg/ {print $2}'`
fragPercentage=$(echo "scale=5; $fragTotal / $packetsPerSecond * 100" | bc)
echo "Percentage Of Fragmentation(%):"$fragPercentage






rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-IP-Packet-Aborts"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenipPktAborts"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$ipPktAborts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ipPktAborts\"")
    {
        $openipPktAborts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalipPktAborts;
my $totalPeriod;
my $minipPktAborts;
my $maxipPktAborts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minipPktAborts) || ($rate < $minipPktAborts))
        {
            $minipPktAborts = $rate;
        }
        if (!defined($maxipPktAborts) || ($rate > $maxipPktAborts))
        {
            $maxipPktAborts = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalipPktAborts += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openipPktAborts]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minipPktAborts) || ($rate < $minipPktAborts))
{
    $minipPktAborts = $rate;
}
if (!defined($maxipPktAborts) || ($rate > $maxipPktAborts))
{
    $maxipPktAborts = $rate;
}
$totalPeriod += $currentPeriod;
$totalipPktAborts += $currentPdus;


printf "IP-Defrag-IP-Packet-Aborts-Avg:%.0f\n", ($totalipPktAborts/$totalPeriod);

if (defined $minipPktAborts)
{


    printf "IP-Defrag-IP-Packet-Aborts-Min:%.0f\n", $minipPktAborts;
    printf "IP-Defrag-IP-Packet-Aborts-Max:%.0f\n", $maxipPktAborts;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-Reallocated-Contexts"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenreallocatedContexts"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$reallocatedContexts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"reallocatedContexts\"")
    {
        $openreallocatedContexts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalreallocatedContexts;
my $totalPeriod;
my $minreallocatedContexts;
my $maxreallocatedContexts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minreallocatedContexts) || ($rate < $minreallocatedContexts))
        {
            $minreallocatedContexts = $rate;
        }
        if (!defined($maxreallocatedContexts) || ($rate > $maxreallocatedContexts))
        {
            $maxreallocatedContexts = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalreallocatedContexts += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openreallocatedContexts]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minreallocatedContexts) || ($rate < $minreallocatedContexts))
{
    $minreallocatedContexts = $rate;
}
if (!defined($maxreallocatedContexts) || ($rate > $maxreallocatedContexts))
{
    $maxreallocatedContexts = $rate;
}
$totalPeriod += $currentPeriod;
$totalreallocatedContexts += $currentPdus;


printf "IP-Defrag-Reallocated-Contexts-Avg:%.0f\n", ($totalreallocatedContexts/$totalPeriod);

if (defined $minreallocatedContexts)
{


    printf "IP-Defrag-Reallocated-Contexts-Min:%.0f\n", $minreallocatedContexts;
    printf "IP-Defrag-Reallocated-Contexts-Max:%.0f\n", $maxreallocatedContexts;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-Reallocated-No-Buffers"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpenreallocatedNoBuffers"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$reallocatedNoBuffers = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"reallocatedNoBuffers\"")
    {
        $openreallocatedNoBuffers = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalreallocatedNoBuffers;
my $totalPeriod;
my $minreallocatedNoBuffers;
my $maxreallocatedNoBuffers;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minreallocatedNoBuffers) || ($rate < $minreallocatedNoBuffers))
        {
            $minreallocatedNoBuffers = $rate;
        }
        if (!defined($maxreallocatedNoBuffers) || ($rate > $maxreallocatedNoBuffers))
        {
            $maxreallocatedNoBuffers = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalreallocatedNoBuffers += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$openreallocatedNoBuffers]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minreallocatedNoBuffers) || ($rate < $minreallocatedNoBuffers))
{
    $minreallocatedNoBuffers = $rate;
}
if (!defined($maxreallocatedNoBuffers) || ($rate > $maxreallocatedNoBuffers))
{
    $maxreallocatedNoBuffers = $rate;
}
$totalPeriod += $currentPeriod;
$totalreallocatedNoBuffers += $currentPdus;


printf "IP-Defrag-Reallocated-No-Buffers-Avg:%.0f\n", ($totalreallocatedNoBuffers/$totalPeriod);

if (defined $minreallocatedNoBuffers)
{


    printf "IP-Defrag-Reallocated-No-Buffers-Min:%.0f\n", $minreallocatedNoBuffers;
    printf "IP-Defrag-Reallocated-No-Buffers-Max:%.0f\n", $maxreallocatedNoBuffers;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-Successful-Defrags"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpensuccessfulDefrags"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$successfulDefrags = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"successfulDefrags\"")
    {
        $opensuccessfulDefrags = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totalsuccessfulDefrags;
my $totalPeriod;
my $minsuccessfulDefrags;
my $maxsuccessfulDefrags;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($minsuccessfulDefrags) || ($rate < $minsuccessfulDefrags))
        {
            $minsuccessfulDefrags = $rate;
        }
        if (!defined($maxsuccessfulDefrags) || ($rate > $maxsuccessfulDefrags))
        {
            $maxsuccessfulDefrags = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totalsuccessfulDefrags += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$opensuccessfulDefrags]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($minsuccessfulDefrags) || ($rate < $minsuccessfulDefrags))
{
    $minsuccessfulDefrags = $rate;
}
if (!defined($maxsuccessfulDefrags) || ($rate > $maxsuccessfulDefrags))
{
    $maxsuccessfulDefrags = $rate;
}
$totalPeriod += $currentPeriod;
$totalsuccessfulDefrags += $currentPdus;


printf "IP-Defrag-Successful-Defrags-Avg:%.0f\n", ($totalsuccessfulDefrags/$totalPeriod);

if (defined $minsuccessfulDefrags)
{


    printf "IP-Defrag-Successful-Defrags-Min:%.0f\n", $minsuccessfulDefrags;
    printf "IP-Defrag-Successful-Defrags-Max:%.0f\n", $maxsuccessfulDefrags;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# IP-Defrag-Too-Many-Fragments"
echo "#################################################################################################"
cat `ls -rt ./IicIpdefragStats* | tail -1`| perl -e '

$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" > ~/myFile


##########################################################################
## Statistic: "totalOpentooManyFragments"
##########################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
#$tooManyFragments = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"tooManyFragments\"")
    {
        $opentooManyFragments = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
my $currentPdus = 0;
my $totaltooManyFragments;
my $totalPeriod;
my $mintooManyFragments;
my $maxtooManyFragments;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $rate = $currentPdus/$currentPeriod;

        if (!defined($mintooManyFragments) || ($rate < $mintooManyFragments))
        {
            $mintooManyFragments = $rate;
        }
        if (!defined($maxtooManyFragments) || ($rate > $maxtooManyFragments))
        {
            $maxtooManyFragments = $rate;
        }
        $totalPeriod += $currentPeriod;
        $totaltooManyFragments += $currentPdus;
        $currentPdus = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentPdus += $fields[$opentooManyFragments]*$currentPeriod;
}
#print "$currentTime,$currentPeriod,$currentPdus\n";
my $rate = $currentPdus/$currentPeriod;

if (!defined($mintooManyFragments) || ($rate < $mintooManyFragments))
{
    $mintooManyFragments = $rate;
}
if (!defined($maxtooManyFragments) || ($rate > $maxtooManyFragments))
{
    $maxtooManyFragments = $rate;
}
$totalPeriod += $currentPeriod;
$totaltooManyFragments += $currentPdus;


printf "IP-Defrag-Too-Many-Fragments-Avg:%.0f\n", ($totaltooManyFragments/$totalPeriod);

if (defined $mintooManyFragments)
{


    printf "IP-Defrag-Too-Many-Fragments-Min:%.0f\n", $mintooManyFragments;
    printf "IP-Defrag-Too-Many-Fragments-Max:%.0f\n", $maxtooManyFragments;
}
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# A11CDMA Statistics:"
echo "#################################################################################################"


cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile
##############################################################################################
## Statistic: "a11CdmaAddFailed" (A11CDMA Add Failed) TOTAL
##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$a11CdmaAddFailed = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"a11CdmaAddFailed\"")
    {
        $a11CdmaAddFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalA11CdmaAddFailed;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentA11CdmaAddFailed/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalA11CdmaAddFailed += $currentA11CdmaAddFailed;
        $currentA11CdmaAddFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentA11CdmaAddFailed += $fields[$a11CdmaAddFailed];
}
my $drops = $currentA11CdmaAddFailed/$currentPeriod;

$totalA11CdmaAddFailed += $currentA11CdmaAddFailed;


printf "Total (A11CDMA- Add Failed ):%.0f\n", ($totalA11CdmaAddFailed);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$a11DroppedMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"a11DroppedMessages\"")
    {
        $a11DroppedMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totala11DroppedMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenta11DroppedMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totala11DroppedMessages += $currenta11DroppedMessages;
        $currenta11DroppedMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenta11DroppedMessages += $fields[$a11DroppedMessages];
}
my $drops = $currenta11DroppedMessages/$currentPeriod;

$totala11DroppedMessages += $currenta11DroppedMessages;


printf "Total (A11- Dropped Messages ):%.0f\n", ($totala11DroppedMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$a11MaxSO67GreKeysExceeded = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"a11MaxSO67GreKeysExceeded\"")
    {
        $a11MaxSO67GreKeysExceeded = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totala11MaxSO67GreKeysExceeded;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenta11MaxSO67GreKeysExceeded/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totala11MaxSO67GreKeysExceeded += $currenta11MaxSO67GreKeysExceeded;
        $currenta11MaxSO67GreKeysExceeded = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenta11MaxSO67GreKeysExceeded += $fields[$a11MaxSO67GreKeysExceeded];
}
my $drops = $currenta11MaxSO67GreKeysExceeded/$currentPeriod;

$totala11MaxSO67GreKeysExceeded += $currenta11MaxSO67GreKeysExceeded;


printf "Total (A11- Max GRE Keys Exceeded):%.0f\n", ($totala11MaxSO67GreKeysExceeded);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$a11Messages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"a11Messages\"")
    {
        $a11Messages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totala11Messages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenta11Messages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totala11Messages += $currenta11Messages;
        $currenta11Messages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenta11Messages += $fields[$a11Messages];
}
my $drops = $currenta11Messages/$currentPeriod;

$totala11Messages += $currenta11Messages;


printf "Total (A11- A11 Messages):%.0f\n", ($totala11Messages);
'


rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaAddGREFail = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaAddGREFail\"")
    {
        $cdmaAddGREFail = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaAddGREFail;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaAddGREFail/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaAddGREFail += $currentcdmaAddGREFail;
        $currentcdmaAddGREFail = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaAddGREFail += $fields[$cdmaAddGREFail];
}
my $drops = $currentcdmaAddGREFail/$currentPeriod;

$totalcdmaAddGREFail += $currentcdmaAddGREFail;


printf "Total (A11CDMA- CDMA Add GRE Fail):%.0f\n", ($totalcdmaAddGREFail);
'


rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaAddMasterGREFail = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaAddMasterGREFail\"")
    {
        $cdmaAddMasterGREFail = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaAddMasterGREFail;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaAddMasterGREFail/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaAddMasterGREFail += $currentcdmaAddMasterGREFail;
        $currentcdmaAddMasterGREFail = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaAddMasterGREFail += $fields[$cdmaAddMasterGREFail];
}
my $drops = $currentcdmaAddMasterGREFail/$currentPeriod;

$totalcdmaAddMasterGREFail += $currentcdmaAddMasterGREFail;


printf "Total (A11CDMA- CDMA Add Master GRE Fail):%.0f\n", ($totalcdmaAddMasterGREFail);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaAddSessionFail = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaAddSessionFail\"")
    {
        $cdmaAddSessionFail = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaAddSessionFail;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaAddSessionFail/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaAddSessionFail += $currentcdmaAddSessionFail;
        $currentcdmaAddSessionFail = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaAddSessionFail += $fields[$cdmaAddSessionFail];
}
my $drops = $currentcdmaAddSessionFail/$currentPeriod;

$totalcdmaAddSessionFail += $currentcdmaAddSessionFail;


printf "Total (A11CDMA- CDMA Add Session Fail):%.0f\n", ($totalcdmaAddSessionFail);
'


rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaSearch = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaSearch\"")
    {
        $cdmaSearch = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaSearch;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaSearch/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaSearch += $currentcdmaSearch;
        $currentcdmaSearch = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaSearch += $fields[$cdmaSearch];
}
my $drops = $currentcdmaSearch/$currentPeriod;

$totalcdmaSearch += $currentcdmaSearch;


printf "Total (A11CDMA- CDMA Search):%.0f\n", ($totalcdmaSearch);
'


rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaSearchFail = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaSearchFail\"")
    {
        $cdmaSearchFail = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaSearchFail;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaSearchFail/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaSearchFail += $currentcdmaSearchFail;
        $currentcdmaSearchFail = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaSearchFail += $fields[$cdmaSearchFail];
}
my $drops = $currentcdmaSearchFail/$currentPeriod;

$totalcdmaSearchFail += $currentcdmaSearchFail;


printf "Total (A11CDMA- CDMA Search Fail):%.0f\n", ($totalcdmaSearchFail);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaSessionsAdded = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaSessionsAdded\"")
    {
        $cdmaSessionsAdded = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaSessionsAdded;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaSessionsAdded/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaSessionsAdded += $currentcdmaSessionsAdded;
        $currentcdmaSessionsAdded = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaSessionsAdded += $fields[$cdmaSessionsAdded];
}
my $drops = $currentcdmaSessionsAdded/$currentPeriod;

$totalcdmaSessionsAdded += $currentcdmaSessionsAdded;


printf "Total (A11CDMA- CDMA Sessions Added):%.0f\n", ($totalcdmaSessionsAdded);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaSessionsDeleted = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaSessionsDeleted\"")
    {
        $cdmaSessionsDeleted = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaSessionsDeleted;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaSessionsDeleted/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaSessionsDeleted += $currentcdmaSessionsDeleted;
        $currentcdmaSessionsDeleted = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaSessionsDeleted += $fields[$cdmaSessionsDeleted];
}
my $drops = $currentcdmaSessionsDeleted/$currentPeriod;

$totalcdmaSessionsDeleted += $currentcdmaSessionsDeleted;


printf "Total (A11CDMA- CDMA Sessions Deleted):%.0f\n", ($totalcdmaSessionsDeleted);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaTimerStartErrors = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaTimerStartErrors\"")
    {
        $cdmaTimerStartErrors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaTimerStartErrors;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaTimerStartErrors/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaTimerStartErrors += $currentcdmaTimerStartErrors;
        $currentcdmaTimerStartErrors = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaTimerStartErrors += $fields[$cdmaTimerStartErrors];
}
my $drops = $currentcdmaTimerStartErrors/$currentPeriod;

$totalcdmaTimerStartErrors += $currentcdmaTimerStartErrors;


printf "Total (A11CDMA- CDMA Timer Start Errors):%.0f\n", ($totalcdmaTimerStartErrors);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaTunnelsAdded = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaTunnelsAdded\"")
    {
        $cdmaTunnelsAdded = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaTunnelsAdded;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaTunnelsAdded/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaTunnelsAdded += $currentcdmaTunnelsAdded;
        $currentcdmaTunnelsAdded = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaTunnelsAdded += $fields[$cdmaTunnelsAdded];
}
my $drops = $currentcdmaTunnelsAdded/$currentPeriod;

$totalcdmaTunnelsAdded += $currentcdmaTunnelsAdded;


printf "Total (A11CDMA- CDMA Tunnels Added):%.0f\n", ($totalcdmaTunnelsAdded);
'


rm -rf ~/myFile

cat `ls -rt ./IicProtoA11cdmaStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$cdmaTunnelsDeleted = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"cdmaTunnelsDeleted\"")
    {
        $cdmaTunnelsDeleted = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalcdmaTunnelsDeleted;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentcdmaTunnelsDeleted/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalcdmaTunnelsDeleted += $currentcdmaTunnelsDeleted;
        $currentcdmaTunnelsDeleted = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentcdmaTunnelsDeleted += $fields[$cdmaTunnelsDeleted];
}
my $drops = $currentcdmaTunnelsDeleted/$currentPeriod;

$totalcdmaTunnelsDeleted += $currentcdmaTunnelsDeleted;


printf "Total (A11CDMA- CDMA Tunnels Deleted):%.0f\n", ($totalcdmaTunnelsDeleted);
'


rm -rf ~/myFile
echo "#################################################################################################"
echo "# GTP Control Plane Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$abortedSessions = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"abortedSessions\"")
    {
        $abortedSessions = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalabortedSessions;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentabortedSessions/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalabortedSessions += $currentabortedSessions;
        $currentabortedSessions = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentabortedSessions += $fields[$abortedSessions];
}
my $drops = $currentabortedSessions/$currentPeriod;

$totalabortedSessions += $currentabortedSessions;


printf "Total (GTPC- Aborted Sessions):%.0f\n", ($totalabortedSessions);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$lookupAdds = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"lookupAdds\"")
    {
        $lookupAdds = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totallookupAdds;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentlookupAdds/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totallookupAdds += $currentlookupAdds;
        $currentlookupAdds = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentlookupAdds += $fields[$lookupAdds];
}
my $drops = $currentlookupAdds/$currentPeriod;

$totallookupAdds += $currentlookupAdds;


printf "Total (GTPC- Lookup Adds):%.0f\n", ($totallookupAdds);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$lookupInsertFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"lookupInsertFails\"")
    {
        $lookupInsertFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totallookupInsertFails;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentlookupInsertFails/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totallookupInsertFails += $currentlookupInsertFails;
        $currentlookupInsertFails = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentlookupInsertFails += $fields[$lookupInsertFails];
}
my $drops = $currentlookupInsertFails/$currentPeriod;

$totallookupInsertFails += $currentlookupInsertFails;


printf "Total (GTPC- Lookup Insert Fails):%.0f\n", ($totallookupInsertFails);
'


rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$lookupRemoves = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"lookupRemoves\"")
    {
        $lookupRemoves = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totallookupRemoves;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentlookupRemoves/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totallookupRemoves += $currentlookupRemoves;
        $currentlookupRemoves = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentlookupRemoves += $fields[$lookupRemoves];
}
my $drops = $currentlookupRemoves/$currentPeriod;

$totallookupRemoves += $currentlookupRemoves;


printf "Total (GTPC- Lookup Removes):%.0f\n", ($totallookupRemoves);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numGsnIdAllocFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numGsnIdAllocFails\"")
    {
        $numGsnIdAllocFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumGsnIdAllocFails;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumGsnIdAllocFails/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumGsnIdAllocFails += $currentnumGsnIdAllocFails;
        $currentnumGsnIdAllocFails = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumGsnIdAllocFails += $fields[$numGsnIdAllocFails];
}
my $drops = $currentnumGsnIdAllocFails/$currentPeriod;

$totalnumGsnIdAllocFails += $currentnumGsnIdAllocFails;


printf "Total (GTPC- Number of GsnId Allocation Fails):%.0f\n", ($totalnumGsnIdAllocFails);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numGsnIds = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numGsnIds\"")
    {
        $numGsnIds = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumGsnIds;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumGsnIds/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumGsnIds += $currentnumGsnIds;
        $currentnumGsnIds = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumGsnIds += $fields[$numGsnIds];
}
my $drops = $currentnumGsnIds/$currentPeriod;

$totalnumGsnIds += $currentnumGsnIds;


printf "Total (GTPC- Number of GsnIds):%.0f\n", ($totalnumGsnIds);
'


rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$seqLookupAddFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"seqLookupAddFails\"")
    {
        $seqLookupAddFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalseqLookupAddFails;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentseqLookupAddFails/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalseqLookupAddFails += $currentseqLookupAddFails;
        $currentseqLookupAddFails = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentseqLookupAddFails += $fields[$seqLookupAddFails];
}
my $drops = $currentseqLookupAddFails/$currentPeriod;

$totalseqLookupAddFails += $currentseqLookupAddFails;


printf "Total (GTPC- SequenceLookupAdd Fails):%.0f\n", ($totalseqLookupAddFails);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$seqLookupAdds = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"seqLookupAdds\"")
    {
        $seqLookupAdds = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalseqLookupAdds;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentseqLookupAdds/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalseqLookupAdds += $currentseqLookupAdds;
        $currentseqLookupAdds = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentseqLookupAdds += $fields[$seqLookupAdds];
}
my $drops = $currentseqLookupAdds/$currentPeriod;

$totalseqLookupAdds += $currentseqLookupAdds;


printf "Total (GTPC- SequenceLookupAdds):%.0f\n", ($totalseqLookupAdds);
'


rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$seqLookupInsertFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"seqLookupInsertFails\"")
    {
        $seqLookupInsertFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalseqLookupInsertFails;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentseqLookupInsertFails/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalseqLookupInsertFails += $currentseqLookupInsertFails;
        $currentseqLookupInsertFails = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentseqLookupInsertFails += $fields[$seqLookupInsertFails];
}
my $drops = $currentseqLookupInsertFails/$currentPeriod;

$totalseqLookupInsertFails += $currentseqLookupInsertFails;


printf "Total (GTPC- SequenceLookupInsert Fails):%.0f\n", ($totalseqLookupInsertFails);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$seqLookupRemoves = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"seqLookupRemoves\"")
    {
        $seqLookupRemoves = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalseqLookupRemoves;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentseqLookupRemoves/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalseqLookupRemoves += $currentseqLookupRemoves;
        $currentseqLookupRemoves = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentseqLookupRemoves += $fields[$seqLookupRemoves];
}
my $drops = $currentseqLookupRemoves/$currentPeriod;

$totalseqLookupRemoves += $currentseqLookupRemoves;


printf "Total (GTPC- SequenceLookupRemoves):%.0f\n", ($totalseqLookupRemoves);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sessionAllocs = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sessionAllocs\"")
    {
        $sessionAllocs = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsessionAllocs;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsessionAllocs/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsessionAllocs += $currentsessionAllocs;
        $currentsessionAllocs = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsessionAllocs += $fields[$sessionAllocs];
}
my $drops = $currentsessionAllocs/$currentPeriod;

$totalsessionAllocs += $currentsessionAllocs;


printf "Total (GTPC- Session Allocations):%.0f\n", ($totalsessionAllocs);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sessionAllocsFailed = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sessionAllocsFailed\"")
    {
        $sessionAllocsFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsessionAllocsFailed;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsessionAllocsFailed/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsessionAllocsFailed += $currentsessionAllocsFailed;
        $currentsessionAllocsFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsessionAllocsFailed += $fields[$sessionAllocsFailed];
}
my $drops = $currentsessionAllocsFailed/$currentPeriod;

$totalsessionAllocsFailed += $currentsessionAllocsFailed;


printf "Total (GTPC- Session Allocations Failed):%.0f\n", ($totalsessionAllocsFailed);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sessionFrees = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sessionFrees\"")
    {
        $sessionFrees = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsessionFrees;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsessionFrees/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsessionFrees += $currentsessionFrees;
        $currentsessionFrees = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsessionFrees += $fields[$sessionFrees];
}
my $drops = $currentsessionFrees/$currentPeriod;

$totalsessionFrees += $currentsessionFrees;


printf "Total (GTPC- Session Frees):%.0f\n", ($totalsessionFrees);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$timerFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"timerFailures\"")
    {
        $timerFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltimerFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttimerFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltimerFailures += $currenttimerFailures;
        $currenttimerFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttimerFailures += $fields[$timerFailures];
}
my $drops = $currenttimerFailures/$currentPeriod;

$totaltimerFailures += $currenttimerFailures;


printf "Total (GTPC- Timer Failures):%.0f\n", ($totaltimerFailures);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$transAllocFails = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"transAllocFails\"")
    {
        $transAllocFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltransAllocFails;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttransAllocFails/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltransAllocFails += $currenttransAllocFails;
        $currenttransAllocFails = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttransAllocFails += $fields[$transAllocFails];
}
my $drops = $currenttransAllocFails/$currentPeriod;

$totaltransAllocFails += $currenttransAllocFails;


printf "Total (GTPC- Transaction Allocation Fails):%.0f\n", ($totaltransAllocFails);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$transEndedSuccess = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"transEndedSuccess\"")
    {
        $transEndedSuccess = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltransEndedSuccess;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttransEndedSuccess/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltransEndedSuccess += $currenttransEndedSuccess;
        $currenttransEndedSuccess = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttransEndedSuccess += $fields[$transEndedSuccess];
}
my $drops = $currenttransEndedSuccess/$currentPeriod;

$totaltransEndedSuccess += $currenttransEndedSuccess;


printf "Total (GTPC- Transaction Ended Success):%.0f\n", ($totaltransEndedSuccess);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$transStarted = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"transStarted\"")
    {
        $transStarted = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltransStarted;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttransStarted/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltransStarted += $currenttransStarted;
        $currenttransStarted = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttransStarted += $fields[$transStarted];
}
my $drops = $currenttransStarted/$currentPeriod;

$totaltransStarted += $currenttransStarted;


printf "Total (GTPC- Transactions Started):%.0f\n", ($totaltransStarted);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$ver0Pkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ver0Pkts\"")
    {
        $ver0Pkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalver0Pkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentver0Pkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalver0Pkts += $currentver0Pkts;
        $currentver0Pkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentver0Pkts += $fields[$ver0Pkts];
}
my $drops = $currentver0Pkts/$currentPeriod;

$totalver0Pkts += $currentver0Pkts;


printf "Total (GTPC- Version0 Packets):%.0f\n", ($totalver0Pkts);
'


rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$ver1Pkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ver1Pkts\"")
    {
        $ver1Pkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalver1Pkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentver1Pkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalver1Pkts += $currentver1Pkts;
        $currentver1Pkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentver1Pkts += $fields[$ver1Pkts];
}
my $drops = $currentver1Pkts/$currentPeriod;

$totalver1Pkts += $currentver1Pkts;


printf "Total (GTPC- Version1 Packets):%.0f\n", ($totalver1Pkts);
'

rm -rf ~/myFile

cat `ls -rt ./IicGtpcStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$ver2Pkts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ver2Pkts\"")
    {
        $ver2Pkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalver2Pkts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentver2Pkts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalver2Pkts += $currentver2Pkts;
        $currentver2Pkts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentver2Pkts += $fields[$ver2Pkts];
}
my $drops = $currentver2Pkts/$currentPeriod;

$totalver2Pkts += $currentver2Pkts;


printf "Total (GTPC- Version2 Packets):%.0f\n", ($totalver2Pkts);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# DIAMETER Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicProtoDiameterStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$diameterBad = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"diameterBad\"")
    {
        $diameterBad = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaldiameterBad;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentdiameterBad/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaldiameterBad += $currentdiameterBad;
        $currentdiameterBad = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentdiameterBad += $fields[$diameterBad];
}
my $drops = $currentdiameterBad/$currentPeriod;

$totaldiameterBad += $currentdiameterBad;


printf "Total (DIAMETER- Bad Diameter Packets):%.0f\n", ($totaldiameterBad);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoDiameterStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$diameterDiscardCmdCode = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"diameterDiscardCmdCode\"")
    {
        $diameterDiscardCmdCode = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaldiameterDiscardCmdCode;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentdiameterDiscardCmdCode/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaldiameterDiscardCmdCode += $currentdiameterDiscardCmdCode;
        $currentdiameterDiscardCmdCode = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentdiameterDiscardCmdCode += $fields[$diameterDiscardCmdCode];
}
my $drops = $currentdiameterDiscardCmdCode/$currentPeriod;

$totaldiameterDiscardCmdCode += $currentdiameterDiscardCmdCode;


printf "Total (DIAMETER- Discard Cmd Code):%.0f\n", ($totaldiameterDiscardCmdCode);
'


rm -rf ~/myFile

cat `ls -rt ./IicProtoDiameterStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$diameterIntoSync = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"diameterIntoSync\"")
    {
        $diameterIntoSync = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaldiameterIntoSync;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentdiameterIntoSync/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaldiameterIntoSync += $currentdiameterIntoSync;
        $currentdiameterIntoSync = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentdiameterIntoSync += $fields[$diameterIntoSync];
}
my $drops = $currentdiameterIntoSync/$currentPeriod;

$totaldiameterIntoSync += $currentdiameterIntoSync;


printf "Total (DIAMETER- Into Sync):%.0f\n", ($totaldiameterIntoSync);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoDiameterStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$diameterMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"diameterMessages\"")
    {
        $diameterMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaldiameterMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentdiameterMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaldiameterMessages += $currentdiameterMessages;
        $currentdiameterMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentdiameterMessages += $fields[$diameterMessages];
}
my $drops = $currentdiameterMessages/$currentPeriod;

$totaldiameterMessages += $currentdiameterMessages;


printf "Total (DIAMETER- Messages):%.0f\n", ($totaldiameterMessages);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# LDAP Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicProtoLdapStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$ldapAborts = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ldapAborts\"")
    {
        $ldapAborts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalldapAborts;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentldapAborts/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalldapAborts += $currentldapAborts;
        $currentldapAborts = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentldapAborts += $fields[$ldapAborts];
}
my $drops = $currentldapAborts/$currentPeriod;

$totalldapAborts += $currentldapAborts;


printf "Total (LDAP- Aborts):%.0f\n", ($totalldapAborts);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoLdapStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$ldapIntoSync = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ldapIntoSync\"")
    {
        $ldapIntoSync = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalldapIntoSync;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentldapIntoSync/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalldapIntoSync += $currentldapIntoSync;
        $currentldapIntoSync = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentldapIntoSync += $fields[$ldapIntoSync];
}
my $drops = $currentldapIntoSync/$currentPeriod;

$totalldapIntoSync += $currentldapIntoSync;


printf "Total (LDAP- Into Sync):%.0f\n", ($totalldapIntoSync);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoLdapStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$ldapMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"ldapMessages\"")
    {
        $ldapMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalldapMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentldapMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalldapMessages += $currentldapMessages;
        $currentldapMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentldapMessages += $fields[$ldapMessages];
}
my $drops = $currentldapMessages/$currentPeriod;

$totalldapMessages += $currentldapMessages;


printf "Total (LDAP- Messages):%.0f\n", ($totalldapMessages);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# MSRP Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicProtoMsrpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$msrpAborted = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"msrpAborted\"")
    {
        $msrpAborted = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmsrpAborted;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmsrpAborted/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmsrpAborted += $currentmsrpAborted;
        $currentmsrpAborted = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmsrpAborted += $fields[$msrpAborted];
}
my $drops = $currentmsrpAborted/$currentPeriod;

$totalmsrpAborted += $currentmsrpAborted;


printf "Total (MSRP- Aborted):%.0f\n", ($totalmsrpAborted);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoMsrpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$msrpCapPktsDropped = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"msrpCapPktsDropped\"")
    {
        $msrpCapPktsDropped = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmsrpCapPktsDropped;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmsrpCapPktsDropped/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmsrpCapPktsDropped += $currentmsrpCapPktsDropped;
        $currentmsrpCapPktsDropped = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmsrpCapPktsDropped += $fields[$msrpCapPktsDropped];
}
my $drops = $currentmsrpCapPktsDropped/$currentPeriod;

$totalmsrpCapPktsDropped += $currentmsrpCapPktsDropped;


printf "Total (MSRP- Capacity Packets Dropped):%.0f\n", ($totalmsrpCapPktsDropped);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoMsrpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$msrpCapPktsToDdm = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"msrpCapPktsToDdm\"")
    {
        $msrpCapPktsToDdm = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmsrpCapPktsToDdm;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmsrpCapPktsToDdm/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmsrpCapPktsToDdm += $currentmsrpCapPktsToDdm;
        $currentmsrpCapPktsToDdm = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmsrpCapPktsToDdm += $fields[$msrpCapPktsToDdm];
}
my $drops = $currentmsrpCapPktsToDdm/$currentPeriod;

$totalmsrpCapPktsToDdm += $currentmsrpCapPktsToDdm;


printf "Total (MSRP- Capacity Packets to DDM):%.0f\n", ($totalmsrpCapPktsToDdm);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoMsrpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$msrpCapStreams = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"msrpCapStreams\"")
    {
        $msrpCapStreams = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmsrpCapStreams;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmsrpCapStreams/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmsrpCapStreams += $currentmsrpCapStreams;
        $currentmsrpCapStreams = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmsrpCapStreams += $fields[$msrpCapStreams];
}
my $drops = $currentmsrpCapStreams/$currentPeriod;

$totalmsrpCapStreams += $currentmsrpCapStreams;


printf "Total (MSRP- Capacity Streams):%.0f\n", ($totalmsrpCapStreams);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoMsrpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$msrpCloneErrors = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"msrpCloneErrors\"")
    {
        $msrpCloneErrors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmsrpCloneErrors;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmsrpCloneErrors/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmsrpCloneErrors += $currentmsrpCloneErrors;
        $currentmsrpCloneErrors = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmsrpCloneErrors += $fields[$msrpCloneErrors];
}
my $drops = $currentmsrpCloneErrors/$currentPeriod;

$totalmsrpCloneErrors += $currentmsrpCloneErrors;


printf "Total (MSRP- Clone Errors):%.0f\n", ($totalmsrpCloneErrors);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoMsrpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$msrpMaxSegLink = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"msrpMaxSegLink\"")
    {
        $msrpMaxSegLink = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmsrpMaxSegLink;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmsrpMaxSegLink/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmsrpMaxSegLink += $currentmsrpMaxSegLink;
        $currentmsrpMaxSegLink = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmsrpMaxSegLink += $fields[$msrpMaxSegLink];
}
my $drops = $currentmsrpMaxSegLink/$currentPeriod;

$totalmsrpMaxSegLink += $currentmsrpMaxSegLink;


printf "Total (MSRP- Max Seg Link):%.0f\n", ($totalmsrpMaxSegLink);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoMsrpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$msrpMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"msrpMessages\"")
    {
        $msrpMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmsrpMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmsrpMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmsrpMessages += $currentmsrpMessages;
        $currentmsrpMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmsrpMessages += $fields[$msrpMessages];
}
my $drops = $currentmsrpMessages/$currentPeriod;

$totalmsrpMessages += $currentmsrpMessages;


printf "Total (MSRP- Messages):%.0f\n", ($totalmsrpMessages);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# PmipV6 Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicProtoPmipv6Stats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$pmipv6DroppedMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"pmipv6DroppedMessages\"")
    {
        $pmipv6DroppedMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalpmipv6DroppedMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentpmipv6DroppedMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalpmipv6DroppedMessages += $currentpmipv6DroppedMessages;
        $currentpmipv6DroppedMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentpmipv6DroppedMessages += $fields[$pmipv6DroppedMessages];
}
my $drops = $currentpmipv6DroppedMessages/$currentPeriod;

$totalpmipv6DroppedMessages += $currentpmipv6DroppedMessages;


printf "Total (PmipV6- Dropped Messages):%.0f\n", ($totalpmipv6DroppedMessages);
'


rm -rf ~/myFile

cat `ls -rt ./IicProtoPmipv6Stats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$pmipv6Messages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"pmipv6Messages\"")
    {
        $pmipv6Messages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalpmipv6Messages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentpmipv6Messages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalpmipv6Messages += $currentpmipv6Messages;
        $currentpmipv6Messages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentpmipv6Messages += $fields[$pmipv6Messages];
}
my $drops = $currentpmipv6Messages/$currentPeriod;

$totalpmipv6Messages += $currentpmipv6Messages;


printf "Total (PmipV6- Messages):%.0f\n", ($totalpmipv6Messages);
'
rm -rf ~/myFile
echo "#################################################################################################"
echo "# RADIUS Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicProtoRadiusStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$radiusDroppedMsgs = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"radiusDroppedMsgs\"")
    {
        $radiusDroppedMsgs = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalradiusDroppedMsgs;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentradiusDroppedMsgs/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalradiusDroppedMsgs += $currentradiusDroppedMsgs;
        $currentradiusDroppedMsgs = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentradiusDroppedMsgs += $fields[$radiusDroppedMsgs];
}
my $drops = $currentradiusDroppedMsgs/$currentPeriod;

$totalradiusDroppedMsgs += $currentradiusDroppedMsgs;


printf "Total (RADIUS- Dropped Messages):%.0f\n", ($totalradiusDroppedMsgs);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoRadiusStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$radiusMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"radiusMessages\"")
    {
        $radiusMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalradiusMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentradiusMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalradiusMessages += $currentradiusMessages;
        $currentradiusMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentradiusMessages += $fields[$radiusMessages];
}
my $drops = $currentradiusMessages/$currentPeriod;

$totalradiusMessages += $currentradiusMessages;


printf "Total (RADIUS- Messages):%.0f\n", ($totalradiusMessages);
'


rm -rf ~/myFile

cat `ls -rt ./IicProtoRadiusStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$radiusTblAllocError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"radiusTblAllocError\"")
    {
        $radiusTblAllocError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalradiusTblAllocError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentradiusTblAllocError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalradiusTblAllocError += $currentradiusTblAllocError;
        $currentradiusTblAllocError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentradiusTblAllocError += $fields[$radiusTblAllocError];
}
my $drops = $currentradiusTblAllocError/$currentPeriod;

$totalradiusTblAllocError += $currentradiusTblAllocError;


printf "Total (RADIUS- Table Allocation Errors):%.0f\n", ($totalradiusTblAllocError);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoRadiusStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$radiusTblInsertError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"radiusTblInsertError\"")
    {
        $radiusTblInsertError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalradiusTblInsertError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentradiusTblInsertError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalradiusTblInsertError += $currentradiusTblInsertError;
        $currentradiusTblInsertError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentradiusTblInsertError += $fields[$radiusTblInsertError];
}
my $drops = $currentradiusTblInsertError/$currentPeriod;

$totalradiusTblInsertError += $currentradiusTblInsertError;


printf "Total (RADIUS- Table Insert Errors):%.0f\n", ($totalradiusTblInsertError);
'
rm -rf ~/myFile
echo "#################################################################################################"
echo "# WSP/WTP Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicProtoWspwtpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$wspInvalidHeadersLen = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"wspInvalidHeadersLen\"")
    {
        $wspInvalidHeadersLen = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalwspInvalidHeadersLen;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentwspInvalidHeadersLen/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalwspInvalidHeadersLen += $currentwspInvalidHeadersLen;
        $currentwspInvalidHeadersLen = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentwspInvalidHeadersLen += $fields[$wspInvalidHeadersLen];
}
my $drops = $currentwspInvalidHeadersLen/$currentPeriod;

$totalwspInvalidHeadersLen += $currentwspInvalidHeadersLen;


printf "Total (WSP- Invalid Header Length):%.0f\n", ($totalwspInvalidHeadersLen);
'

rm -rf ~/myFile

cat `ls -rt ./IicProtoWspwtpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$wtpAllocFail = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"wtpAllocFail\"")
    {
        $wtpAllocFail = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalwtpAllocFail;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentwtpAllocFail/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalwtpAllocFail += $currentwtpAllocFail;
        $currentwtpAllocFail = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentwtpAllocFail += $fields[$wtpAllocFail];
}
my $drops = $currentwtpAllocFail/$currentPeriod;

$totalwtpAllocFail += $currentwtpAllocFail;


printf "Total (WTP- Allocation Fail):%.0f\n", ($totalwtpAllocFail);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# SCTP Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicSctpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##########################################################################
## Statistic: "assocAllocFailures" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$assocAllocFailures = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"assocAllocFailures\"")
    {
        $assocAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentAllocFailures;
my $totalAllocFailures;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalAllocFailures += $currentAllocFailures;
        $currentAllocFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentAllocFailures += $fields[$assocAllocFailures];
}
$totalAllocFailures += $currentAllocFailures;

printf "TOTAL (SCTP- Association Allocation Failures):%.0f\n", ($totalAllocFailures);
'


##########################################################################
## Statistic: "assocTblEntries" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$assocTblEntries = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"assocTblEntries\"")
    {
        $assocTblEntries = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentAssocTblEntries;
my $totalAssocTblEntries;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalAssocTblEntries += $currentAssocTblEntries;
        $currentAssocTblEntries = 0;
    }
    $currentTime = $fields[$time];
    $currentAssocTblEntries += $fields[$assocTblEntries];
}
$totalAssocTblEntries += $currentAssocTblEntries;

printf "TOTAL (SCTP- Association Table Entries):%.0f\n", ($totalAssocTblEntries);
'



##########################################################################
## Statistic: "assocTblInsertFails" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$assocTblInsertFails = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"assocTblInsertFails\"")
    {
        $assocTblInsertFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentAssocInsertFails;
my $totalAssocInsertFails;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalAssocInsertFails += $currentAssocInsertFails;
        $currentAssocInsertFails = 0;
    }
    $currentTime = $fields[$time];
    $currentAssocInsertFails += $fields[$assocTblInsertFails];
}
$totalAssocInsertFails += $currentAssocInsertFails;

printf "TOTAL (SCTP- Association Table Insert Fails):%.0f\n", ($totalAssocInsertFails);
'



##########################################################################
## Statistic: "bitmapAllocFailures" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$bitmapAllocFailures = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"bitmapAllocFailures\"")
    {
        $bitmapAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentBitmapAllocFailures;
my $totalBitmapAllocFailures;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalBitmapAllocFailures += $currentBitmapAllocFailures;
        $currentBitmapAllocFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentBitmapAllocFailures += $fields[$bitmapAllocFailures];
}
$totalBitmapAllocFailures += $currentBitmapAllocFailures;

printf "TOTAL (SCTP- Bitmap Allocation Failures):%.0f\n", ($totalBitmapAllocFailures);
'


##########################################################################
## Statistic: "bundledPkts" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$bundledPkts = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"bundledPkts\"")
    {
        $bundledPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentBundledPkts;
my $totalBundledPkts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalBundledPkts += $currentBundledPkts;
        $currentBundledPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentBundledPkts += $fields[$bundledPkts];
}
$totalBundledPkts += $currentBundledPkts;

printf "TOTAL (SCTP- Bundled Packets):%.0f\n", ($totalBundledPkts);
'



##########################################################################
## Statistic: "chunksLostReassembly" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$chunksLostReassembly = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"chunksLostReassembly\"")
    {
        $chunksLostReassembly = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentChunksLostAssy;
my $totalChunksLostAssy;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalChunksLostAssy += $currentChunksLostAssy;
        $currentChunksLostAssy = 0;
    }
    $currentTime = $fields[$time];
    $currentChunksLostAssy += $fields[$chunksLostReassembly];
}
$totalChunksLostAssy += $currentChunksLostAssy;

printf "TOTAL (SCTP- Chunks Lost Reassembly):%.0f\n", ($totalChunksLostAssy);
'


##########################################################################
## Statistic: "cloneFailed" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$cloneFailed = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"cloneFailed\"")
    {
        $cloneFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentClonesFailed;
my $totalClonesFailed;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalClonesFailed += $currentClonesFailed;
        $currentClonesFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentClonesFailed += $fields[$cloneFailed];
}
$totalClonesFailed += $currentClonesFailed;

printf "TOTAL (SCTP- Clone Failed):%.0f\n", ($totalClonesFailed);
'


##########################################################################
## Statistic: "disregardedPkts" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$disregardedPkts = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"disregardedPkts\"")
    {
        $disregardedPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentDisregardedPkts;
my $totalDisregardedPkts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalDisregardedPkts += $currentDisregardedPkts;
        $currentDisregardedPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentDisregardedPkts += $fields[$disregardedPkts];
}
$totalDisregardedPkts += $currentDisregardedPkts;

printf "TOTAL (SCTP- Disregarded Packets):%.0f\n", ($totalDisregardedPkts);
'



##########################################################################
## Statistic: "droppedAddresses" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$droppedAddresses = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"droppedAddresses\"")
    {
        $droppedAddresses = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentDroppedAddresses;
my $totalDroppedAddresses;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalDroppedAddresses += $currentDroppedAddresses;
        $currentDroppedAddresses = 0;
    }
    $currentTime = $fields[$time];
    $currentDroppedAddresses += $fields[$droppedAddresses];
}
$totalDroppedAddresses += $currentDroppedAddresses;

printf "TOTAL (SCTP- Dropped Addresses):%.0f\n", ($totalDroppedAddresses);
'


##########################################################################
## Statistic: "droppedDetection" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$droppedDetection = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"droppedDetection\"")
    {
        $droppedDetection = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentDroppedDetection;
my $totalDroppedDetection;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalDroppedDetection += $currentDroppedDetection;
        $currentDroppedDetection = 0;
    }
    $currentTime = $fields[$time];
    $currentDroppedDetection += $fields[$droppedDetection];
}
$totalDroppedDetection += $currentDroppedDetection;

printf "TOTAL (SCTP- Dropped Detection):%.0f\n", ($totalDroppedDetection);
'


##########################################################################
## Statistic: "droppedPkts" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$droppedPkts = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"droppedPkts\"")
    {
        $droppedPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentDroppedPkts;
my $totalDroppedPkts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalDroppedPkts += $currentDroppedPkts;
        $currentDroppedPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentDroppedPkts += $fields[$droppedPkts];
}
$totalDroppedPkts += $currentDroppedPkts;

printf "TOTAL (SCTP- Dropped Packets):%.0f\n", ($totalDroppedPkts);
'


##########################################################################
## Statistic: "fragmentsDropped" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$fragmentsDropped = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"fragmentsDropped\"")
    {
        $fragmentsDropped = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentFragmentsDropped;
my $totalFragmentsDropped;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalFragmentsDropped += $currentFragmentsDropped;
        $currentFragmentsDropped = 0;
    }
    $currentTime = $fields[$time];
    $currentFragmentsDropped += $fields[$fragmentsDropped];
}
$totalFragmentsDropped += $currentFragmentsDropped;

printf "TOTAL (SCTP- Fragments Dropped):%.0f\n", ($totalFragmentsDropped);
'


##########################################################################
## Statistic: "fragmentsHeld" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$fragmentsHeld = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"fragmentsHeld\"")
    {
        $fragmentsHeld = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentFragmentsHeld;
my $totalFragmentsHeld;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalFragmentsHeld += $currentFragmentsHeld;
        $currentFragmentsHeld = 0;
    }
    $currentTime = $fields[$time];
    $currentFragmentsHeld += $fields[$fragmentsHeld];
}
$totalFragmentsHeld += $currentFragmentsHeld;

printf "TOTAL (SCTP- Fragments Held):%.0f\n", ($totalFragmentsHeld);
'


##########################################################################
## Statistic: "incompleteInits" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$incompleteInits = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"incompleteInits\"")
    {
        $incompleteInits = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentIncompleteInits;
my $totalIncompleteInits;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalIncompleteInits += $currentIncompleteInits;
        $currentIncompleteInits = 0;
    }
    $currentTime = $fields[$time];
    $currentIncompleteInits += $fields[$incompleteInits];
}
$totalIncompleteInits += $currentIncompleteInits;

printf "TOTAL (SCTP- Incomplete Inits):%.0f\n", ($totalIncompleteInits);
'


##########################################################################
## Statistic: "incompleteReassemblies" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$incompleteReassemblies = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"incompleteReassemblies\"")
    {
        $incompleteReassemblies = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentIncompleteReassemblies;
my $totalIncompleteReassemblies;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalIncompleteReassemblies += $currentIncompleteReassemblies;
        $currentIncompleteReassemblies = 0;
    }
    $currentTime = $fields[$time];
    $currentIncompleteReassemblies += $fields[$incompleteReassemblies];
}
$totalIncompleteReassemblies += $currentIncompleteReassemblies;

printf "TOTAL (SCTP- Incomplete Reassemblies):%.0f\n", ($totalIncompleteReassemblies);
'


##########################################################################
## Statistic: "inconsistentAssocs" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$inconsistentAssocs = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"inconsistentAssocs\"")
    {
        $inconsistentAssocs = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentInconsistentAssocs;
my $totalInconsistentAssocs;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalInconsistentAssocs += $currentInconsistentAssocs;
        $currentInconsistentAssocs = 0;
    }
    $currentTime = $fields[$time];
    $currentInconsistentAssocs += $fields[$inconsistentAssocs];
}
$totalInconsistentAssocs += $currentInconsistentAssocs;

printf "TOTAL (SCTP- Inconsistent Associations):%.0f\n", ($totalInconsistentAssocs);
'



##########################################################################
## Statistic: "linkTblEntries" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$linkTblEntries = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"linkTblEntries\"")
    {
        $linkTblEntries = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentLinkTblEntries;
my $totalLinkTblEntries;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalLinkTblEntries += $currentLinkTblEntries;
        $currentLinkTblEntries = 0;
    }
    $currentTime = $fields[$time];
    $currentLinkTblEntries += $fields[$linkTblEntries];
}
$totalLinkTblEntries += $currentLinkTblEntries;

printf "TOTAL (SCTP- Link Table Entries):%.0f\n", ($totalLinkTblEntries);
'


##########################################################################
## Statistic: "linkTblInsertFails" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$linkTblInsertFails = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"linkTblInsertFails\"")
    {
        $linkTblInsertFails = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentLinkTblInsertFails;
my $totalLinkTblInsertFails;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalLinkTblInsertFails += $currentLinkTblInsertFails;
        $currentLinkTblInsertFails = 0;
    }
    $currentTime = $fields[$time];
    $currentLinkTblInsertFails += $fields[$linkTblInsertFails];
}
$totalLinkTblInsertFails += $currentLinkTblInsertFails;

printf "TOTAL (SCTP- Link Table Insert Fails):%.0f\n", ($totalLinkTblInsertFails);
'


##########################################################################
## Statistic: "monitoredPaths" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$monitoredPaths = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"monitoredPaths\"")
    {
        $monitoredPaths = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentMonitoredPaths;
my $totalMonitoredPaths;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalMonitoredPaths += $currentMonitoredPaths;
        $currentMonitoredPaths = 0;
    }
    $currentTime = $fields[$time];
    $currentMonitoredPaths += $fields[$monitoredPaths];
}
$totalMonitoredPaths += $currentMonitoredPaths;

printf "TOTAL (SCTP- Monitored Paths):%.0f\n", ($totalMonitoredPaths);
'



##########################################################################
## Statistic: "overrunResets" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$overrunResets = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"overrunResets\"")
    {
        $overrunResets = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentOverrunResets;
my $totalOverrunResets;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalOverrunResets += $currentOverrunResets;
        $currentOverrunResets = 0;
    }
    $currentTime = $fields[$time];
    $currentOverrunResets += $fields[$overrunResets];
}
$totalOverrunResets += $currentOverrunResets;

printf "TOTAL (SCTP- Overrun Resets):%.0f\n", ($totalOverrunResets);
'



##########################################################################
## Statistic: "overruns" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$overruns = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"overruns\"")
    {
        $overruns = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentOverruns;
my $totalOverruns;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalOverruns += $currentOverruns;
        $currentOverruns = 0;
    }
    $currentTime = $fields[$time];
    $currentOverruns += $fields[$overruns];
}
$totalOverruns += $currentOverruns;

printf "TOTAL (SCTP- Overruns):%.0f\n", ($totalOverruns);
'


##########################################################################
## Statistic: "pathsWithNoAssoc" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$pathsWithNoAssoc = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"pathsWithNoAssoc\"")
    {
        $pathsWithNoAssoc = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPathsWithNoAss;
my $totalPathsWithNoAss;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalPathsWithNoAss += $currentPathsWithNoAss;
        $currentPathsWithNoAss = 0;
    }
    $currentTime = $fields[$time];
    $currentPathsWithNoAss += $fields[$pathsWithNoAssoc];
}
$totalPathsWithNoAss += $currentPathsWithNoAss;

printf "TOTAL (SCTP- Paths With No Association):%.0f\n", ($totalPathsWithNoAss);
'


##########################################################################
## Statistic: "processedPkts" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$processedPkts = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"processedPkts\"")
    {
        $processedPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentProcessedPkts;
my $totalProcessedPkts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalProcessedPkts += $currentProcessedPkts;
        $currentProcessedPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentProcessedPkts += $fields[$processedPkts];
}
$totalProcessedPkts += $currentProcessedPkts;

printf "TOTAL (SCTP- Processed Packets):%.0f\n", ($totalProcessedPkts);
'



##########################################################################
## Statistic: "reassemblyCreateFailed" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$reassemblyCreateFailed = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"reassemblyCreateFailed\"")
    {
        $reassemblyCreateFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentReassCreateFailed;
my $totalReassCreateFailed;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalReassCreateFailed += $currentReassCreateFailed;
        $currentReassCreateFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentReassCreateFailed += $fields[$reassemblyCreateFailed];
}
$totalReassCreateFailed += $currentReassCreateFailed;

printf "TOTAL (SCTP- Reassembly Create Failed):%.0f\n", ($totalReassCreateFailed);
'


##########################################################################
## Statistic: "retransmissionResets" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$retransmissionResets = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"retransmissionResets\"")
    {
        $retransmissionResets = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentRetransmissionResets;
my $totalRetransmissionResets;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalRetransmissionResets += $currentRetransmissionResets;
        $currentRetransmissionResets = 0;
    }
    $currentTime = $fields[$time];
    $currentRetransmissionResets += $fields[$retransmissionResets];
}
$totalRetransmissionResets += $currentRetransmissionResets;

printf "TOTAL (SCTP- Retransmission Resets):%.0f\n", ($totalRetransmissionResets);
'


##########################################################################
## Statistic: "retransmissios" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$retransmissios = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"retransmissios\"")
    {
        $retransmissios = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentRetransMissios;
my $totalRetransMissios;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalRetransMissios += $currentRetransMissios;
        $currentRetransMissios = 0;
    }
    $currentTime = $fields[$time];
    $currentRetransMissios += $fields[$retransmissios];
}
$totalRetransMissios += $currentRetransMissios;

printf "TOTAL (SCTP- Retransmissions):%.0f\n", ($totalRetransMissios);
'


##########################################################################
## Statistic: "sackOutOfRange" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$sackOutOfRange = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"sackOutOfRange\"")
    {
        $sackOutOfRange = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentSackOutOfRange;
my $totalSackOutOfRange;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalSackOutOfRange += $currentSackOutOfRange;
        $currentSackOutOfRange = 0;
    }
    $currentTime = $fields[$time];
    $currentSackOutOfRange += $fields[$sackOutOfRange];
}
$totalSackOutOfRange += $currentSackOutOfRange;

printf "TOTAL (SCTP- Sack Out Of Range):%.0f\n", ($totalSackOutOfRange);
'


##########################################################################
## Statistic: "seqCreateFailed" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$seqCreateFailed = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"seqCreateFailed\"")
    {
        $seqCreateFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentSeqCreateFailed;
my $totalSeqCreateFailed;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalSeqCreateFailed += $currentSeqCreateFailed;
        $currentSeqCreateFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentSeqCreateFailed += $fields[$seqCreateFailed];
}
$totalSeqCreateFailed += $currentSeqCreateFailed;

printf "TOTAL (SCTP- Sequence Create Failed):%.0f\n", ($totalSeqCreateFailed);
'


##########################################################################
## Statistic: "sequenceErrors" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$sequenceErrors = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"sequenceErrors\"")
    {
        $sequenceErrors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentSeqErrors;
my $totalSeqErrors;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalSeqErrors += $currentSeqErrors;
        $currentSeqErrors = 0;
    }
    $currentTime = $fields[$time];
    $currentSeqErrors += $fields[$sequenceErrors];
}
$totalSeqErrors += $currentSeqErrors;

printf "TOTAL (SCTP- Sequence Errors):%.0f\n", ($totalSeqErrors);
'


##########################################################################
## Statistic: "streamAddFailed" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$streamAddFailed = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"streamAddFailed\"")
    {
        $streamAddFailed = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentStreamAddFailed;
my $totalStreamAddFailed;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalStreamAddFailed += $currentStreamAddFailed;
        $currentStreamAddFailed = 0;
    }
    $currentTime = $fields[$time];
    $currentStreamAddFailed += $fields[$streamAddFailed];
}
$totalStreamAddFailed += $currentStreamAddFailed;

printf "TOTAL (SCTP- Stream Add Failed):%.0f\n", ($totalStreamAddFailed);
'

##########################################################################
## Statistic: "timerFailures" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$timerFailures = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"timerFailures\"")
    {
        $timerFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentTimerFailures;
my $totalTimerFailures;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalTimerFailures += $currentTimerFailures;
        $currentTimerFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentTimerFailures += $fields[$timerFailures];
}
$totalTimerFailures += $currentTimerFailures;

printf "TOTAL (SCTP- Timer Failures):%.0f\n", ($totalTimerFailures);
'



##########################################################################
## Statistic: "totalPkts" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$totalPkts = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"totalPkts\"")
    {
        $totalPkts = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentTotalPkts;
my $totalTotalPkts;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalTotalPkts += $currentTotalPkts;
        $currentTotalPkts = 0;
    }
    $currentTime = $fields[$time];
    $currentTotalPkts += $fields[$totalPkts];
}
$totalTotalPkts += $currentTotalPkts;

printf "TOTAL (SCTP- Total Packets):%.0f\n", ($totalTotalPkts);
'



##########################################################################
## Statistic: "tsnOutOfRange" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
@fields = split ",", $input;
$tsnOutOfRange = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"tsnOutOfRange\"")
    {
        $tsnOutOfRange = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentTsnOutOfRange;
my $totalTsnOutOfRange;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalTsnOutOfRange += $currentTsnOutOfRange;
        $currentTsnOutOfRange = 0;
    }
    $currentTime = $fields[$time];
    $currentTsnOutOfRange += $fields[$tsnOutOfRange];
}
$totalTsnOutOfRange += $currentTsnOutOfRange;

printf "TOTAL (SCTP- TSN Out Of Range):%.0f\n", ($totalTsnOutOfRange);
'

##########################################################################
## Statistic: "vtagResets" (Packets-Per-Second) AVG
##########################################################################

cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$vtagResets = 0;
$period = 0;
$time = 0;
$tmp =0;

foreach $field (@fields)
{
    if ($field eq "\"vtagResets\"")
    {
        $vtagResets = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentVtagResets;
my $totalVtagResets;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
        $totalVtagResets += $currentVtagResets;
        $currentVtagResets = 0;
    }
    $currentTime = $fields[$time];
    $currentVtagResets += $fields[$vtagResets];
}
$totalVtagResets += $currentVtagResets;

printf "TOTAL (SCTP- VTAG Resets):%.0f\n", ($totalVtagResets);
'



rm -rf ~/myFile
echo "#################################################################################################"
echo "# Sigtran Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$isupMessage = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"isupMessage\"")
    {
        $isupMessage = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalisupMessage;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentisupMessage/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalisupMessage += $currentisupMessage;
        $currentisupMessage = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentisupMessage += $fields[$isupMessage];
}
my $drops = $currentisupMessage/$currentPeriod;

$totalisupMessage += $currentisupMessage;


printf "Total (SIGTRAN- ISUP Messages):%.0f\n", ($totalisupMessage);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$m3uaDroppedMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"m3uaDroppedMessages\"")
    {
        $m3uaDroppedMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalm3uaDroppedMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentm3uaDroppedMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalm3uaDroppedMessages += $currentm3uaDroppedMessages;
        $currentm3uaDroppedMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentm3uaDroppedMessages += $fields[$m3uaDroppedMessages];
}
my $drops = $currentm3uaDroppedMessages/$currentPeriod;

$totalm3uaDroppedMessages += $currentm3uaDroppedMessages;


printf "Total (SIGTRAN- M3UA Dropped Messages):%.0f\n", ($totalm3uaDroppedMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$m3uaFragmentedMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"m3uaFragmentedMessages\"")
    {
        $m3uaFragmentedMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalm3uaFragmentedMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentm3uaFragmentedMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalm3uaFragmentedMessages += $currentm3uaFragmentedMessages;
        $currentm3uaFragmentedMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentm3uaFragmentedMessages += $fields[$m3uaFragmentedMessages];
}
my $drops = $currentm3uaFragmentedMessages/$currentPeriod;

$totalm3uaFragmentedMessages += $currentm3uaFragmentedMessages;


printf "Total (SIGTRAN- M3UA Fragmented Messages):%.0f\n", ($totalm3uaFragmentedMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$m3uaMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"m3uaMessages\"")
    {
        $m3uaMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalm3uaMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentm3uaMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalm3uaMessages += $currentm3uaMessages;
        $currentm3uaMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentm3uaMessages += $fields[$m3uaMessages];
}
my $drops = $currentm3uaMessages/$currentPeriod;

$totalm3uaMessages += $currentm3uaMessages;


printf "Total (SIGTRAN- M3UA Messages):%.0f\n", ($totalm3uaMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$m3uaNotClassified = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"m3uaNotClassified\"")
    {
        $m3uaNotClassified = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalm3uaNotClassified;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentm3uaNotClassified/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalm3uaNotClassified += $currentm3uaNotClassified;
        $currentm3uaNotClassified = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentm3uaNotClassified += $fields[$m3uaNotClassified];
}
my $drops = $currentm3uaNotClassified/$currentPeriod;

$totalm3uaNotClassified += $currentm3uaNotClassified;


printf "Total (SIGTRAN- M3UA Not Classified):%.0f\n", ($totalm3uaNotClassified);
'


rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sccpDropped = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sccpDropped\"")
    {
        $sccpDropped = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsccpDropped;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsccpDropped/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsccpDropped += $currentsccpDropped;
        $currentsccpDropped = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsccpDropped += $fields[$sccpDropped];
}
my $drops = $currentsccpDropped/$currentPeriod;

$totalsccpDropped += $currentsccpDropped;


printf "Total (SIGTRAN- SCCP Dropped):%.0f\n", ($totalsccpDropped);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sccpTableInsertErrors = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sccpTableInsertErrors\"")
    {
        $sccpTableInsertErrors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsccpTableInsertErrors;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsccpTableInsertErrors/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsccpTableInsertErrors += $currentsccpTableInsertErrors;
        $currentsccpTableInsertErrors = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsccpTableInsertErrors += $fields[$sccpTableInsertErrors];
}
my $drops = $currentsccpTableInsertErrors/$currentPeriod;

$totalsccpTableInsertErrors += $currentsccpTableInsertErrors;


printf "Total (SIGTRAN- SCCP Table Insert Errors):%.0f\n", ($totalsccpTableInsertErrors);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sccpTotalSegments = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sccpTotalSegments\"")
    {
        $sccpTotalSegments = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsccpTotalSegments;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsccpTotalSegments/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsccpTotalSegments += $currentsccpTotalSegments;
        $currentsccpTotalSegments = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsccpTotalSegments += $fields[$sccpTotalSegments];
}
my $drops = $currentsccpTotalSegments/$currentPeriod;

$totalsccpTotalSegments += $currentsccpTotalSegments;


printf "Total (SIGTRAN- SCCP Total Segments):%.0f\n", ($totalsccpTotalSegments);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$suaDroppedMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"suaDroppedMessages\"")
    {
        $suaDroppedMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsuaDroppedMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsuaDroppedMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsuaDroppedMessages += $currentsuaDroppedMessages;
        $currentsuaDroppedMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsuaDroppedMessages += $fields[$suaDroppedMessages];
}
my $drops = $currentsuaDroppedMessages/$currentPeriod;

$totalsuaDroppedMessages += $currentsuaDroppedMessages;


printf "Total (SIGTRAN- SUA Dropped Messages):%.0f\n", ($totalsuaDroppedMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$suaFragmentedMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"suaFragmentedMessages\"")
    {
        $suaFragmentedMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsuaFragmentedMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsuaFragmentedMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsuaFragmentedMessages += $currentsuaFragmentedMessages;
        $currentsuaFragmentedMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsuaFragmentedMessages += $fields[$suaFragmentedMessages];
}
my $drops = $currentsuaFragmentedMessages/$currentPeriod;

$totalsuaFragmentedMessages += $currentsuaFragmentedMessages;


printf "Total (SIGTRAN- SUA Fragmented Messages):%.0f\n", ($totalsuaFragmentedMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$suaMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"suaMessages\"")
    {
        $suaMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsuaMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsuaMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsuaMessages += $currentsuaMessages;
        $currentsuaMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsuaMessages += $fields[$suaMessages];
}
my $drops = $currentsuaMessages/$currentPeriod;

$totalsuaMessages += $currentsuaMessages;


printf "Total (SIGTRAN- SUA Messages):%.0f\n", ($totalsuaMessages);
'


rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$tableEntryAllocFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"tableEntryAllocFailures\"")
    {
        $tableEntryAllocFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltableEntryAllocFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttableEntryAllocFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltableEntryAllocFailures += $currenttableEntryAllocFailures;
        $currenttableEntryAllocFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttableEntryAllocFailures += $fields[$tableEntryAllocFailures];
}
my $drops = $currenttableEntryAllocFailures/$currentPeriod;

$totaltableEntryAllocFailures += $currenttableEntryAllocFailures;


printf "Total (SIGTRAN- Table Entry Allocation Failures):%.0f\n", ($totaltableEntryAllocFailures);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$tableInsertFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"tableInsertFailures\"")
    {
        $tableInsertFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltableInsertFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttableInsertFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltableInsertFailures += $currenttableInsertFailures;
        $currenttableInsertFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttableInsertFailures += $fields[$tableInsertFailures];
}
my $drops = $currenttableInsertFailures/$currentPeriod;

$totaltableInsertFailures += $currenttableInsertFailures;


printf "Total (SIGTRAN- Table Insert Failures):%.0f\n", ($totaltableInsertFailures);
'


rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$tcapContNotSupported = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"tcapContNotSupported\"")
    {
        $tcapContNotSupported = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltcapContNotSupported;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttcapContNotSupported/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltcapContNotSupported += $currenttcapContNotSupported;
        $currenttcapContNotSupported = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttcapContNotSupported += $fields[$tcapContNotSupported];
}
my $drops = $currenttcapContNotSupported/$currentPeriod;

$totaltcapContNotSupported += $currenttcapContNotSupported;


printf "Total (SIGTRAN- TCAP Cont Not Supported):%.0f\n", ($totaltcapContNotSupported);
'

rm -rf ~/myFile

cat `ls -rt ./IicSigtranStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$tcapDropped = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"tcapDropped\"")
    {
        $tcapDropped = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltcapDropped;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttcapDropped/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltcapDropped += $currenttcapDropped;
        $currenttcapDropped = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttcapDropped += $fields[$tcapDropped];
}
my $drops = $currenttcapDropped/$currentPeriod;

$totaltcapDropped += $currenttcapDropped;


printf "Total (SIGTRAN- TCAP Dropped):%.0f\n", ($totaltcapDropped);
'
rm -rf ~/myFile
echo "#################################################################################################"
echo "# TCP Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$oosCloneFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"oosCloneFailures\"")
    {
        $oosCloneFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaloosCloneFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentoosCloneFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaloosCloneFailures += $currentoosCloneFailures;
        $currentoosCloneFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentoosCloneFailures += $fields[$oosCloneFailures];
}
my $drops = $currentoosCloneFailures/$currentPeriod;

$totaloosCloneFailures += $currentoosCloneFailures;


printf "Total (TCP- OOS Clone Failures):%.0f\n", ($totaloosCloneFailures);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$oosInsertCnt = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"oosInsertCnt\"")
    {
        $oosInsertCnt = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaloosInsertCnt;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentoosInsertCnt/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaloosInsertCnt += $currentoosInsertCnt;
        $currentoosInsertCnt = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentoosInsertCnt += $fields[$oosInsertCnt];
}
my $drops = $currentoosInsertCnt/$currentPeriod;

$totaloosInsertCnt += $currentoosInsertCnt;


printf "Total (TCP- OOS Insert Count):%.0f\n", ($totaloosInsertCnt);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$oosInsertFailures = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"oosInsertFailures\"")
    {
        $oosInsertFailures = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaloosInsertFailures;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentoosInsertFailures/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaloosInsertFailures += $currentoosInsertFailures;
        $currentoosInsertFailures = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentoosInsertFailures += $fields[$oosInsertFailures];
}
my $drops = $currentoosInsertFailures/$currentPeriod;

$totaloosInsertFailures += $currentoosInsertFailures;


printf "Total (TCP- OOS Insert Failures):%.0f\n", ($totaloosInsertFailures);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$oosRemoveCnt = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"oosRemoveCnt\"")
    {
        $oosRemoveCnt = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaloosRemoveCnt;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentoosRemoveCnt/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaloosRemoveCnt += $currentoosRemoveCnt;
        $currentoosRemoveCnt = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentoosRemoveCnt += $fields[$oosRemoveCnt];
}
my $drops = $currentoosRemoveCnt/$currentPeriod;

$totaloosRemoveCnt += $currentoosRemoveCnt;


printf "Total (TCP- OOS Remove Count):%.0f\n", ($totaloosRemoveCnt);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rsmCloneErrors = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rsmCloneErrors\"")
    {
        $rsmCloneErrors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrsmCloneErrors;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrsmCloneErrors/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrsmCloneErrors += $currentrsmCloneErrors;
        $currentrsmCloneErrors = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrsmCloneErrors += $fields[$rsmCloneErrors];
}
my $drops = $currentrsmCloneErrors/$currentPeriod;

$totalrsmCloneErrors += $currentrsmCloneErrors;


printf "Total (TCP- RSM Clone Errors):%.0f\n", ($totalrsmCloneErrors);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rsmMaxSegLink = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rsmMaxSegLink\"")
    {
        $rsmMaxSegLink = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrsmMaxSegLink;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrsmMaxSegLink/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrsmMaxSegLink += $currentrsmMaxSegLink;
        $currentrsmMaxSegLink = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrsmMaxSegLink += $fields[$rsmMaxSegLink];
}
my $drops = $currentrsmMaxSegLink/$currentPeriod;

$totalrsmMaxSegLink += $currentrsmMaxSegLink;


printf "Total (TCP- RSM Max Seg Link):%.0f\n", ($totalrsmMaxSegLink);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$rsmMaxSizeExceeded = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"rsmMaxSizeExceeded\"")
    {
        $rsmMaxSizeExceeded = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalrsmMaxSizeExceeded;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentrsmMaxSizeExceeded/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalrsmMaxSizeExceeded += $currentrsmMaxSizeExceeded;
        $currentrsmMaxSizeExceeded = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentrsmMaxSizeExceeded += $fields[$rsmMaxSizeExceeded];
}
my $drops = $currentrsmMaxSizeExceeded/$currentPeriod;

$totalrsmMaxSizeExceeded += $currentrsmMaxSizeExceeded;


printf "Total (TCP- RSM Max Seg Link):%.0f\n", ($totalrsmMaxSizeExceeded);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$seqNodeAllocError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"seqNodeAllocError\"")
    {
        $seqNodeAllocError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalseqNodeAllocError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentseqNodeAllocError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalseqNodeAllocError += $currentseqNodeAllocError;
        $currentseqNodeAllocError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentseqNodeAllocError += $fields[$seqNodeAllocError];
}
my $drops = $currentseqNodeAllocError/$currentPeriod;

$totalseqNodeAllocError += $currentseqNodeAllocError;


printf "Total (TCP- Seq Node Alloc Error):%.0f\n", ($totalseqNodeAllocError);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$tcpSegmentsToRsm = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"tcpSegmentsToRsm\"")
    {
        $tcpSegmentsToRsm = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltcpSegmentsToRsm;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttcpSegmentsToRsm/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltcpSegmentsToRsm += $currenttcpSegmentsToRsm;
        $currenttcpSegmentsToRsm = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttcpSegmentsToRsm += $fields[$tcpSegmentsToRsm];
}
my $drops = $currenttcpSegmentsToRsm/$currentPeriod;

$totaltcpSegmentsToRsm += $currenttcpSegmentsToRsm;


printf "Total (TCP- TCP Segments to RSM):%.0f\n", ($totaltcpSegmentsToRsm);
'

rm -rf ~/myFile

cat `ls -rt ./IicTcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$tcpSmResets = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"tcpSmResets\"")
    {
        $tcpSmResets = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totaltcpSmResets;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currenttcpSmResets/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totaltcpSmResets += $currenttcpSmResets;
        $currenttcpSmResets = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currenttcpSmResets += $fields[$tcpSmResets];
}
my $drops = $currenttcpSmResets/$currentPeriod;

$totaltcpSmResets += $currenttcpSmResets;


printf "Total (TCP- TCP SM Resets):%.0f\n", ($totaltcpSmResets);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# VoIP: H225 Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicVoipH225Stats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$H225Errors = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"H225Errors\"")
    {
        $H225Errors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalH225Errors;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentH225Errors/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalH225Errors += $currentH225Errors;
        $currentH225Errors = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentH225Errors += $fields[$H225Errors];
}
my $drops = $currentH225Errors/$currentPeriod;

$totalH225Errors += $currentH225Errors;


printf "Total (VoIP- H225 Errors):%.0f\n", ($totalH225Errors);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipH225Stats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$H225Good = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"H225Good\"")
    {
        $H225Good = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalH225Good;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentH225Good/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalH225Good += $currentH225Good;
        $currentH225Good = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentH225Good += $fields[$H225Good];
}
my $drops = $currentH225Good/$currentPeriod;

$totalH225Good += $currentH225Good;


printf "Total (VoIP- H225 Good):%.0f\n", ($totalH225Good);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# VoIP: Megaco Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoCloneError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoCloneError\"")
    {
        $megacoCloneError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoCloneError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoCloneError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoCloneError += $currentmegacoCloneError;
        $currentmegacoCloneError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoCloneError += $fields[$megacoCloneError];
}
my $drops = $currentmegacoCloneError/$currentPeriod;

$totalmegacoCloneError += $currentmegacoCloneError;


printf "Total (VoIP- Megaco Clone Errors):%.0f\n", ($totalmegacoCloneError);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoCreateError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoCreateError\"")
    {
        $megacoCreateError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoCreateError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoCreateError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoCreateError += $currentmegacoCreateError;
        $currentmegacoCreateError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoCreateError += $fields[$megacoCreateError];
}
my $drops = $currentmegacoCreateError/$currentPeriod;

$totalmegacoCreateError += $currentmegacoCreateError;


printf "Total (VoIP- Megaco Create Errors):%.0f\n", ($totalmegacoCreateError);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoErrors = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoErrors\"")
    {
        $megacoErrors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoErrors;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoErrors/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoErrors += $currentmegacoErrors;
        $currentmegacoErrors = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoErrors += $fields[$megacoErrors];
}
my $drops = $currentmegacoErrors/$currentPeriod;

$totalmegacoErrors += $currentmegacoErrors;


printf "Total (VoIP- Megaco Errors):%.0f\n", ($totalmegacoErrors);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoGoodAscii = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoGoodAscii\"")
    {
        $megacoGoodAscii = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoGoodAscii;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoGoodAscii/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoGoodAscii += $currentmegacoGoodAscii;
        $currentmegacoGoodAscii = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoGoodAscii += $fields[$megacoGoodAscii];
}
my $drops = $currentmegacoGoodAscii/$currentPeriod;

$totalmegacoGoodAscii += $currentmegacoGoodAscii;


printf "Total (VoIP- Megaco Good Ascii):%.0f\n", ($totalmegacoGoodAscii);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoGoodBinary = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoGoodBinary\"")
    {
        $megacoGoodBinary = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoGoodBinary;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoGoodBinary/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoGoodBinary += $currentmegacoGoodBinary;
        $currentmegacoGoodBinary = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoGoodBinary += $fields[$megacoGoodBinary];
}
my $drops = $currentmegacoGoodBinary/$currentPeriod;

$totalmegacoGoodBinary += $currentmegacoGoodBinary;


printf "Total (VoIP- Megaco Good Binary):%.0f\n", ($totalmegacoGoodBinary);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoMaxContextsExceeded = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoMaxContextsExceeded\"")
    {
        $megacoMaxContextsExceeded = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoMaxContextsExceeded;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoMaxContextsExceeded/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoMaxContextsExceeded += $currentmegacoMaxContextsExceeded;
        $currentmegacoMaxContextsExceeded = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoMaxContextsExceeded += $fields[$megacoMaxContextsExceeded];
}
my $drops = $currentmegacoMaxContextsExceeded/$currentPeriod;

$totalmegacoMaxContextsExceeded += $currentmegacoMaxContextsExceeded;


printf "Total (VoIP- Megaco Max Contexts Exceeded):%.0f\n", ($totalmegacoMaxContextsExceeded);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoStateAllocError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoStateAllocError\"")
    {
        $megacoStateAllocError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoStateAllocError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoStateAllocError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoStateAllocError += $currentmegacoStateAllocError;
        $currentmegacoStateAllocError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoStateAllocError += $fields[$megacoStateAllocError];
}
my $drops = $currentmegacoStateAllocError/$currentPeriod;

$totalmegacoStateAllocError += $currentmegacoStateAllocError;


printf "Total (VoIP- Megaco State Alloc Error):%.0f\n", ($totalmegacoStateAllocError);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoTblInsertError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoTblInsertError\"")
    {
        $megacoTblInsertError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoTblInsertError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoTblInsertError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoTblInsertError += $currentmegacoTblInsertError;
        $currentmegacoTblInsertError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoTblInsertError += $fields[$megacoTblInsertError];
}
my $drops = $currentmegacoTblInsertError/$currentPeriod;

$totalmegacoTblInsertError += $currentmegacoTblInsertError;


printf "Total (VoIP- Megaco Table Insert Error):%.0f\n", ($totalmegacoTblInsertError);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoTblReqAdded = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoTblReqAdded\"")
    {
        $megacoTblReqAdded = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoTblReqAdded;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoTblReqAdded/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoTblReqAdded += $currentmegacoTblReqAdded;
        $currentmegacoTblReqAdded = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoTblReqAdded += $fields[$megacoTblReqAdded];
}
my $drops = $currentmegacoTblReqAdded/$currentPeriod;

$totalmegacoTblReqAdded += $currentmegacoTblReqAdded;


printf "Total (VoIP- Megaco Table Req Added):%.0f\n", ($totalmegacoTblReqAdded);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"  >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoTblReqAllocError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoTblReqAllocError\"")
    {
        $megacoTblReqAllocError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoTblReqAllocError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoTblReqAllocError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoTblReqAllocError += $currentmegacoTblReqAllocError;
        $currentmegacoTblReqAllocError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoTblReqAllocError += $fields[$megacoTblReqAllocError];
}
my $drops = $currentmegacoTblReqAllocError/$currentPeriod;

$totalmegacoTblReqAllocError += $currentmegacoTblReqAllocError;


printf "Total (VoIP- Megaco Table Req Alloc Error):%.0f\n", ($totalmegacoTblReqAllocError);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMegacoStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2"  >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$megacoTblReqRemoved = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"megacoTblReqRemoved\"")
    {
        $megacoTblReqRemoved = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmegacoTblReqRemoved;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmegacoTblReqRemoved/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmegacoTblReqRemoved += $currentmegacoTblReqRemoved;
        $currentmegacoTblReqRemoved = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmegacoTblReqRemoved += $fields[$megacoTblReqRemoved];
}
my $drops = $currentmegacoTblReqRemoved/$currentPeriod;

$totalmegacoTblReqRemoved += $currentmegacoTblReqRemoved;


printf "Total (VoIP- Megaco Table Req Removed):%.0f\n", ($totalmegacoTblReqRemoved);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# VoIP: MGCP Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicVoipMgcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$mgcpCloneError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"mgcpCloneError\"")
    {
        $mgcpCloneError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmgcpCloneError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmgcpCloneError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmgcpCloneError += $currentmgcpCloneError;
        $currentmgcpCloneError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmgcpCloneError += $fields[$mgcpCloneError];
}
my $drops = $currentmgcpCloneError/$currentPeriod;

$totalmgcpCloneError += $currentmgcpCloneError;


printf "Total (VoIP- MGCP Clone Errors):%.0f\n", ($totalmgcpCloneError);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMgcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$mgcpDroppedMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"mgcpDroppedMessages\"")
    {
        $mgcpDroppedMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmgcpDroppedMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmgcpDroppedMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmgcpDroppedMessages += $currentmgcpDroppedMessages;
        $currentmgcpDroppedMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmgcpDroppedMessages += $fields[$mgcpDroppedMessages];
}
my $drops = $currentmgcpDroppedMessages/$currentPeriod;

$totalmgcpDroppedMessages += $currentmgcpDroppedMessages;


printf "Total (VoIP- MGCP Dropped Messages):%.0f\n", ($totalmgcpDroppedMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMgcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$mgcpMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"mgcpMessages\"")
    {
        $mgcpMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmgcpMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmgcpMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmgcpMessages += $currentmgcpMessages;
        $currentmgcpMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmgcpMessages += $fields[$mgcpMessages];
}
my $drops = $currentmgcpMessages/$currentPeriod;

$totalmgcpMessages += $currentmgcpMessages;


printf "Total (VoIP- MGCP Messages):%.0f\n", ($totalmgcpMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipMgcpStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$mgcpTblInsertError = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"mgcpTblInsertError\"")
    {
        $mgcpTblInsertError = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalmgcpTblInsertError;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentmgcpTblInsertError/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalmgcpTblInsertError += $currentmgcpTblInsertError;
        $currentmgcpTblInsertError = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentmgcpTblInsertError += $fields[$mgcpTblInsertError];
}
my $drops = $currentmgcpTblInsertError/$currentPeriod;

$totalmgcpTblInsertError += $currentmgcpTblInsertError;


printf "Total (VoIP- MGCP Table Insert Error):%.0f\n", ($totalmgcpTblInsertError);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# VoIP: SIP Statistics:"
echo "#################################################################################################"
cat `ls -rt ./IicVoipSipStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sipErrors = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sipErrors\"")
    {
        $sipErrors = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsipErrors;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsipErrors/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsipErrors += $currentsipErrors;
        $currentsipErrors = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsipErrors += $fields[$sipErrors];
}
my $drops = $currentsipErrors/$currentPeriod;

$totalsipErrors += $currentsipErrors;


printf "Total (VoIP- SIP Errors):%.0f\n", ($totalsipErrors);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipSipStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sipMsgMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sipMsgMessages\"")
    {
        $sipMsgMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsipMsgMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsipMsgMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsipMsgMessages += $currentsipMsgMessages;
        $currentsipMsgMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsipMsgMessages += $fields[$sipMsgMessages];
}
my $drops = $currentsipMsgMessages/$currentPeriod;

$totalsipMsgMessages += $currentsipMsgMessages;


printf "Total (VoIP- SIP Msg Messages):%.0f\n", ($totalsipMsgMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipSipStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sipMsgNat = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sipMsgNat\"")
    {
        $sipMsgNat = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsipMsgNat;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsipMsgNat/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsipMsgNat += $currentsipMsgNat;
        $currentsipMsgNat = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsipMsgNat += $fields[$sipMsgNat];
}
my $drops = $currentsipMsgNat/$currentPeriod;

$totalsipMsgNat += $currentsipMsgNat;


printf "Total (VoIP- SIP Msg Nat):%.0f\n", ($totalsipMsgNat);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipSipStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sipMsgSigComp = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sipMsgSigComp\"")
    {
        $sipMsgSigComp = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsipMsgSigComp;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsipMsgSigComp/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsipMsgSigComp += $currentsipMsgSigComp;
        $currentsipMsgSigComp = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsipMsgSigComp += $fields[$sipMsgSigComp];
}
my $drops = $currentsipMsgSigComp/$currentPeriod;

$totalsipMsgSigComp += $currentsipMsgSigComp;


printf "Total (VoIP- SIP Msg Sig Comp):%.0f\n", ($totalsipMsgSigComp);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipSipStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sipMsgStun = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sipMsgStun\"")
    {
        $sipMsgStun = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsipMsgStun;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsipMsgStun/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsipMsgStun += $currentsipMsgStun;
        $currentsipMsgStun = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsipMsgStun += $fields[$sipMsgStun];
}
my $drops = $currentsipMsgStun/$currentPeriod;

$totalsipMsgStun += $currentsipMsgStun;


printf "Total (VoIP- SIP Msg Stun):%.0f\n", ($totalsipMsgStun);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipSipStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sipStreamKeepAlives = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sipStreamKeepAlives\"")
    {
        $sipStreamKeepAlives = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsipStreamKeepAlives;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsipStreamKeepAlives/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsipStreamKeepAlives += $currentsipStreamKeepAlives;
        $currentsipStreamKeepAlives = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsipStreamKeepAlives += $fields[$sipStreamKeepAlives];
}
my $drops = $currentsipStreamKeepAlives/$currentPeriod;

$totalsipStreamKeepAlives += $currentsipStreamKeepAlives;


printf "Total (VoIP- SIP Stream KeepAlives):%.0f\n", ($totalsipStreamKeepAlives);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipSipStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sipStreamMessages = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sipStreamMessages\"")
    {
        $sipStreamMessages = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsipStreamMessages;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsipStreamMessages/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsipStreamMessages += $currentsipStreamMessages;
        $currentsipStreamMessages = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsipStreamMessages += $fields[$sipStreamMessages];
}
my $drops = $currentsipStreamMessages/$currentPeriod;

$totalsipStreamMessages += $currentsipStreamMessages;


printf "Total (VoIP- SIP Stream Messages):%.0f\n", ($totalsipStreamMessages);
'

rm -rf ~/myFile

cat `ls -rt ./IicVoipSipStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$sipStreamSigComp = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"sipStreamSigComp\"")
    {
        $sipStreamSigComp = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalsipStreamSigComp;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentsipStreamSigComp/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalsipStreamSigComp += $currentsipStreamSigComp;
        $currentsipStreamSigComp = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentsipStreamSigComp += $fields[$sipStreamSigComp];
}
my $drops = $currentsipStreamSigComp/$currentPeriod;

$totalsipStreamSigComp += $currentsipStreamSigComp;


printf "Total (VoIP- SIP Stream SigComp):%.0f\n", ($totalsipStreamSigComp);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# LTE: IPM (Inter-Processing-Messaging) Statistics:"
echo "#################################################################################################"
cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numIpmFailedSent = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numIpmFailedSent\"")
    {
        $numIpmFailedSent = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumIpmFailedSent;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumIpmFailedSent/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumIpmFailedSent += $currentnumIpmFailedSent;
        $currentnumIpmFailedSent = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumIpmFailedSent += $fields[$numIpmFailedSent];
}
my $drops = $currentnumIpmFailedSent/$currentPeriod;

$totalnumIpmFailedSent += $currentnumIpmFailedSent;


printf "Total (LTE IPM- Num IPM Failed Sent):%.0f\n", ($totalnumIpmFailedSent);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numIpmReceived = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numIpmReceived\"")
    {
        $numIpmReceived = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumIpmReceived;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumIpmReceived/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumIpmReceived += $currentnumIpmReceived;
        $currentnumIpmReceived = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumIpmReceived += $fields[$numIpmReceived];
}
my $drops = $currentnumIpmReceived/$currentPeriod;

$totalnumIpmReceived += $currentnumIpmReceived;


printf "Total (LTE IPM- Num IPM Received):%.0f\n", ($totalnumIpmReceived);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numIpmSent = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numIpmSent\"")
    {
        $numIpmSent = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumIpmSent;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumIpmSent/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumIpmSent += $currentnumIpmSent;
        $currentnumIpmSent = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumIpmSent += $fields[$numIpmSent];
}
my $drops = $currentnumIpmSent/$currentPeriod;

$totalnumIpmSent += $currentnumIpmSent;


printf "Total (LTE IPM- Num IPM Sent):%.0f\n", ($totalnumIpmSent);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numIpmSent = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numIpmSent\"")
    {
        $numIpmSent = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumIpmSent;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumIpmSent/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumIpmSent += $currentnumIpmSent;
        $currentnumIpmSent = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumIpmSent += $fields[$numIpmSent];
}
my $drops = $currentnumIpmSent/$currentPeriod;

$totalnumIpmSent += $currentnumIpmSent;


printf "Total (LTE IPM- Num IPM Sent):%.0f\n", ($totalnumIpmSent);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$s10IpmReceived = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"s10IpmReceived\"")
    {
        $s10IpmReceived = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totals10IpmReceived;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currents10IpmReceived/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totals10IpmReceived += $currents10IpmReceived;
        $currents10IpmReceived = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currents10IpmReceived += $fields[$s10IpmReceived];
}
my $drops = $currents10IpmReceived/$currentPeriod;

$totals10IpmReceived += $currents10IpmReceived;


printf "Total (LTE IPM- S10 IPM Received):%.0f\n", ($totals10IpmReceived);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$s10IpmSent = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"s10IpmSent\"")
    {
        $s10IpmSent = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totals10IpmSent;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currents10IpmSent/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totals10IpmSent += $currents10IpmSent;
        $currents10IpmSent = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currents10IpmSent += $fields[$s10IpmSent];
}
my $drops = $currents10IpmSent/$currentPeriod;

$totals10IpmSent += $currents10IpmSent;


printf "Total (LTE IPM- S10 IPM Sent):%.0f\n", ($totals10IpmSent);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$s1IpmReceived = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"s1IpmReceived\"")
    {
        $s1IpmReceived = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totals1IpmReceived;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currents1IpmReceived/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totals1IpmReceived += $currents1IpmReceived;
        $currents1IpmReceived = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currents1IpmReceived += $fields[$s1IpmReceived];
}
my $drops = $currents1IpmReceived/$currentPeriod;

$totals1IpmReceived += $currents1IpmReceived;


printf "Total (LTE IPM- S1 IPM Received):%.0f\n", ($totals1IpmReceived);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$s1IpmSent = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"s1IpmSent\"")
    {
        $s1IpmSent = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totals1IpmSent;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currents1IpmSent/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totals1IpmSent += $currents1IpmSent;
        $currents1IpmSent = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currents1IpmSent += $fields[$s1IpmSent];
}
my $drops = $currents1IpmSent/$currentPeriod;

$totals1IpmSent += $currents1IpmSent;


printf "Total (LTE IPM- S1 IPM Sent):%.0f\n", ($totals1IpmSent);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$s6IpmReceived = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"s6IpmReceived\"")
    {
        $s6IpmReceived = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totals6IpmReceived;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currents6IpmReceived/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totals6IpmReceived += $currents6IpmReceived;
        $currents6IpmReceived = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currents6IpmReceived += $fields[$s6IpmReceived];
}
my $drops = $currents6IpmReceived/$currentPeriod;

$totals6IpmReceived += $currents6IpmReceived;


printf "Total (LTE IPM- S6 IPM Received):%.0f\n", ($totals6IpmReceived);
'

rm -rf ~/myFile

cat `ls -rt ./LteIpmStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$s6IpmSent = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"s6IpmSent\"")
    {
        $s6IpmSent = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totals6IpmSent;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currents6IpmSent/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totals6IpmSent += $currents6IpmSent;
        $currents6IpmSent = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currents6IpmSent += $fields[$s6IpmSent];
}
my $drops = $currents6IpmSent/$currentPeriod;

$totals6IpmSent += $currents6IpmSent;


printf "Total (LTE IPM- S6 IPM Sent):%.0f\n", ($totals6IpmSent);
'

rm -rf ~/myFile
echo "#################################################################################################"
echo "# LTE Mapper Client Statistics:"
echo "#################################################################################################"
cat `ls -rt ./LteMapperClientStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numRecordCreatesSentToLteMapper = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numRecordCreatesSentToLteMapper\"")
    {
        $numRecordCreatesSentToLteMapper = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumRecordCreatesSentToLteMapper;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumRecordCreatesSentToLteMapper/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumRecordCreatesSentToLteMapper += $currentnumRecordCreatesSentToLteMapper;
        $currentnumRecordCreatesSentToLteMapper = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumRecordCreatesSentToLteMapper += $fields[$numRecordCreatesSentToLteMapper];
}
my $drops = $currentnumRecordCreatesSentToLteMapper/$currentPeriod;

$totalnumRecordCreatesSentToLteMapper += $currentnumRecordCreatesSentToLteMapper;


printf "Total (LTE Mapper Client Stats- Number of Record Creates Sent to LTE Mapper):%.0f\n", ($totalnumRecordCreatesSentToLteMapper);
'

rm -rf ~/myFile

cat `ls -rt ./LteMapperClientStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numRecordUpdatesSentToLteMapper = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numRecordUpdatesSentToLteMapper\"")
    {
        $numRecordUpdatesSentToLteMapper = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumRecordUpdatesSentToLteMapper;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumRecordUpdatesSentToLteMapper/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumRecordUpdatesSentToLteMapper += $currentnumRecordUpdatesSentToLteMapper;
        $currentnumRecordUpdatesSentToLteMapper = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumRecordUpdatesSentToLteMapper += $fields[$numRecordUpdatesSentToLteMapper];
}
my $drops = $currentnumRecordUpdatesSentToLteMapper/$currentPeriod;

$totalnumRecordUpdatesSentToLteMapper += $currentnumRecordUpdatesSentToLteMapper;


printf "Total (LTE Mapper Client Stats- Number of Record Updates Sent to LTE Mapper):%.0f\n", ($totalnumRecordUpdatesSentToLteMapper);
'

rm -rf ~/myFile

cat `ls -rt ./LteMapperClientStats* | tail -1`| perl -e '
$input=<STDIN>;
print $input;

while (($input = <STDIN> ) && $input !~ /$ARGV[0]/ ){}
if ($input =~ /$ARGV[0]/){
    print $input;
    while (($input = <STDIN> ) && $input !~ /$ARGV[1]/) { print $input; }
    print $input;
    while (($input = <STDIN> ) && $input =~ /$ARGV[1]/) { print $input; }
}' "$1" "$2" >  ~/myFile

##############################################################################################
cat ~/myFile | perl -we '
$input=<STDIN>;
chomp($input);
@fields = split ",", $input;
$numRecordsInLteMapperClient = 0;
$period = 0;
$time = 0;
$tmp = 0;
foreach $field (@fields)
{
    if ($field eq "\"numRecordsInLteMapperClient\"")
    {
        $numRecordsInLteMapperClient = $tmp;
    }
    elsif ($field eq "period")
    {
        $period = $tmp;
    }
    elsif ($field eq "time")
    {
        $time = $tmp;
    }
    $tmp++;
}
my $currentTime;
my $currentPeriod;
# my $currentDropCount = 0;
my $totalnumRecordsInLteMapperClient;
my $totalPeriod;
while ($input = <STDIN>)
{
    @fields = split ",", $input;
    if (defined ($currentTime ) && $fields[$time] ne $currentTime)
    {
                my $drops = $currentnumRecordsInLteMapperClient/$currentPeriod;

        $totalPeriod += $currentPeriod;
        $totalnumRecordsInLteMapperClient += $currentnumRecordsInLteMapperClient;
        $currentnumRecordsInLteMapperClient = 0;
    }
    $currentTime = $fields[$time];
    $currentPeriod = $fields[$period] / 1000;
    $currentnumRecordsInLteMapperClient += $fields[$numRecordsInLteMapperClient];
}
my $drops = $currentnumRecordsInLteMapperClient/$currentPeriod;

$totalnumRecordsInLteMapperClient += $currentnumRecordsInLteMapperClient;


printf "Total (LTE Mapper Client Stats- Number of Records In LTE Mapper Client):%.0f\n", ($totalnumRecordsInLteMapperClient);
'



ls -1 /iris/current/config/site/*.plist | sed 's,^,irisplist , ' > getPlist
chmod 755 ./getPlist
sv > myProbeEnvironment.txt
echo "" >> myProbeEnvironment.txt
./getPlist >> myProbeEnvironment.txt

echo "" >> myProbeEnvironment.txt
sleep 1
aui S2dServer-1-1 -c "send S2dServer inventory" >> myProbeEnvironment.txt
sleep 5
