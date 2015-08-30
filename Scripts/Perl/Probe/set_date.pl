#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./set_date.pl
#     DATE:           March 2005
#     ORGANISATION:   Minacom Labs Inc.
#     AUTHOR:         Eric Lussier
#     LAST MODIF.:    2005/03/31
#     VERSION:        1.0
#
#     PURPOSE
#     -------
#     This script is simply a wrapper script that calls the
#     '/bin/date' command to set the system date.
#
#     HISTORY
#     -------
#     REV 1.0:  First version of the tool.
#
####################################################################
# Modules
####################################################################
use strict;
####################################################################
&main();
####################################################################
# MAIN
####################################################################
sub main {

  if ((@ARGV != 1) || ($ARGV[0] !~ /^(\d{2})\/(\d{2})\/(\d{4})$/)) {
    print "ERROR: Command usage is: ./set_date.pl <MM/DD/YYYY>\n";
  } else {
    my $DATE = $ARGV[0];
    my $TIME = `date +\"%H:%M:%S\"`;
    chomp $TIME;
    system "/bin/date -s \"$DATE $TIME\"";
  }
}
####################################################################
# End of script
####################################################################
