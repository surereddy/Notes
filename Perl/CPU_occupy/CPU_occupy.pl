#!/usr/bin/perl
##########################
# This script will occupy about 97% percent CPU resource.
# Use contrl+c or kill to end the process, or wait until the repetition ends which takes about 1 hour with max_number=1000000.
# 
##########################

#occupy CPU by endless repetition
sub occupy_cpu{
#`touch occupy_cpu_tempfile.txt`;
`echo "Repetition starts...\r\n">occupy_cpu_tempfile.txt`;
my $var=0;
my $i;
my $number_recreat_file=10000; # Don't change unless you know its usage.
my $max_number=1000000;#10000000;
for ($var=1;$var<$max_number;$var+=1)
{
#$var=$var+1;
#if(1)
if($var%$number_recreat_file==0) # if $a is 'ip=' leading
 {
 `echo "New file from $var .\r\n">occupy_cpu_tempfile.txt`;
 }

`echo "$var\r\n">>occupy_cpu_tempfile.txt`;
}

`echo Repetition ends.>>occupy_cpu_tempfile.txt`;
print "Repetition ends.\r\n";
}

occupy_cpu();

#sleep(3);

print "End of perl script.\r\n";