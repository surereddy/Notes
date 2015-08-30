#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./set_network_if.pl
#     DATE:           2006/05/10
#     ORGANISATION:   Minacom Labs Inc.
#     AUTHOR:         Eric Lussier
#     LAST MODIF.:    2006/05/26
#     MODIFIED BY:    Eric Lussier
#
#     HISTORY
#     -------
#
#     REV 1.0:  First version of the tool.  This tool replaces both
#               "set_network_ip.pl" and "set_gateway.pl" scripts.
#               New features are DHCP support and a more explicit
#               "-list" option.
#
#     REV 1.1   To properly support DHCP with dynamic DNS, parameter
#               DHCP_HOSTNAME must be specified in the Ethernet
#               interface configuration file.  This version now
#               provides the "-dhost" option to permit that.
#
####################################################################
# Modules
####################################################################
use strict;
use Getopt::Long qw(:config pass_through);
####################################################################
# Constants
####################################################################
use constant VERSION => '1.1';
use constant LASTMOD => 'May 2006';
####################################################################
# GLOBAL VARIABLES
####################################################################
my $network = "/etc/sysconfig/network";
my $cfgpath = "/etc/sysconfig/network-scripts";
####################################################################
&main();                                # Running main program
####################################################################
# SUBROUTINES
####################################################################
sub printUsage {

  print "Command usage\n";
  print "-------------\n";
  print "set_network_if.pl [-i|interface INTERFACE] [-a|address ADDRESS]\n";
  print "                  [-n|netmask NETMASK] [-g|gateway GATEWAY]\n";
  print "                  [-dhcp] [-dhost DHCP_HOSTNAME] [-l|list]\n";
  print "                  [-c|clear] [-v|version][-h|help]\n\n";

  print "                  [-i|interface]:  Ethernet interface to set, list or clear.\n";
  print "                  [-a|address]:    IP address to configure.\n";
  print "                  [-n|netmask]:    IP netmask to configure.\n";
  print "                  [-g|gateway]:    Default gateway to configure. (OPTIONAL)\n";
  print "                  [-dhcp]:         Configure interface to use DHCP.\n";
  print "                  [-dhost]:        For dynamic DNS population. (OPTIONAL)\n";
  print "                  [-l|list]:       List current configuration.\n";
  print "                  [-c|clear]:      Erase configuration.\n";
  print "                  [-v|version]:    Print command version.\n";
  print "                  [-h|help]:       Print help page.\n\n";

  print "***************************************************************\n";
  print "NOTE: Command can ONLY be used in one of the ways listed below.\n";
  print "***************************************************************\n";
  print "- Ethernet interface will be set to use the specified static configuration:\n";
  print "\tset_network_if.pl [-i INTERFACE] [-a ADDRESS] [-n NETMASK] [-g GATEWAY]\n";
  print "- Same as above, but no default gateway will be configured for this interface:\n";
  print "\tset_network_if.pl [-i INTERFACE] [-a ADDRESS] [-n NETMASK]\n";
  print "- Ethernet interface will be dynamically configured each time it is brought up:\n";
  print "\tset_network_if.pl [-i INTERFACE] [-dhcp]\n";
  print "- Same as above and sending a hostname for dynamic DNS configuration:\n";
  print "\tset_network_if.pl [-i INTERFACE] [-dhcp] [-dhost DHCP_HOSTNAME]\n";
  print "- List the current configuration of the specified Ethernet interface:\n";
  print "\tset_network_if.pl [-i INTERFACE] [-l]\n";
  print "- Delete configuration of the specified Ethernet interface:\n";
  print "\tset_network_if.pl [-i INTERFACE] [-c]\n";
  print "- Display the command version:\n";
  print "\tset_network_if.pl [-v]\n";
  print "- Display the command help page:\n";
  print "\tset_network_if.pl [-h]\n\n";

  exit;
}
####################################################################
sub checkIPsyntax {

  my $address = $_[0];

  unless ($address =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
    die "ERROR: Invalid parameter '$address'.  Nothing was changed.\n";
  }

  foreach my $el ($1, $2, $3, $4) {
    if (($el > 255) || ($el < 0)) {
      die "ERROR: Invalid parameter '$address'.  Nothing was changed.\n";
    }
  }
}
####################################################################
sub listNetworkConfiguration {

  my $interface = $_[0];
  
  # Printing configuration file parameters
  my $output = `cat "$cfgpath/ifcfg-$interface"`;
  print "Interface configuration file:\n";
  print "*****************************\n";
  print "$output\n";
  
  my ($filebuf, $mac, $address, $broadcast, $netmask, $mtu);
  $filebuf = `/sbin/ifconfig $interface`;
  if ($filebuf) {
    ($mac) = $filebuf =~ /.+?HWaddr\s+(\S+)/m;
    ($address) = $filebuf =~ /.+?inet addr:(\S+)/m;
    ($broadcast) = $filebuf =~ /.+?Bcast:(\S+)/m;
    ($netmask) = $filebuf =~ /.+?Mask:(\S+)/m;
    ($mtu) = $filebuf =~ /.+?MTU:(\d+)/m;
    print "Current interface status:\n";
    print "*************************\n";
    if (defined $mac) { print "MACADDR=$mac\n" };
    if (defined $address) { print "IPADDR=$address\n" };
    if (defined $netmask) { print "NETMASK=$netmask\n" };
    if (defined $broadcast) { print "BROADCAST=$broadcast\n" };
    if (defined $mtu) { print "MTU=$mtu\n" };
  }
}
####################################################################
sub zapNetworkConfiguration {

 # This function performs two actions:
  # 1 - Remove the default gateway configured in the "$network" file (if any)
  # 2 - Erase the configuration of the specified Ethernet interface

  my $if_file = "$cfgpath/ifcfg-$_[0]";

  my @filebuf;

  # Action 1: Reading file
  open (NETWORK, $network) || die "ERROR: Couldn't open file '$network' in read mode...";
  while (<NETWORK>) {
    unless (/\s*GATEWAY\s*\=\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*/) { push @filebuf, $_ };
  }
  close NETWORK;

  # Action 1: Writing file
  open (NETWORK, ">$network") || die "ERROR: Couldn't open file '$network' in write mode...";
    print NETWORK @filebuf;
  close NETWORK;

  # Flushing file buffer
  @filebuf = "";

  open (IF_CFG, $if_file) || die "ERROR: Couldn't open file '$if_file' in read mode...";
  while (<IF_CFG>) {
    unless (/IPADDR|NETMASK|GATEWAY|BOOTPROTO|DHCP_HOSTNAME/) { push @filebuf, $_ };
  }
  close IF_CFG;

  # Rewriting interface file, erasing network configuration
  open (IF_CFG, ">$if_file") || die "ERROR: Couldn't open file '$if_file' in write mode...";
  print IF_CFG @filebuf;
  close IF_CFG;
}
####################################################################
sub setNetworkConfiguration {

  my ($interface, $address, $netmask, $gateway, $dhost) = @_;

  my $file = "$cfgpath/ifcfg-$interface";

  open (IF_CFG, ">>$file") || die "ERROR: Couldn't open file '$file' in write mode...";
  # Checking first if the interface is to be configured for DHCP
  if ($address =~ /^dhcp$/) {
    print IF_CFG "BOOTPROTO=dhcp\n";
    print IF_CFG "DHCP_HOSTNAME=$dhost\n" unless (!defined $dhost);
    return;
  } else {
    print IF_CFG "BOOTPROTO=static\n";
  }
  print IF_CFG "IPADDR=$address\n";
  print IF_CFG "NETMASK=$netmask\n";
  print IF_CFG "GATEWAY=$gateway\n" unless (!defined $gateway);
  close IF_CFG;
}
####################################################################
# MAIN
####################################################################
sub main {

  unless (@ARGV) { &printUsage };

  my ($help, $version, $list, $clear, $interface, $address, $netmask, $gateway, $dhcp, $dhost);

  unless (GetOptions("help"=>\$help, "version"=>\$version, "list"=>\$list, "clear"=>\$clear,
                     "interface=s"=>\$interface, "address=s"=>\$address, "netmask=s"=>\$netmask,
                     "gateway=s"=>\$gateway, "dhcp"=>\$dhcp, "dhost=s"=>\$dhost)) { exit };

  # Checking for all bad command usage possibilities
  if ((@ARGV) or 
      ((defined $clear) and (defined $list)) or
      ((defined $clear) and (defined $address)) or
      ((defined $clear) and (defined $netmask)) or
      ((defined $clear) and (defined $gateway)) or
      ((defined $clear) and (defined $dhcp)) or
      ((defined $clear) and (defined $dhost)) or
      ((defined $clear) and (!defined $interface)) or
      ((defined $list) and (defined $address)) or
      ((defined $list) and (defined $netmask)) or
      ((defined $list) and (defined $gateway)) or
      ((defined $list) and (defined $dhcp)) or
      ((defined $list) and (defined $dhost)) or
      ((defined $list) and (!defined $interface)) or
      ((defined $dhcp) and (defined $address)) or
      ((defined $dhcp) and (defined $netmask)) or
      ((defined $dhcp) and (defined $gateway)) or
      ((defined $dhcp) and (!defined $interface)) or
      ((defined $address) and (!defined $interface)) or
      ((defined $netmask) and (!defined $interface)) or
      ((defined $gateway) and (!defined $interface)) or
      ((defined $dhost) and (!defined $dhcp)) or
      ((defined $interface) and
        (!((defined $dhcp) or (defined $list) or (defined $clear)) and
        (!((defined $netmask) and (defined $address)))))) {
    # Choice of option(s) is invalid
    print "ERROR: Unknown argument or bad command usage.  Check usage with the -h option.\n";
  } elsif (defined $help) {
    &printUsage;
  } elsif (defined $version) {
    print "set_network_if.pl, version " . VERSION . ", Minacom Labs Inc., " . LASTMOD . ".\n";
  } else {
    # Checking that the interface configuration file exists
    unless (-e "$cfgpath/ifcfg-$interface") {
      print "ERROR: File '$cfgpath/ifcfg-$interface' does not exist.\n";
    } else {
      # Listing interface configuration
      if (defined $list) {
        &listNetworkConfiguration($interface);
      # Clearing interface configuration
      } elsif (defined $clear) {
        &zapNetworkConfiguration($interface);
      # Configuring the network interface
      } else {
        unless (defined $dhcp) {
          foreach my $el ($address, $netmask, $gateway) { &checkIPsyntax($el) unless (!defined $el) };
        } else {
          $address = "dhcp";
        }
        &zapNetworkConfiguration($interface);
        &setNetworkConfiguration($interface, $address, $netmask, $gateway, $dhost);
      }
    }
  }
}
####################################################################
# End of script
####################################################################
