#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./set_time.pl
#     DATE:           March 2005
#     ORGANISATION:   Minacom Labs Inc.
#     AUTHOR:         Eric Lussier
#     LAST MODIF.:    2005/03/31
#     VERSION:        1.0
#
#     PURPOSE
#     -------
#     This script is simply a wrapper script that calls the
#     '/bin/date' command to set the system time.
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

  if ((@ARGV != 1) || ($ARGV[0] !~ /^(\d{2})\:(\d{2})\:(\d{2})$/)) {
    print "ERROR: Command usage is: ./set_time.pl <HH:MM:SS>\n";
  } else {
    my $TIME = $ARGV[0];
    system "/bin/date -s \"$TIME\"";
  }
}
####################################################################
# End of script
####################################################################
