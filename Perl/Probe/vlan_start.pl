#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./vlan_start.pl
#     DATE:           2006/11/10
#     ORGANISATION:   Minacom Labs Inc.
#     AUTHOR:         Eric Lussier
#     LAST MODIF.:    
#     MODIFIED BY:    
#
#     HISTORY
#     -------
#
#     REV 1.0:  First version of the tool.  This tool brings all
#               vlan interfaces up and is called at boot.
#
####################################################################
# Modules
####################################################################
use strict;
use Getopt::Long qw(:config pass_through);
####################################################################
# Constants
####################################################################
use constant VERSION => '1.0';
use constant LASTMOD => 'November 2006';
####################################################################
# GLOBAL VARIABLES
####################################################################
my $cfgpath = "/etc/sysconfig/network-scripts";
####################################################################
&main();
####################################################################
# SUBROUTINES
####################################################################
sub printUsage {

  print "Command usage\n";
  print "-------------\n";
  print "vlan_start.pl [-v|version] [-h|help]\n\n";

  print "              [-v|version]:    Print command version.\n";
  print "              [-h|help]:       Print help page.\n\n";

  print "************************************************\n";
  print "NOTE: This script does not require any argument.\n";
  print "************************************************\n";

  exit;
}
####################################################################
sub start_vlan {

  my (@vlans, $vlan);

  @vlans = glob("$cfgpath/ifcfg-eth?.*");
  
  if (@vlans) {
    unless (-e "/sbin/vconfig") {
      die "ERROR: Couldn't find the vconfig utility in the /sbin directory...";
    }
    foreach $vlan (@vlans) {
      $vlan =~ /\S+ifcfg\-(eth\S+)\.(\S+)/;
      system("/sbin/vconfig add $1 $2");
    }
  }
}
####################################################################
# MAIN
####################################################################
sub main {

  my ($help, $version);

  GetOptions("help"=>\$help, "version"=>\$version);
  
  if (defined $help) {
    &printUsage();
  } elsif (defined $version) {
    print "vlan_start.pl, version " . VERSION . ", Minacom Labs Inc., " . LASTMOD . ".\n";
  } else {
    &start_vlan();
  }
}
####################################################################
# End of script
####################################################################
