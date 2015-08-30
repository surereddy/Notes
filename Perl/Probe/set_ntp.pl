#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./set_ntp.pl
#     DATE:           2005/02/04
#     ORGANISATION:   Minacom Labs Inc.
#     AUTHOR:         Joel Leclerc
#     MODIFIED BY:    Eric Lussier
#     LAST MODIF.:    2005/03/23
#
#     HISTORY
#     -------
#
#     REV 1.0:  First version of the tool.
#
#     REV 1.1:  Added the -list and -help options and multiple NTP
#               servers capability.
#
#     REV 1.2:  Added the -version option and name support (NTP
#               servers can now be specified either by name or IP).
#
#     REV 1.3:  Added the -clear option.  Modified the zapNtpServers
#               function to reflect the change.
#
#     REV 1.4:  Added the -sync option and modified the -help option
#               to be more verbose.  Modified the ntpdate command to
#               use the -u switch by default.
#
####################################################################
# Modules
####################################################################
use strict;
use Getopt::Long qw(:config no_pass_through);
####################################################################
# Constants
####################################################################
use constant VERSION => '1.4';
use constant LASTMOD => 'March 2005';
####################################################################
# GLOBAL VARIABLES
####################################################################
my $cronfile = "/var/spool/cron/root";
my $logfile = "/var/log/ntp/ntpdate.log";
#my $cronfile = ".\\root";
#my $logfile = ".\\ntpdate.log";
####################################################################
&main();                                # Running main program
####################################################################
# SUBROUTINES
####################################################################
sub zapNtpServers {

  my @crondata;

  # Reading CRON file and waving NTP servers
  open (CRONFILE, "$cronfile") || die "ERROR: Couldn't open file '$cronfile' in read mode...";

  while (<CRONFILE>) {
    unless (/ntpdate/) {
      push @crondata, $_;
    }
  }

  close CRONFILE;

  # Writing CRON file without NTP servers
  open (CRONFILE, ">$cronfile") || die "ERROR: Couldn't open file '$cronfile' in write mode...";
  print CRONFILE @crondata;
  close CRONFILE;

}
####################################################################
sub addNtpServers {

  my $NTPSERVERS_REF = $_[0];

  my $time_cnt;     # variable used to compute NTP syncro runtime
  my $cnt;

  open (CRONFILE, ">>$cronfile") || die "ERROR: Couldn't open file '$cronfile' in write mode...";

  # Adding NTP servers
  for ($cnt=0; $cnt<@$NTPSERVERS_REF; $cnt++) {
    $time_cnt = 0 + ($cnt * 5);
    print CRONFILE "$time_cnt 1 * * * /usr/sbin/ntpdate $NTPSERVERS_REF->[$cnt] >> $logfile\n";
  }

  close CRONFILE;

}
####################################################################
sub syncronize {

  my (@NTPSERVERS_CONFIGURED, $ntpserver, $cnt);

  open (CRONFILE, "$cronfile") || die "ERROR: Couldn't open file '$cronfile' in read mode...";

  while (<CRONFILE>) {
    if (/ntpdate\s+(\S+)/) {
      push @NTPSERVERS_CONFIGURED, "$1";
    }
  }

  if (@NTPSERVERS_CONFIGURED) {
    foreach $ntpserver (@NTPSERVERS_CONFIGURED) {
      system("/usr/sbin/ntpdate -u $ntpserver >> $logfile 2>&1");
    }
  }

  close CRONFILE;

}
####################################################################
sub listNtpServers {

  my (@NTPSERVERS_CONFIGURED, $ntpserver);

  open (CRONFILE, "$cronfile") || die "ERROR: Couldn't open file '$cronfile' in read mode...";

  while (<CRONFILE>) {
    if (/ntpdate\s+(\S+)/) {
      push @NTPSERVERS_CONFIGURED, "$1";
    }
  }

  if (@NTPSERVERS_CONFIGURED) {
    foreach $ntpserver (@NTPSERVERS_CONFIGURED) {
      print "NTPSERVER $ntpserver\n";
    }
  }
}
####################################################################
sub printUsage {

  print "Command usage\n";
  print "-------------\n";
  print "To set or change NTP server configuration, use following syntax with no option:\n\n";
  print "\tset_ntp.pl <NTPSERVER_1> [<NTPSERVER_2> <...> <NTPSERVER_N>]\n\n";

  print "Command also supports these options (one at a time):\n\n";
  print "           [-h|help]:      Print command usage.\n";
  print "           [-v|version]:   Print script version.\n";
  print "           [-l|list]:      List NTP server(s) currently configured.\n";
  print "           [-c|clear]:     Erase NTP server configuration.\n";
  print "           [-s|sync]:      Synchronize now with current NTP configuration.\n\n";

  exit;

}  
####################################################################
# MAIN
####################################################################
sub main {

  unless (@ARGV) { &printUsage };

  my ($help, $version, $list, $clear, $sync);

  unless (GetOptions("help"=>\$help, "version"=>\$version, "list"=>\$list, "clear"=>\$clear, "sync"=>\$sync)) { exit };

  my @NTPSERVERS = @ARGV;

  if (defined $help) {
    &printUsage;
  } elsif ((defined $version || defined $list || defined $clear || defined $sync) && (@NTPSERVERS)) {
    print "ERROR: Mixed option and argument.  Check command usage using the -h option.\n";
  } elsif (defined $version) {
    print "set_ntp.pl, version " . VERSION . ", Minacom Labs Inc., " . LASTMOD . ".\n";
  } elsif (defined $list) {
    # Listing all NTP servers presently configured
    &listNtpServers();
  } elsif (defined $clear) {
    # Erasing all NTP servers presently configured
    &zapNtpServers();
  } elsif (defined $sync) {
    # Synchronize time with NTP servers currently configured
    &syncronize(\@NTPSERVERS);
  } else {
    # Checking that cron file exists
    unless (-e "$cronfile") {
      print "ERROR: File '$cronfile' does not exist.\n";
    } else {
      # Removing NTP server(s) from crontab file
      &zapNtpServers();
      # Configuring NTP server(s)
      &addNtpServers(\@NTPSERVERS);
    }
  }
}
####################################################################
# End of script
####################################################################
