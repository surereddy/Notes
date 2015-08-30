#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./set_timezone.pl
#     DATE:           2005/02/04
#     ORGANISATION:   Minacom Labs Inc.
#     AUTHOR:         Joel Leclerc
#     MODIFIED BY:    Eric Lussier
#     LAST MODIF.:    2005/04/13
#     VERSION:        1.2
#
#     HISTORY
#     -------
#
#     REV 1.0:  First version of the tool.
#
#     REV 1.1:  The tool now relies on the command 'timeconfig'
#               rather than the 'replace_line.pl' script.
#
#     REV 1.2:  Added the -h and -v options.
#
####################################################################
# Modules
####################################################################
use strict;
use Getopt::Long qw(:config no_pass_through);
####################################################################
# Constants
####################################################################
use constant VERSION => '1.2';
use constant LASTMOD => 'April 2005';
####################################################################
# GLOBAL VARIABLES
####################################################################
my $zoneinfoDir = "/usr/share/zoneinfo";
####################################################################
&main();
####################################################################
# SUBROUTINES
####################################################################
sub printUsage {

  print "Command usage is: set_timezone.pl <TIMEZONE>\n\n";

  print "Command also supports these options (one at a time):\n\n";
  print "           [-h|help]:      Print command usage.\n";
  print "           [-v|version]:   Print script version.\n\n";

  exit;
}
####################################################################
# MAIN
####################################################################
sub main {

  unless (@ARGV) { &printUsage };

  my ($help, $version);

  unless (GetOptions("help"=>\$help, "version"=>\$version)) { exit };

  if (defined $help) {
    &printUsage;
  } elsif (defined $version) {
    print "set_timezone.pl, version " . VERSION . ", Minacom Labs Inc., " . LASTMOD . ".\n";
  } else {
    # Checking that only one argument has been provided on the command line
    unless (@ARGV == 1) { &printUsage };

    my $TIMEZONE = $ARGV[0];

    if (-e "/usr/share/zoneinfo/$TIMEZONE") {
      system("/usr/sbin/timeconfig $TIMEZONE");
    } else {
      print "ERROR: Time zone file '$zoneinfoDir/$TIMEZONE' doesn't exist.\n";
    }
  }
}
####################################################################
# End of script
####################################################################
