#!/usr/bin/perl
use Socket;
my $proto=getprotobyname("tcp"); 
#print $proto;
my $temp;
my $temp2;

#chomp
sub test_chomp{
$\="\r\n";
my $var1="line 1\r\n";
my $var2="line 2\r\n";
print "var1(Before) is:\r\n$var1";
chomp($var1);
print "var1(After chomp) is:\r\n$var1";
my $var=$var1."\r\n".$var2;
print "var1 is:\r\n$var1";
print "var is:\r\n$var";
}



#
sub test_multiLine_string{
my $string=qq~ 
##########
line 1
line 2
##########
~; 
print $string;
undef $string;

	}

sub test_regular_expression{
print "Inside regular begins.\r\n";
 my $ip='';
 my $a='';
 $a='ip=172.24.252.246';
 print $a;
		 #if($a=~/^ip=.*/) # OK. if $a is 'ip=' leading
		 if($a=~/ip=/) # OK. if $a is 'ip=' leading
		 {
		 	$a=~s/ip=//; #replace 'ip=' with none in $a and assaign the result back to $a 
		 	$ip=$a;
		 }
 print $ip;
 undef $ip;
 undef $a;
print "\r\nInside regular ends.\r\n";
	}


##############
#Main function start here!
##############
#test_regular_expression();	
$temp=100;
$temp2=~$temp; # not work

print $temp;
print $temp2;

print "\r\nBefore sleep of 3s.\r\n";

sleep(3);

print "End\r\n";