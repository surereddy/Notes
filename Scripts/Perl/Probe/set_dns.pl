#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./set_dns.pl
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
#     REV 1.1:  Added multiple server capability.
#
#     REV 1.2:  Added the -help, -list, -version and -clear options.
#
#     REV 1.3:  Modified the -help option to be more verbose.
#
####################################################################
# Modules
####################################################################
use strict;
use Getopt::Long qw(:config no_pass_through);
####################################################################
# Constants
####################################################################
use constant VERSION => '1.3';
use constant LASTMOD => 'March 2005';
####################################################################
# GLOBAL VARIABLES
####################################################################
my $nsfile = "/etc/resolv.conf";  # File to contain name servers
#my $nsfile = ".\\resolv.conf";   # File to contain name servers
####################################################################
&main();                                # Running main program
####################################################################
# SUBROUTINES
####################################################################
sub check_quad {

  my $NAMESERVERS_REF = $_[0];

  my $IP_1="1";                         # first nibble of an IP
  my $IP_2="1";                         # second nibble of an IP
  my $IP_3="1";                         # third nibble of an IP
  my $IP_4="1";                         # fourth nibble of an IP

  my (@ALL_NIBBLES_SPACE_SEPARATED, $NB, $cnt);

  for ($cnt=0; $cnt<@$NAMESERVERS_REF; $cnt++) {

    @ALL_NIBBLES_SPACE_SEPARATED = split (/\./, $NAMESERVERS_REF->[$cnt]);
    $NB=@ALL_NIBBLES_SPACE_SEPARATED;

    if ( $NB < 4 || $NB > 4) {
      print "$NAMESERVERS_REF->[$cnt]: Number of nibbles entered = $NB, Need exactly 4 nibbles\n";
      return (0);                       # if bad number of nibbles then return false
    }


    ($IP_1, $IP_2, $IP_3, $IP_4) = split (/\./, $NAMESERVERS_REF->[$cnt]);
    # separates line elements with [.]
    # [.] has to be escaped
    if ( $IP_1 =~ /\D/  || $IP_2 =~ /\D/  || $IP_3 =~ /\D/  || $IP_4 =~ /\D/ ) {
      print "$NAMESERVERS_REF->[$cnt]: One of the nibbles is not a digit, please start again...\n";
      return (0);                       # false
    }


    if ($IP_1<=0 || $IP_1>255 || $IP_2<0  || $IP_2>255 || $IP_3<0  || $IP_3>255 || $IP_4<0  || $IP_4>255) {
      print "$NAMESERVERS_REF->[$cnt]: Not a valid IP address or nibble, please start again...\n";
      return (0);                       # false
    }
  }

  return (1);

}
####################################################################
sub zapNameServers {

  my @nsdata;

  # Reading NSFILE and waving name servers
  open (NSFILE, "$nsfile") || die "ERROR: Couldn't open file '$nsfile' in read mode...";

  $/ = "\n";     # line delimiter is newline (default value)

  while (<NSFILE>) {
    unless (/nameserver/) {
      push @nsdata, $_;
    }
  }

  close NSFILE;

  # Writing NSFILE without name servers
  open (NSFILE, ">$nsfile") || die "ERROR: Couldn't open file '$nsfile' in write mode...";
  print NSFILE @nsdata;
  close NSFILE;

}
####################################################################
sub addNameServers {

  my $NAMESERVERS_REF = $_[0];

  my $cnt;

  open (NSFILE, ">>$nsfile") || die "ERROR: Couldn't open file '$nsfile' in write mode...";

  # Adding name servers
  for ($cnt=0; $cnt<@$NAMESERVERS_REF; $cnt++) {
    print NSFILE "nameserver $NAMESERVERS_REF->[$cnt]\n";
  }

  close NSFILE;

}
####################################################################
sub listNameServers {

  my (@NAMESERVERS_CONFIGURED, $nameserver);

  open (NSFILE, "$nsfile") || die "ERROR: Couldn't open file '$nsfile' in read mode...";

  while (<NSFILE>) {
    if (/nameserver\s+(.*)/) {
      push @NAMESERVERS_CONFIGURED, "$1";
    }
  }

  if (@NAMESERVERS_CONFIGURED) {
    foreach $nameserver (@NAMESERVERS_CONFIGURED) {
      print "NAMESERVER $nameserver\n";
    }
  }
}
####################################################################
sub printUsage {

  print "Command usage\n";
  print "-------------\n";
  print "To set or change name server configuration, use following syntax with no option:\n\n";
  print "\tset_dns.pl <NAMESERVER_1> [<NAMESERVER_2> <...> <NAMESERVER_N>]\n\n";

  print "Command also supports these options (one at a time):\n\n";
  print "           [-h|help]:      Print command usage.\n";
  print "           [-v|version]:   Print script version.\n";
  print "           [-l|list]:      List name server(s) currently configured.\n";
  print "           [-c|clear]:     Erase name server configuration.\n\n";

  exit;

}
####################################################################
# MAIN
####################################################################
sub main {

  unless (@ARGV) { &printUsage };

  my ($help, $version, $list, $clear);

  unless (GetOptions("help"=>\$help, "version"=>\$version, "list"=>\$list, "clear"=>\$clear)) { exit };

  my @NAMESERVERS = @ARGV;

  if (defined $help) {
    &printUsage;
  } elsif ((defined $version || defined $list || defined $clear) && (@NAMESERVERS)) {
    print "ERROR: Mixed option and argument.  Check command usage using the -h option.\n";
  } elsif (defined $version) {
    print "set_dns.pl, version " . VERSION . ", Minacom Labs Inc., " . LASTMOD . ".\n";
  } elsif (defined $list) {
    # Listing all name servers presently configured
    &listNameServers();
  } elsif (defined $clear) {
    # Erasing all name servers presently configured
    &zapNameServers();
  } else {
    # Checking that name server file exists
    unless (-e "$nsfile") {
      print "ERROR: File '$nsfile' does not exist.\n";
    } else {
      # Validating IP address(es) provided on the command line
      if (&check_quad(\@NAMESERVERS)) {
        # Removing name server(s) from configuration file
        &zapNameServers();
        # Configuring name server(s)
        &addNameServers(\@NAMESERVERS);
      }
    }
  }
}
####################################################################
# End of script
####################################################################
