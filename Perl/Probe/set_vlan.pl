#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./set_vlan.pl
#     DATE:           2006/05/13
#     ORGANISATION:   Minacom Labs Inc.
#     AUTHOR:         Eric Lussier
#     LAST MODIF.:    2007/02/08
#     MODIFIED BY:    Eric Lussier
#
#     HISTORY
#     -------
#
#     REV 1.0:  First version of the tool.  This tool enables the
#               creation and deletion of a VLAN.  Once created, a
#               vlan can be modified using the "set_network_if.pl"
#               script.
#
#     REV 1.1:  Added support for DHCP VLANs.
#
#     REV 1.2:  Fixed a little bug in option processing which was
#               accepting an incomplete command usage which, in this
#               case, was creating a VLAN without all the required
#               info.
#
#     REV 1.3:  Changed the name format of interface configuration
#               files to use the "." instead of the ":".  Usage of
#               the semicolon is for aliases ant not VLANs.  Also
#               modified a bit the content of configuration files.
#
#     REV 1.4:  Changed the behavior of the script to create a route
#               with a metric 1 for each VLAN.
#
#     REV 1.5:  Added IP address conflict verification.
#
####################################################################
# Modules
####################################################################
use strict;
use Getopt::Long qw(:config pass_through);
####################################################################
# Constants
####################################################################
use constant VERSION => '1.5';
use constant LASTMOD => 'February 8, 2007';
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
  print "set_vlan.pl [-i|interface INTERFACE] [-a|address ADDRESS]\n";
  print "            [-ne|netmask NETMASK] [-g|gateway GATEWAY]\n";
  print "            [-na|name VLAN_ID] [-dhcp] [-dhost DHCP_HOSTNAME]\n";
  print "            [-s|set] [-c|clear] [-l|list] [-v|version] [-h|help]\n\n";

  print "            [-i|interface]:  Base Ethernet interface to use.\n";
  print "            [-a|address]:    IP address to configure.\n";
  print "            [-ne|netmask]:   IP netmask to configure.\n";
  print "            [-g|gateway]:    Default gateway to configure. (OPTIONAL)\n";
  print "            [-na|name]:      VLAN ID to set, list or clear.\n";
  print "            [-dhcp]:         Configure VLAN to use DHCP.\n";
  print "            [-dhost]:        For dynamic DNS population. (OPTIONAL)\n";
  print "            [-s|set]:        Add VLAN configuration.\n";
  print "            [-c|clear]:      Erase VLAN configuration.\n";
  print "            [-l|list]:       List VLAN configuration.\n";
  print "            [-v|version]:    Print command version.\n";
  print "            [-h|help]:       Print help page.\n\n";

  print "Command usage examples:\n";
  print "-----------------------\n";
  print "- Configure a new static VLAN:\n";
  print "\tset_vlan.pl [-i INTERFACE] [-na VLAN_ID] [-s] [-a ADDRESS] [-ne NETMASK]\n";
  print "- Configure a new dynamic VLAN:\n";
  print "\tset_vlan.pl [-i INTERFACE] [-na VLAN_ID] [-s] [-dhcp]\n";
  print "- Erase an existing VLAN:\n";
  print "\tset_vlan.pl [-i INTERFACE] [-na VLAN_ID] [-c]\n";
  print "- List all VLAN configured:\n";
  print "\tset_vlan.pl [-l]\n";
  print "- List all VLAN configured on the specified interface:\n";
  print "\tset_vlan.pl [-i INTERFACE] [-l]\n";
  print "- Print the detailed configuration of one specific VLAN:\n";
  print "\tset_vlan.pl [-i INTERFACE] [-na VLAN_ID] [-l]\n";
  print "- Display the command version:\n";
  print "\tset_vlan.pl [-v]\n";
  print "- Display the command help page:\n";
  print "\tset_vlan.pl [-h]\n";

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
sub listVLANConfiguration {

  my ($interface, $name) = @_;

  my (@vlan_if_files, $el);
  
  if (defined $interface) {
    if (defined $name) {
      # Printing detailed configuration of one specific VLAN
      my $output = `cat "$cfgpath/ifcfg-$interface.$name"`;
      print "$output";
      return;
    } else {
      # All VLAN configured on the specified base interface will be listed
      @vlan_if_files = glob("$cfgpath/ifcfg-$interface.*");
      foreach $el (@vlan_if_files) {
        $el =~ s/.*ifcfg-(.*)/$1/;
        print "$el\n";
      }
    }
  } else {
    # All VLAN configured will be listed
    @vlan_if_files = glob("$cfgpath/ifcfg-eth?.*");
    foreach $el (@vlan_if_files) {
      $el =~ s/.*ifcfg-(.*)/$1/;
      print "$el\n";
    }
  }
}
####################################################################
sub zapVLANConfiguration {

  my ($interface, $name) = @_;

  unless (-e "/sbin/vconfig") {
    die "ERROR: Couldn't find the vconfig utility in the /sbin directory...";
  }
  
  # Deleting VLAN and its configuration file
  if (-e "$cfgpath/ifcfg-$interface.$name") {
    system("/sbin/vconfig rem $interface.$name");
    unlink "$cfgpath/ifcfg-$interface.$name";
    print "INFO: VLAN '$interface.$name' was erased.\n";
  }
  
  # Removing VLAN default route
  my @file;
  my $file = "/sbin/ifup-local";
  if (-e $file) {
    open (IFUP_LOCAL, $file) || die "ERROR: Couldn't open file '$file' in read mode...";
    while (<IFUP_LOCAL>) {
      push @file, $_ unless ($_ =~ /$interface\.$name/);
    }
    open (IFUP_LOCAL, ">$file") || die "ERROR: Couldn't open file '$file' in write mode...";
    print IFUP_LOCAL @file;
  }
  close IFUP_LOCAL;
}
####################################################################
sub setVLANConfiguration {

  my ($interface, $name, $address, $netmask, $gateway, $dhost) = @_;

  my $file = "$cfgpath/ifcfg-$interface.$name";

  my (@address, @netmask, @network, $network);  
  
  unless (-e "/sbin/vconfig") {
    die "ERROR: Couldn't find the vconfig utility in the /sbin directory...";
  }

  # Writing VLAN configuration file
  open (VLAN_CFG, ">$file") || die "ERROR: Couldn't open file '$file' in write mode...";
  print VLAN_CFG "DEVICE=$interface.$name\n";
  print VLAN_CFG "ONBOOT=yes\n";
  print VLAN_CFG "VLAN=yes\n";
  if ($address =~ /^dhcp$/) {
    print VLAN_CFG "BOOTPROTO=dhcp\n";
    print VLAN_CFG "DHCP_HOSTNAME=$dhost\n" unless (!defined $dhost);
  } else {
    print VLAN_CFG "BOOTPROTO=static\n";
    print VLAN_CFG "IPADDR=$address\n";
    print VLAN_CFG "NETMASK=$netmask\n";
    print VLAN_CFG "GATEWAY=$gateway\n" unless (!defined $gateway);
  }
  close VLAN_CFG;

  # Creating VLAN using the vconfig utility
  system("/sbin/vconfig add $interface $name");

  # Adding default route for VLAN (unless VLAN uses DHCP)
  if ($address !~ /^dhcp$/) {
    $file = "/sbin/ifup-local";
    unless (-e $file) {
      system("/bin/touch $file"); 
      system("/bin/chmod 500 $file");
      open (IFUP_LOCAL, ">$file") || die "ERROR: Couldn't open file '$file' in write mode...";
      print IFUP_LOCAL "#!/bin/bash\n\n";
    } else {
      open (IFUP_LOCAL, ">>$file") || die "ERROR: Couldn't open file '$file' in write mode...";
    }

    # Calculating network address
    @address = split /\./, $address;
    @netmask = split /\./, $netmask;
    @network = (int($address[0]) & int($netmask[0]),
                int($address[1]) & int($netmask[1]),
                int($address[2]) & int($netmask[2]),
                int($address[3]) & int($netmask[3]));
    $network = "$network[0].$network[1].$network[2].$network[3]";
  
    # Erasing VLAN default route added by the vconfig utility called earlier in this function
    sleep 3;
    `/sbin/route del -net $network netmask $netmask metric 0 dev ${interface}.$name`;
  
    # Adding VLAN default route to current routing table
    if (defined $gateway) {
      `/sbin/route add -net $network netmask $netmask gw $gateway metric 1 dev $interface.$name`;
    } else {
      `/sbin/route add -net $network netmask $netmask metric 1 dev $interface.$name`;
    }

    # Printing route commands to interface startup configuration file
    print IFUP_LOCAL "/sbin/route del -net $network netmask $netmask metric 0 dev ${interface}.$name\n";
    if (defined $gateway) {
      print IFUP_LOCAL "/sbin/route add -net $network netmask $netmask gw $gateway metric 1 dev $interface.$name\n";
    } else {
      print IFUP_LOCAL "/sbin/route add -net $network netmask $netmask metric 1 dev $interface.$name\n";
    }
    close IFUP_LOCAL;
  }
  
  # Verifying if IP address is already in use
  my $returnMessage = readpipe("/etc/sysconfig/network-scripts/ifup $interface.$name");
  if ($returnMessage =~ m/ERROR/i) {
    &zapVLANConfiguration($interface, $name);
    print "ERROR: IP conflict or other problem detected.  Couldn't add VLAN '${interface}.$name'.  Exiting...\n";
    exit;
  }
  
  print "INFO: VLAN '${interface}.$name' was created successfully.\n";
}
####################################################################
# MAIN
####################################################################
sub main {

  unless (@ARGV) { &printUsage };

  my ($help, $version, $set, $list, $clear, $interface, $name, $address, $netmask, $gateway, $dhcp, $dhost);

  unless (GetOptions("help"=>\$help, "version"=>\$version, "set"=>\$set, "list"=>\$list, "clear"=>\$clear,
                     "interface=s"=>\$interface, "name=s"=>\$name, "address=s"=>\$address, "netmask=s"=>\$netmask,
                     "gateway=s"=>\$gateway, "dhcp"=>\$dhcp, "dhost=s"=>\$dhost)) { exit };

  # Checking for all bad command usage possibilities
  if ((@ARGV) or 
      ((defined $clear) and (defined $set)) or
      ((defined $clear) and (defined $list)) or
      ((defined $clear) and (defined $address)) or
      ((defined $clear) and (defined $netmask)) or
      ((defined $clear) and (defined $gateway)) or
      ((defined $clear) and (defined $dhcp)) or
      ((defined $clear) and (defined $dhost)) or
      ((defined $clear) and ((!defined $interface) or (!defined $name))) or
      ((defined $list) and (defined $set)) or
      ((defined $list) and (defined $address)) or
      ((defined $list) and (defined $netmask)) or
      ((defined $list) and (defined $gateway)) or
      ((defined $list) and (defined $dhcp)) or
      ((defined $list) and (defined $dhost)) or
      ((defined $dhcp) and (defined $address)) or
      ((defined $dhcp) and (defined $netmask)) or
      ((defined $dhcp) and (defined $gateway)) or
      ((defined $dhcp) and (!defined $interface)) or
      ((defined $address) and (!defined $set)) or
      ((defined $netmask) and (!defined $set)) or
      ((defined $gateway) and (!defined $set)) or
      ((defined $dhost) and (!defined $dhcp)) or
      ((defined $interface) and
        (!((defined $set) or (defined $list) or (defined $clear)))) or
      ((defined $set) and
        ((!defined $interface) or (!defined $name) or
         ((!((defined $address) and (defined $netmask))) and (!defined $dhcp)))) or
      ((defined $name) and
        (!((defined $set) or (defined $clear) or (defined $list))))) {
    # Choice of option(s) is invalid
    print "ERROR: Unknown argument or bad command usage.  Check usage with the -h option.\n";
  } elsif (defined $help) {
    &printUsage;
  } elsif (defined $version) {
    print "set_vlan.pl, version " . VERSION . ", Minacom Labs Inc., " . LASTMOD . ".\n";
  } else {
    # Checking that the interface configuration file exists (if needed)
    if ((defined $set) or (defined $clear)) {
      unless (-e "$cfgpath/ifcfg-$interface") {
        print "ERROR: File '$cfgpath/ifcfg-$interface' does not exist.\n";
        exit 1;
      }
    } else {
      if (defined $name) {
        unless (-e "$cfgpath/ifcfg-$interface.$name") {
          print "ERROR: File '$cfgpath/ifcfg-$interface.$name' does not exist.\n";
          exit 1;
        }
      }
    }
    # Listing VLAN configuration
    if (defined $list) {
      &listVLANConfiguration($interface, $name);
    # Erasing a VLAN configuration
    } elsif (defined $clear) {
      &zapVLANConfiguration($interface, $name);
    # Adding or modifying a VLAN configuration
    } else {
      unless (defined $dhcp) {
        foreach my $el ($address, $netmask, $gateway) { &checkIPsyntax($el) unless (!defined $el) };
      } else {
        $address = "dhcp";
      }
      &zapVLANConfiguration($interface, $name);
      &setVLANConfiguration($interface, $name, $address, $netmask, $gateway, $dhost);
    }
  }
}
####################################################################
# End of script
####################################################################
