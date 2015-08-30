#!/usr/bin/perl -w
####################################################################
#
#     CALL:           ./set_hostname.pl
#     DATE:           2005/02/04
#     ORGANISATION:   Minacom Labs Inc.
#     AUTHOR:         Joel Leclerc
#     MODIFIED BY:    Eric Lussier
#     LAST MODIF.:    2005/04/13
#     VERSION:        1.1
#
#     HISTORY
#     -------
#
#     REV 1.0:  First version of the tool.
#
#     REV 1.1:  Added the -h and -v options.
#
####################################################################
# Modules
####################################################################
use strict;
use Getopt::Long qw(:config no_pass_through);
####################################################################
# Constants
####################################################################
use constant VERSION => '1.1';
use constant LASTMOD => 'April 2005';
####################################################################
&main();
####################################################################
# SUBROUTINES
####################################################################
sub printUsage {

  print "Command usage is: set_hostname.pl <HOSTNAME>\n\n";

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
    print "set_hostname.pl, version " . VERSION . ", Minacom Labs Inc., " . LASTMOD . ".\n";
  } else {
    # Checking that only one argument has been provided on the command line
    unless (@ARGV == 1) { &printUsage };

    my $HOSTNAME = $ARGV[0];

    my (@files, @file, $file);

    # Checking that both required configuration files exists
    @files = ("/etc/sysconfig/network", "/etc/hosts");
    foreach $file (@files) {
      unless (-e $file) {
        print "ERROR: Required file '$file' doesn't exists.  Exiting...\n";
        exit;
      }
    }

    # Changing hostname in first configuration file...
    $file = "/etc/sysconfig/network";
    open FILE, "$file" or die "ERROR: Couldn't open file '$file' in read mode...";
    while (<FILE>) {
      unless ($_ =~ /HOSTNAME\=/) {
        push @file, $_;
      }
    }

    push @file, "HOSTNAME=$HOSTNAME\n";
    close FILE;

    open FILE, ">$file" or die "ERROR: Couldn't open file '$file' in write mode...";
    print FILE @file;
    close FILE;

    @file = "";

    # Changing hostname in second configuration file...
    $file = "/etc/hosts";
    open FILE, "$file" or die "ERROR: Couldn't open file '$file' in read mode...";
    while (<FILE>) {
      unless ($_ =~ /127\.0\.0\.1/) {
        push @file, $_;
      }
    }

    push @file, "127.0.0.1\t$HOSTNAME\n";
    close FILE;

    open FILE, ">$file" or die "ERROR: Couldn't open file '$file' in write mode...";
    print FILE @file;
    close FILE;
  }
}
####################################################################
# End of script
####################################################################
