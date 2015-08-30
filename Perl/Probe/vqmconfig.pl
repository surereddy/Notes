#!/usr/bin/perl
###############################################################################
#
# PROGRAM       vqmconfig.pl
# AUTHOR        Eric Lussier
# DATE          November 24, 2006
# LAST MOD. BY  Eric Lussier
# LAST MODIF.   January 26, 2007
#
#
# DESCRIPTION   This program was written to enable the DirectQuality web
#               interface to configure the Minacom test modules located
#               inside all PowerProbe's flavors.  This will let DirectQuality
#               users modify the configuration and behavior of the modules on
#               the fly rather than requiring a customer support engineer to
#               log into each probe individually and make the changes.
#
# HISTORY       VERSION 1.0 - November 24, 2006
#
#               VERSION 1.1 - January 5, 2007
#               Bug fixes.
#
#               VERSION 1.2 - January 19, 2007
#               CAS support & modifications to the structure to accept more
#               command-line switch combinations.
#
#               VERSION 1.3 - January 26, 2007
#               Bug fixes.  Structure modifications.  Removed the '-prm' and
#               '-prm2' options.
#
###############################################################################
# MODULES
###############################################################################
use strict;
use warnings;
use Getopt::Long qw(:config no_pass_through);
###############################################################################
# CONSTANTS
###############################################################################
use constant VERSION => '1.3';
use constant LASTMOD => 'January 26, 2007';
###############################################################################
&main();
###############################################################################
# SUBROUTINES
###############################################################################
sub printUsage {
  print "\n";
  print "COMMAND USAGE\n";
  print "-------------\n";
  print "This script has two run modes: VIEW and EDIT.\n\n";

  print "When no option is provided, it runs in VIEW mode and returns the current configuration\n";
  print "of all supported test modules.  If the switch '-set' is provided, then the script runs\n";
  print "in EDIT mode and apply changes to the specified test module.\n\n";

  print "NOTES\n";
  print "-----\n";
  print "- Only one test module can be modified at a time.\n";
  print "- Option value 'DELETE' can be specified with most options.\n\n";

  print "GENERAL OPTIONS\n";
  print "---------------\n";
  print "[-help]:     Print command usage.\n";
  print "[-version]:  Print script version.\n";
  print "[-set]:      Run in edit mode.\n\n";

  print "DIGITAL MODULE PARAMETERS - GENERIC\n";
  print "-----------------------------------\n";
  print "[-gpcm <ALAW,ULAW,AUTOMATIC>]:  Encoding scheme.\n";
  print "[-logfile <log_filename>]:      Test module log filename.\n\n";

  print "DIGITAL MODULE CONFIGURATION - BOARD\n";
  print "------------------------------------\n";
  print "[-id    <Hex Digit - 0 to F>]:  Test module ID to modify.\n";
  print "[-ecr   <ON,OFF>]:              Echo cancellation resource.\n";
  print "[-pcm   <ALAW,ULAW,AUTOMATIC>]: Encoding scheme.\n";
  print "[-pro   <protocol1>]:           ISDN protocol or CAS.\n";
  print "[-fwl   <fwlfile1>]:            Firmware load.\n";
  print "[-crc   <ON,OFF>]:              G.703 framing CRC4.\n";
  print "[-type  <CAS,PRI>]:             Protocol type.\n";
  print "[-form  <D4,ESF>]:              Framing format.\n";
  print "[-zero  <NONE,B8ZS,BIT7>]:      Zero code suppression.\n";
  print "[-pro2  <protocol2>]:           ISDN protocol or CAS (2nd span of dual span boards only).\n";
  print "[-fwl2  <fwlfile2>]:            Firmware load (2nd span of dual span boards only).\n";
  print "[-crc2  <ON,OFF>]:              G.703 framing CRC4 (2nd span of dual span boards only).\n";
  print "[-type2 <CAS,PRI>]:             Protocol type (2nd span of dual span boards only).\n";
  print "[-form2 <D4,ESF>]:              Framing format (2nd span of dual span boards only).\n";
  print "[-zero2 <NONE,B8ZS,BIT7>]:      Zero code suppression (2nd span of dual span boards only).\n";
  print "\n";
}
###############################################################################
sub buildProtocolStruct {

  my (%SIGprotocols, %supportedParameters);

  %SIGprotocols = ('NONE',  'No ISDN protocol is used',
                   'CAS',   'Channel Associated Signaling',
                   '1TR6',  'German National ISDN',
                   '4ESS',  'AT&T 4ESS custom switch TR41449/TR41459',
                   '5ESS',  'AT&T 5ESS custom switch 505-900-322',
                   'CTR4',  'EURO-ISDN ETSI300-102',
                   'DASS2', 'British National BTNR-190-1985',
                   'DMS',   'Northern Telecom custom switch A211-1 and A211-4',
                   'DPNSS', 'British Private Branch Exchange DASS2 extension',
                   'ETN',   'EURO-ISDN ETSI300-102 for T1',
                   'ETU',   'EURO-ISDN ETSI300-102 for T1',
                   'NE1',   'EURO-ISDN ETSI300-102',
                   'NI2',   'National ISDN-2 Bellcore Special Report SR-NWT-002343',
                   'NT1',   'T1 Network Emulation TR41449/TR41459',
                   'NTT',   'Japanese National ISDN INS-Net 1500',
                   'QNT',   'Q.SIG ISO 11572, ISO 11574',
                   'QTE',   'Q.SIG ISO 11572, ISO 11574',
                   'QTN',   'Q.SIG ECMA-142/143 for T1',
                   'QTU',   'Q.SIG ECMA-142/143 for T1',
                   'TPH',   'Australian National ISDN TS-0141 1990',
                   'TPHNT', 'Australian National ISDN TS-0141 1990',
                   'VN',    'French National ISDN VN3',
                   'VNNT',  'French National ISDN VN3 (Network Termination)');

  %supportedParameters = ('NONE' => {},
                          'CAS' => {
                            'CRC4' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },                            
                          '1TR6' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          '4ESS' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          '5ESS' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'CTR4' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'DASS2' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'DMS' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'DPNSS' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'ETN' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'ETU' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'NE1' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'NI2' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'NT1' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'NTT' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'QNT' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'QTE' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'QTN' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'QTU' => {
                            'TYPE' => undef,
                            'FORM' => undef,
                            'ZERO' => undef
                          },
                          'TPH' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'TPHNT' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'VN' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          },
                          'VNNT' => {
                            'CRC4' => undef,
                            'TYPE' => undef
                          });

  return (\%SIGprotocols, \%supportedParameters);
}
###############################################################################
sub printProtocols {

  my %SIGprotocols = %{$_[0]};

  print "Supported ISDN-T1/E1 protocols\n";
  print "------------------------------\n";
  foreach (sort keys %SIGprotocols) {
    if (length() <= 5) {
      print "${_}\t$SIGprotocols{$_}\n";
    } else {
      print "${_}$SIGprotocols{$_}\n";
    }
  }

  print "\n";
}
###############################################################################
sub printVersion {

  print "vqmconfig.pl, version ". VERSION . ", Minacom Labs Inc., " . LASTMOD . ".\n";
  exit;
}
###############################################################################
sub viewConfig {

  my $cfg_pt = $_[0];

  my (@logfile, $logfile, $k1, $k2, $k3);

  # Printing configuration structure
  print "******************************\n";
  print "TEST MODULE CONFIGURATION FILE\n";
  print "******************************\n";
  foreach $k1 (sort keys %$cfg_pt) {
    if (($k1 eq 'GENERIC') or (defined $$cfg_pt{$k1}->{'BoardType'})) {
      print "$k1 CONFIGURATION\n";
      foreach $k2 (sort keys %{$cfg_pt->{$k1}}) {
        if ($k2 =~ /ProtocolParameters|ProtocolParameters2/) {
          foreach $k3 (sort keys %{$cfg_pt->{$k1}{$k2}}) {
            if (defined $cfg_pt->{$k1}{$k2}{$k3}) {
               print "${k2}_$k3\=$cfg_pt->{$k1}{$k2}{$k3}\n";
            }
          }
        } else {
          if (defined $cfg_pt->{$k1}{$k2}) {
            print "$k2\=$cfg_pt->{$k1}{$k2}\n";
          }
        }
      }
    }
    print "\n";
  }
  
  # Printing the Dialogic drivers startup log file
  print "********************\n";
  print "TEST MODULE LOG FILE\n";
  print "********************\n";
  if ($$cfg_pt{'GENERIC'}{'LogFile'} =~ /\//) {
    $logfile = "$$cfg_pt{'GENERIC'}{'LogFile'}";
  } else {
    $logfile = "/usr/dialogic/log/" . $$cfg_pt{'GENERIC'}{'LogFile'};
  }
  open (LOGFILE, $logfile) || die "ERROR: Couldn't open file '$logfile' in read mode...";
  @logfile = <LOGFILE>;
  print @logfile;
  close LOGFILE;

  exit;
}
###############################################################################
sub updateConfigStruct {

  my ($cfg_pt, $supportedParameters_pt, $gpcm, $logfile, $id, $ecr, $pcm, $fwl, $fwl2, $pro, $pro2, $crc,
      $type, $form, $zero, $crc2, $type2, $form2, $zero2, $SIGprotocols_pt) = @_;
      
  # Tracing protocol parameter changes
  my $ppflag = 0;
  
  # Parsing GENERIC options
  if (defined $gpcm) {
    if (($gpcm eq 'ALAW') or ($gpcm eq 'ULAW') or ($gpcm eq 'AUTOMATIC') or ($gpcm eq 'DELETE')) {
      $$cfg_pt{'GENERIC'}{'PCMEncoding'} = $gpcm;
    } else {
      print "ERROR: Valid PCM values are: ULAW, ALAW, AUTOMATIC.\n";
      exit;
    }
  }
  if (defined $logfile) {
    $$cfg_pt{'GENERIC'}{'LogFile'} = $logfile;
  }
  
  # Parsing test module options
  if (((defined $ecr) or (defined $pcm) or (defined $fwl) or (defined $fwl2) or (defined $pro) or (defined $pro2) or
       (defined $crc) or (defined $type) or (defined $form) or (defined $zero) or (defined $crc2) or (defined $type2) or
       (defined $form2) or (defined $zero2)) and (!defined $id)) {
    print "ERROR: Test module to modify must be specified with option -id.\n";
    exit;
  } elsif (defined $id) {
    if (($id ne '0') and ($id ne '1') and ($id ne '2') and ($id ne '3') and
        ($id ne '4') and ($id ne '5') and ($id ne '6') and ($id ne '7') and
        ($id ne '8') and ($id ne '9') and ($id ne 'A') and ($id ne 'B') and
        ($id ne 'C') and ($id ne 'D') and ($id ne 'E') and ($id ne 'F')) {
      print "ERROR: Valid ID values are hexadecimal numbers from 0 to F.\n";
      exit;
    }
    
    # Valid ID number was provided.  Building valid hash ref key
    $id = "ID$id";

    # Parsing edit mode switches...
    if (defined $ecr) {
      if (($ecr eq 'ON') or ($ecr eq 'OFF') or ($ecr eq 'DELETE')) {
        $$cfg_pt{$id}{'EC_Resource'} = $ecr;
      } else {
        print "ERROR: Valid ECR values are: ON, OFF.\n";
        exit;
      }
    }
    if (defined $pcm) {
      if (($pcm eq 'ULAW') or ($pcm eq 'ALAW') or ($pcm eq 'AUTOMATIC') or ($pcm eq 'DELETE')) {
        $$cfg_pt{$id}{'PCMEncoding'} = $pcm;
      } else {
        print "ERROR: Valid PCM values are: ULAW, ALAW, AUTOMATIC.\n";
        exit;
      }
    }
    if (defined $fwl) {
      $$cfg_pt{$id}{'FirmwareFile'} = $fwl;
    }
    if (defined $fwl2) {
      $$cfg_pt{$id}{'FirmwareFile2'} = $fwl2;
    }
    if (defined $pro) {
      if (($pro eq 'DELETE') and ((defined $crc) or (defined $type) or defined ($form) or (defined $zero))) {
        print "ERROR: You can either set OR delete a protocol.  Please specify the new protocol to set instead.\n";
        exit;
      } elsif ($pro eq 'CAS') {
        $$cfg_pt{$id}{'ParameterFile'} = 'spandti.prm';
        $$cfg_pt{$id}{'ISDNProtocol'} = 'CAS';
      } elsif (($pro eq 'DELETE') or ($pro eq 'NONE')) {
        $$cfg_pt{$id}{'ISDNProtocol'} = $pro;
      } else {
        if (exists $SIGprotocols_pt->{$pro}) {
          $$cfg_pt{$id}{'ISDNProtocol'} = $pro;
          $$cfg_pt{$id}{'ParameterFile'} = lc($pro) . ".prm";
        } else {
          print "ERROR: Protocol '$pro' isn't supported.  Please use switch '-h' to list supported protocols.\n";
          exit;
        }
      }
    } elsif ((defined $cfg_pt->{$id}{'ParameterFile'}) and ($cfg_pt->{$id}{'ParameterFile'} =~ /spandti/)) {
      $$cfg_pt{$id}{'ISDNProtocol'} = 'CAS';
    }
    if (defined $pro2) {
      if (($pro2 eq 'DELETE') and ((defined $crc2) or (defined $type2) or defined ($form2) or (defined $zero2))) {
        print "ERROR: You can either set OR delete a protocol.  Please specify the new protocol to set instead.\n";
        exit;
      } elsif ($pro2 eq 'CAS') {
        $$cfg_pt{$id}{'ParameterFile2'} = 'spandti.prm';
        $$cfg_pt{$id}{'ISDNProtocol2'} = 'CAS';
      } elsif (($pro2 eq 'DELETE') or ($pro2 eq 'NONE')) {
        $$cfg_pt{$id}{'ISDNProtocol2'} = $pro2;
      } else {
        if (exists $SIGprotocols_pt->{$pro2}) {
          $$cfg_pt{$id}{'ISDNProtocol2'} = $pro2;
          $$cfg_pt{$id}{'ParameterFile2'} = lc($pro2) . ".prm";
        } else {
          print "ERROR: Protocol '$pro2' isn't supported.  Please use switch '-h' to list supported protocols.\n";
          exit;
        }
      }
    } elsif ((defined $cfg_pt->{$id}{'ParameterFile2'}) and ($cfg_pt->{$id}{'ParameterFile2'} =~ /spandti/)) {
      $$cfg_pt{$id}{'ISDNProtocol2'} = 'CAS';
    }
    
    # Checking protocol parameter switches
    $ppflag++ if ((defined $crc) or (defined $type) or (defined $form) or (defined $zero));
    $ppflag += 2 if ((defined $crc2) or (defined $type2) or (defined $form2) or (defined $zero2));
    
    # Checking if protocol was specified
    if ((($ppflag == 1) or ($ppflag == 3)) and (!defined $pro)) {
      print "ERROR: Please specify the protocol to set with '-pro'.\n";
      exit;
    }
    if ((($ppflag == 2) or ($ppflag == 3)) and (!defined $pro2)) {
      print "ERROR: Please specify the protocol to set with '-pro2'.\n";
      exit
    }

    # Applying protocol parameter changes...
    if (defined $crc) {
      if ((!defined $$cfg_pt{$id}{'ISDNProtocol'}) or (exists $supportedParameters_pt->{$$cfg_pt{$id}{'ISDNProtocol'}}{'CRC4'})) {
        if (($crc eq 'ON') or ($crc eq 'OFF')) {
          $cfg_pt->{$id}{'ProtocolParameters'}{'CRC4'} = $crc;
        } else {
          print "ERROR: Valid CRC4 values are: ON, OFF.\n";
          exit;
        }
      } else {
        print "ERROR: CRC4 cannot be set for protocol '$$cfg_pt{$id}{'ISDNProtocol'}'.\n";
        exit;
      }
    }
    if (defined $crc2) {
      if ((!defined $$cfg_pt{$id}{'ISDNProtocol2'}) or (exists $supportedParameters_pt->{$$cfg_pt{$id}{'ISDNProtocol2'}}{'CRC4'})) {
        if (($crc2 eq 'ON') or ($crc2 eq 'OFF')) {
          $cfg_pt->{$id}{'ProtocolParameters2'}{'CRC4'} = $crc2;
        } else {
          print "ERROR: Valid CRC4 values are: ON, OFF.\n";
          exit;
        }
      } else {
        print "ERROR: CRC4 cannot be set for protocol '$$cfg_pt{$id}{'ISDNProtocol2'}'.\n";
        exit;
      }
    }
    if (defined $type) {
      if ((!defined $$cfg_pt{$id}{'ISDNProtocol'}) or (exists $supportedParameters_pt->{$$cfg_pt{$id}{'ISDNProtocol'}}{'TYPE'})) {
        if (($type eq 'CAS') or ($type eq 'PRI')) {
          $cfg_pt->{$id}{'ProtocolParameters'}{'TYPE'} = $type;
        } else {
          print "ERROR: Valid TYPE values are: CAS, PRI.\n";
          exit;
        }
      } else {
        print "ERROR: TYPE cannot be set for protocol '$$cfg_pt{$id}{'ISDNProtocol'}'.\n";
        exit;
      }
    }
    if (defined $type2) {
      if ((!defined $$cfg_pt{$id}{'ISDNProtocol2'}) or (exists $supportedParameters_pt->{$$cfg_pt{$id}{'ISDNProtocol2'}}{'TYPE'})) {
        if (($type2 eq 'CAS') or ($type2 eq 'PRI')) {
          $cfg_pt->{$id}{'ProtocolParameters2'}{'TYPE'} = $type2;
        } else {
          print "ERROR: Valid TYPE values are: CAS, PRI.\n";
          exit;
        }
      } else {
        print "ERROR: TYPE cannot be set for protocol '$$cfg_pt{$id}{'ISDNProtocol2'}'.\n";
        exit;
      }
    }
    if (defined $form) {
      if ((!defined $$cfg_pt{$id}{'ISDNProtocol'}) or (exists $supportedParameters_pt->{$$cfg_pt{$id}{'ISDNProtocol'}}{'FORM'})) {
        if (($form eq 'D4') or ($form eq 'ESF')) {
          $cfg_pt->{$id}{'ProtocolParameters'}{'FORM'} = $form;
        } else {
          print "ERROR: Valid FORM values are: D4, ESF.\n";
          exit;
        }
      } else {
        print "ERROR: FORM cannot be set for protocol '$$cfg_pt{$id}{'ISDNProtocol'}'.\n";
        exit;
      }
    }
    if (defined $form2) {
      if ((!defined $$cfg_pt{$id}{'ISDNProtocol2'}) or (exists $supportedParameters_pt->{$$cfg_pt{$id}{'ISDNProtocol2'}}{'FORM'})) {
        if (($form2 eq 'D4') or ($form2 eq 'ESF')) {
          $cfg_pt->{$id}{'ProtocolParameters2'}{'FORM'} = $form2;
        } else {
          print "ERROR: Valid FORM values are: D4, ESF.\n";
          exit;
        }
      } else {
        print "ERROR: FORM cannot be set for protocol '$$cfg_pt{$id}{'ISDNProtocol2'}'.\n";
        exit;
      }
    }
    if (defined $zero) {
      if ((!defined $$cfg_pt{$id}{'ISDNProtocol'}) or (exists $supportedParameters_pt->{$$cfg_pt{$id}{'ISDNProtocol'}}{'ZERO'})) {
        if (($zero eq 'NONE') or ($zero eq 'B8ZS') or ($zero eq 'BIT7')) {
          $cfg_pt->{$id}{'ProtocolParameters'}{'ZERO'} = $zero;
        } else {
          print "ERROR: Valid ZERO values are: NONE, B8ZS, BIT7.\n";
          exit;
        }
      } else {
        print "ERROR: ZERO cannot be set for protocol '$$cfg_pt{$id}{'ISDNProtocol'}'.\n";
        exit;
      }
    }
    if (defined $zero2) {
      if ((!defined $$cfg_pt{$id}{'ISDNProtocol2'}) or (exists $supportedParameters_pt->{$$cfg_pt{$id}{'ISDNProtocol2'}}{'ZERO'})) {
        if (($zero2 eq 'NONE') or ($zero2 eq 'B8ZS') or ($zero2 eq 'BIT7')) {
          $cfg_pt->{$id}{'ProtocolParameters2'}{'ZERO'} = $zero2;
        } else {
          print "ERROR: Valid ZERO values are: NONE, B8ZS, BIT7.\n";
          exit;
        }
      } else {
        print "ERROR: ZERO cannot be set for protocol '$$cfg_pt{$id}{'ISDNProtocol2'}'.\n";
        exit;
      }
    }
  }

  # Possible return values: 0 = No change, 1 = Span 1, 2 = Span 2, 3 = Span 1 & 2
  return $ppflag;
}
###############################################################################
sub editConfig {

  my ($cfg_pt, $ppflag, $id) = @_;
  
  my (@cfg, $cfg, $org, $key, $idx);
  
  my $safe = 0;

  if (defined $id) {
    $id = "ID$id";
  } else {
    $id = "";
  }
  
  $cfg = "/usr/dialogic/cfg/dialogic.cfg";
  $org = "/usr/dialogic/cfg/dialogic.org";

  # Checks if a backup of the Dialogic configuration file exists, if not creates it
  unless (-e $org) {
    # Reading configuration file
    open (CFG, $cfg) || die "ERROR: Couldn't open file '$cfg' in read mode...";
    @cfg = <CFG>;
    close CFG;
    # Writing backup configuration file
    open (ORG, ">$org") || die "ERROR: Couldn't open file '$org' in write mode...";
    print ORG @cfg;
    close ORG;
    # Informing user that a backup file was created
    print "INFO: Original configuration file saved as '$org'.\n";
  }

  # Saving ISDN protocols as section below will potentially delete them from DB
  my ($ISDNProtocol, $ISDNProtocol2);
  if (defined $$cfg_pt{$id}{'ISDNProtocol'}) { $ISDNProtocol = $$cfg_pt{$id}{'ISDNProtocol'} };
  if (defined $$cfg_pt{$id}{'ISDNProtocol2'}) { $ISDNProtocol2 = $$cfg_pt{$id}{'ISDNProtocol2'} };

  # Saving parameter filenames as section below will potentially delete them from DB
  my ($ParameterFile, $ParameterFile2);
  if (defined $$cfg_pt{$id}{'ParameterFile'}) { $ParameterFile = $$cfg_pt{$id}{'ParameterFile'} };
  if (defined $$cfg_pt{$id}{'ParameterFile2'}) { $ParameterFile2 = $$cfg_pt{$id}{'ParameterFile2'} };

  # Building configuration buffer to sync changes
  open (CFG, $cfg) || die "ERROR: Couldn't open file '$cfg' in read mode...";
  @cfg = "";
  while (<CFG>) {
    if (($_ !~ /\[Genload - .*/) and ($safe == 0)) {
      push @cfg, $_;
      next;
    }
    # Parsing GENERIC section
    if ($_ =~ /All Boards/) {
      push @cfg, $_;
      unless ($safe) {
        do {
          $_ = <CFG>;
          if (defined $_) {
            if ($_ =~ /(\S+)\=(\S+)/) {
              if ((exists $cfg_pt->{'GENERIC'}{$1}) and (defined $cfg_pt->{'GENERIC'}{$1})) {
                push @cfg, "$1\=$cfg_pt->{'GENERIC'}{$1}\n" unless ($cfg_pt->{'GENERIC'}{$1} eq 'DELETE');
                delete $cfg_pt->{'GENERIC'}{$1};
              }
            } elsif ($_ !~ /\[Genload - .*/) {
              push @cfg, $_ unless ((/^\s*$/) or ($2 eq 'DELETE'));
            }
          }
        } until ((/\[Genload - .*/) or (eof));
      }
      # Adding new values to configuration buffer
      foreach $key (sort keys %{$cfg_pt->{'GENERIC'}}) {
        if (defined $cfg_pt->{'GENERIC'}{$key}) {
          push @cfg, "$key\=$cfg_pt->{'GENERIC'}{$key}\n" unless ($cfg_pt->{'GENERIC'}{$key} eq 'DELETE');
        }
      }
      push @cfg, "\n";
      $safe++ if (eof);
      redo;
    }
    # Parsing IDX section
    elsif ($_ =~ /PCI ID (\S+)] \/\* .*\*\//) {
      $idx = "ID$1";
      push @cfg, $_;
      unless ($safe) {
        do {
          $_ = <CFG>;
          if (defined $_) {
            if ($_ =~ /(\S+)\=(\S+)/) {
              if (($1 eq 'ParameterFile') or ($1 eq 'ParameterFile2') or ($1 eq 'ISDNProtocol') or ($1 eq 'ISDNProtocol2')) {
                push @cfg, $_ if (($id ne $idx) and (!exists $cfg_pt->{$idx}{$1}));
              } elsif ((exists $cfg_pt->{$idx}{$1}) and (defined $cfg_pt->{$idx}{$1})) {
                push @cfg, "$1\=$cfg_pt->{$idx}{$1}\n" unless ($cfg_pt->{$idx}{$1} eq 'DELETE');
                delete $cfg_pt->{$idx}{$1};
              } else {
                push @cfg, $_ unless ($2 eq 'DELETE');
              }
            } elsif ($_ !~ /\[Genload - .*/) {
              push @cfg, $_ unless (/^\s*$/);
            }
          }
        } until ((/\[Genload - .*/) or (eof));
      }
      # Processing parameter file option (1st span)
      if ($id eq $idx) {
        if (($ppflag == 1) or ($ppflag == 3)) {
          if ((defined $ISDNProtocol) and ($ISDNProtocol ne 'NONE') and ($ISDNProtocol ne 'DELETE')) {
            if ($ISDNProtocol ne 'CAS') {
              push @cfg, "ParameterFile=" . lc($ISDNProtocol) . ".${id}.1\n";
            } else {
              push @cfg, "ParameterFile=spandti" . ".${id}.1\n";
            }
          }
          delete $cfg_pt->{$idx}{'ParameterFile'};
        }
      }
      # Processing parameter file option (2nd span)
      if ($id eq $idx) {
        if (($ppflag == 2) or ($ppflag == 3)) {
          if ((defined $ISDNProtocol2) and ($ISDNProtocol2 ne 'NONE') and ($ISDNProtocol2 ne 'DELETE')) {
            if ($ISDNProtocol2 ne 'CAS') {
              push @cfg, "ParameterFile2=" . lc($ISDNProtocol2) . ".${id}.2\n";
            } else {
              push @cfg, "ParameterFile2=spandti" . ".${id}.2\n";
            }
          }
          delete $cfg_pt->{$idx}{'ParameterFile2'};
        }
      }
      # Adding new values to configuration buffer
      foreach $key (sort keys %{$cfg_pt->{$idx}}) {
        next if ($key =~ /ProtocolParameters|ProtocolParameters2|BoardType/);
        if (defined $cfg_pt->{$idx}{$key}) {
          next if (($key eq 'ISDNProtocol') and ($cfg_pt->{$idx}{$key} eq 'CAS'));
          next if (($key eq 'ISDNProtocol2') and ($cfg_pt->{$idx}{$key} eq 'CAS'));
          next if (($key eq 'ParameterFile') and ((!defined $ISDNProtocol) or ($ISDNProtocol eq 'NONE') or ($ISDNProtocol eq 'DELETE')));
          next if (($key eq 'ParameterFile2') and ((!defined $ISDNProtocol2) or ($ISDNProtocol2 eq 'NONE') or ($ISDNProtocol2 eq 'DELETE')));
          push @cfg, "$key\=$cfg_pt->{$idx}{$key}\n" unless ($cfg_pt->{$idx}{$key} eq 'DELETE');
        }
      }
      push @cfg, "\n" unless ($safe);
      $safe++ if (eof);
      redo unless ($safe == 2);
    }
  }
  close CFG;

  # Looking for protocol parameter changes
  my ($prmorgfile, $prmdstfile);
  if ($ppflag) {
    # Modifying parameter file of ISDN protocol on span 1
    if (($ppflag == 1) or ($ppflag == 3)) {
      $prmorgfile = $ParameterFile;
      if ($prmorgfile =~ /(.+)\.prm/) {
        $prmdstfile = $1;
      } else {
        $prmdstfile = $prmorgfile;
      }
      $prmdstfile = "/usr/dialogic/data/" . $prmdstfile . ".${id}.1";
      $prmorgfile = "/usr/dialogic/data/" . $prmorgfile;
      open (PRMORG, $prmorgfile) || die "ERROR: Couldn't open file '$prmorgfile' in read mode...";
      open (PRMDST, ">$prmdstfile") || die "ERROR: Couldn't open file '$prmdstfile' in write mode...";
      # Making changes to parameter file
      while (<PRMORG>) {
        if (/^\;?(\S{4})\s(\d{2})/) {
          if ($1 eq '000F') {
            if (defined $cfg_pt->{$id}{'ProtocolParameters'}{'CRC4'}) {
              if ($cfg_pt->{$id}{'ProtocolParameters'}{'CRC4'} eq 'OFF') {
                print PRMDST "$1 00\n";
              } else {
                print PRMDST "$1 01\n";
              }
            } else {
              print PRMDST $_;
            }
          } elsif ($1 eq '0013') {
            if (defined $cfg_pt->{$id}{'ProtocolParameters'}{'TYPE'}) {
              if ($cfg_pt->{$id}{'ProtocolParameters'}{'TYPE'} eq 'CAS') {
                print PRMDST "$1 00\n";
              } else {
                print PRMDST "$1 01\n";
              }
            } else {
              print PRMDST $_;
            }
          } elsif ($1 eq '0014') {
            if (defined $cfg_pt->{$id}{'ProtocolParameters'}{'FORM'}) {
              if ($cfg_pt->{$id}{'ProtocolParameters'}{'FORM'} eq 'D4') {
                print PRMDST "$1 00\n";
              } else {
                print PRMDST "$1 01\n";
              }
            } else {
              print PRMDST $_;
            }
          } elsif ($1 eq '0020') {
            if (defined $cfg_pt->{$id}{'ProtocolParameters'}{'ZERO'}) {
              if ($cfg_pt->{$id}{'ProtocolParameters'}{'ZERO'} eq 'NONE') {
                print PRMDST "$1 00\n";
              } elsif ($cfg_pt->{$id}{'ProtocolParameters'}{'ZERO'} eq 'B8ZS') {
                  print PRMDST "$1 01\n";
              } else {
                print PRMDST "$1 02\n";
              }
            } else {
              print PRMDST $_;
            }
          } else {
            print PRMDST $_;
          }
        } else {
          print PRMDST $_;
        }
      }
      close PRMORG;
      close PRMDST;
    }
    # Modifying parameter file of ISDN protocol on span 2
    if (($ppflag == 2) or ($ppflag == 3)) {
      $prmorgfile = $ParameterFile2;
      if ($prmorgfile =~ /(.+)\.prm/) {
        $prmdstfile = $1;
      } else {
        $prmdstfile = $prmorgfile;
      }
      $prmdstfile = "/usr/dialogic/data/" . $prmdstfile . ".${id}.2";
      $prmorgfile = "/usr/dialogic/data/" . $prmorgfile;
      open (PRMORG, $prmorgfile) || die "ERROR: Couldn't open file '$prmorgfile' in read mode...";
      open (PRMDST, ">$prmdstfile") || die "ERROR: Couldn't open file '$prmdstfile' in write mode...";
      # Making changes to parameter file
      while (<PRMORG>) {
        if (/^\;?(\S{4})\s(\d{2})/) {
          if ($1 eq '000F') {
            if (defined $cfg_pt->{$id}{'ProtocolParameters2'}{'CRC4'}) {
              if ($cfg_pt->{$id}{'ProtocolParameters2'}{'CRC4'} eq 'OFF') {
                print PRMDST "$1 00\n";
              } else {
                print PRMDST "$1 01\n";
              }
            } else {
              print PRMDST $_;
            }
          } elsif ($1 eq '0013') {
            if (defined $cfg_pt->{$id}{'ProtocolParameters2'}{'TYPE'}) {
              if ($cfg_pt->{$id}{'ProtocolParameters2'}{'TYPE'} eq 'CAS') {
                print PRMDST "$1 00\n";
              } else {
                print PRMDST "$1 01\n";
              }
            } else {
              print PRMDST $_;
            }
          } elsif ($1 eq '0014') {
            if (defined $cfg_pt->{$id}{'ProtocolParameters2'}{'FORM'}) {
              if ($cfg_pt->{$id}{'ProtocolParameters2'}{'FORM'} eq 'D4') {
                print PRMDST "$1 00\n";
              } else {
                print PRMDST "$1 01\n";
              }
            } else {
              print PRMDST $_;
            }
          } elsif ($1 eq '0020') {
            if (defined $cfg_pt->{$id}{'ProtocolParameters2'}{'ZERO'}) {
              if ($cfg_pt->{$id}{'ProtocolParameters2'}{'ZERO'} eq 'NONE') {
                print PRMDST "$1 00\n";
              } elsif ($cfg_pt->{$id}{'ProtocolParameters2'}{'ZERO'} eq 'B8ZS') {
                print PRMDST "$1 01\n";
              } else {
                print PRMDST "$1 02\n";
              }
            } else {
              print PRMDST $_;
            }
          } else {
            print PRMDST $_;
          }
        } else {
          print PRMDST $_;
        }
      }
      close PRMORG;
      close PRMDST;
    }
  }

  # Writing updated configuration file
  open (CFG, ">$cfg") || die "ERROR: Couldn't open file '$cfg' in write mode...";
  print CFG @cfg;
  close CFG;

  print "INFO: Configuration file modified successfully.  Reboot the probe to load changes.\n";
}
###############################################################################
sub addID {

  my ($cfg_pt, $id) = @_;
  
  $cfg_pt->{$id} = {
    'BoardType' => undef,
    'PCMEncoding' => undef,
    'EC_Resource' => undef,
    'ISDNProtocol' => undef,
    'ISDNProtocol2' => undef,
    'ParameterFile' => undef,
    'ParameterFile2' => undef,
    'FirmwareFile' => undef,
    'FirmwareFile2' => undef,
    'ProtocolParameters' => {
      'CRC4' => undef,
      'TYPE' => undef,
      'FORM' => undef,
      'ZERO' => undef
    },
    'ProtocolParameters2' => {
      'CRC4' => undef,
      'TYPE' => undef,
      'FORM' => undef,
      'ZERO' => undef
    }
  };
}
###############################################################################
sub buildConfigStruct {

  my $id = $_[0];

  my (%cfg, @logfile, $logfile, $cfg, $cfg_pt, $k1, $k2, $prmfile, $buf, $idx);
  
  my $safe = 0;
  
  if (defined $id) {
    $id = "ID$id";
  } else {
    $id = "";
  }

  $cfg = "/usr/dialogic/cfg/dialogic.cfg";

  $cfg_pt = \%cfg;

  # Building the configuration data structure
  %cfg = ('GENERIC' => {
            'LogFile' => '/usr/dialogic/log/genload.log',
            'BusType' => undef,
            'PrimaryMaster' => undef,
            'PrimaryMasterClockSource' => undef,
            'PCMEncoding' => undef,
            'SCBusClockMaster' => undef,
            'SCBusClockMasterSource' => undef
          });

  # Populating configuration structure
  open (CFG, $cfg) || die "ERROR: Couldn't open file '$cfg' in read mode...";
  while (<CFG>) {
    next unless (/\[Genload - .*/);
    # Parsing GENERIC section
    if ($_ =~ /All Boards/) {
      unless ($safe) {
        do {
          $_ = <CFG>;
          if (defined $_) {
            if ($_ =~ /(\S+)\=(\S+)/) {
              unless (exists $cfg_pt->{'GENERIC'}{$1}) {
                print "WARNING: GENERIC section parameter '$1' isn't supported and will be skipped.\n";
              } else {
                $cfg_pt->{'GENERIC'}{$1} = $2;
              }
            }
          }
        } until ((/\[Genload - .*/) or (eof));
      }
      $safe++ if (eof);
      redo;
    }
    # Parsing IDX section
    elsif ($_ =~ /PCI ID (\S+)] \/\* (.*)\*\//) {
      $idx = "ID$1";
      &addID($cfg_pt, $idx) unless (exists $cfg_pt->{$idx});
      $cfg_pt->{$idx}{'BoardType'} = $2;
      unless ($safe) {
        do {
          $_ = <CFG>;
          if ((defined $_) and ($_ =~ /(\S+)\=(\S+)/)) {
            $cfg_pt->{$idx}{$1} = $2;
          }
        } until ((/\[Genload - .*/) or (eof));
      }
      $safe++ if (eof);
      $buf = $_;
      # Adding protocol specific parameters (1st span)
      if (defined $cfg_pt->{$idx}{'ParameterFile'}) {
        $prmfile = $cfg_pt->{$idx}{'ParameterFile'};
        $prmfile = "/usr/dialogic/data/" . $prmfile unless ($prmfile =~ /\//);
        &getProtocolParameters($cfg_pt, $prmfile, $idx, 1) if (($prmfile ne 'DELETE') and (-e $prmfile));
      }
      # Adding protocol specific parameters (2nd span)
      if (defined $cfg_pt->{$idx}{'ParameterFile2'}) {
        $prmfile = $cfg_pt->{$idx}{'ParameterFile2'};
        $prmfile = "/usr/dialogic/data/" . $prmfile unless ($prmfile =~ /\//);
        &getProtocolParameters($cfg_pt, $prmfile, $idx, 2) if (($prmfile ne 'DELETE') and (-e $prmfile));
      }
      $_ = $buf;
      redo unless ($safe == 2);
    }
  }
  close CFG;
  return $cfg_pt;
}
###############################################################################
sub getProtocolParameters {

  my ($cfg_pt, $prmfile, $id, $span) = @_;
  
  my ($value, $flag);
  
  if ((defined $prmfile) and ($prmfile =~ /spandti/)) {
    $flag = 0;
  } else {
    $flag = 1;
  }
  
  open (PRMFILE, $prmfile) || die "ERROR: Couldn't open file '$prmfile' in read mode...";
  while (<PRMFILE>) {
    if (/^\;?(\S{4})\s(\d{2})/) {
      if ($1 eq '000F') {
        if ($2 eq '00') {
          $value = 'OFF';
        } elsif ($2 eq '01') {
          $value = 'ON';
        } else {
          $value = "UNSUPPORTED VALUE";
        }
        if ($span == 1) {
          $cfg_pt->{$id}{'ProtocolParameters'}{'CRC4'} = $value;
        } else {
          $cfg_pt->{$id}{'ProtocolParameters2'}{'CRC4'} = $value;
        }          
      } elsif (($1 eq '0013') and ($flag)) {
        if ($2 eq '00') {
          $value = 'CAS';
        } elsif ($2 eq '01') {
          $value = 'PRI';
        } elsif ($2 eq '02') {
          $value = 'NONE';
        } else {
          $value = "UNSUPPORTED VALUE";
        }
        if ($span == 1) {
          $cfg_pt->{$id}{'ProtocolParameters'}{'TYPE'} = $value;
        } else {
          $cfg_pt->{$id}{'ProtocolParameters2'}{'TYPE'} = $value;
        }          
      } elsif ($1 eq '0014') {
        if ($2 eq '00') {
          $value = 'D4';
        } elsif ($2 eq '01') {
          $value = 'ESF';
        } else {
          $value = "UNSUPPORTED VALUE";
        }
        if ($span == 1) {
          $cfg_pt->{$id}{'ProtocolParameters'}{'FORM'} = $value;
        } else {
          $cfg_pt->{$id}{'ProtocolParameters2'}{'FORM'} = $value;
        }          
      } elsif ($1 eq '0020') {
        if ($2 eq '00') {
          $value = 'NONE';
        } elsif ($2 eq '01') {
          $value = 'B8ZS';
        } elsif ($2 eq '02') {
          $value = 'BIT7';
        } else {
          $value = "UNSUPPORTED VALUE";
        }
        if ($span == 1) {
          $cfg_pt->{$id}{'ProtocolParameters'}{'ZERO'} = $value;
        } else {
          $cfg_pt->{$id}{'ProtocolParameters2'}{'ZERO'} = $value;
        }          
      }
    }
  }
  close PRMFILE;
}  
###############################################################################
# MAIN ROUTINE
###############################################################################
sub main {

  # Building data structure for specific protocol options
  my ($SIGprotocols_pt, $supportedParameters_pt) = &buildProtocolStruct();

  # Without argument, the script runs in view mode
  unless (@ARGV) { &viewConfig(&buildConfigStruct()) };

  # Defining required variables
  my ($help, $version, $set, $gpcm, $logfile, $id, $ecr, $pcm, $fwl, $fwl2, $pro, $pro2, $crc, $type,
      $form, $zero, $crc2, $type2, $form2, $zero2);

  # Sorting the argument array
  unless (GetOptions("help"=>\$help, "version"=>\$version, "set"=>\$set, "gpcm=s"=>\$gpcm, "logfile=s"=>\$logfile,
                     "id=s"=>\$id, "ecr=s"=>\$ecr, "pcm=s"=>\$pcm, "fwl=s"=>\$fwl, "fwl2=s"=>\$fwl2, "pro=s"=>\$pro,
                     "pro2=s"=>\$pro2, "crc=s"=>\$crc, "crc2=s"=>\$crc2, "type=s"=>\$type, "type2=s"=>\$type2,
                     "form=s"=>\$form, "form2=s"=>\$form2, "zero=s"=>\$zero, "zero2=s"=>\$zero2)) { exit };

  # Formatting options
  $id = uc($id) if (defined $id);
  $ecr = uc($ecr) if (defined $ecr);
  $pcm = uc($pcm) if (defined $pcm);
  $pro = uc($pro) if (defined $pro);
  $pro2 = uc($pro2) if (defined $pro2);
  $gpcm = uc($gpcm) if (defined $gpcm);
  $crc = uc($crc) if (defined $crc);
  $crc2 = uc($crc2) if (defined $crc2);
  $type = uc($type) if (defined $type);
  $type2 = uc($type2) if (defined $type2);
  $form = uc($form) if (defined $form);
  $form2 = uc($form2) if (defined $form2);
  $zero = uc($zero) if (defined $zero);
  $zero2 = uc($zero2) if (defined $zero2);
  $fwl = uc($fwl) if ((defined $fwl) and ($fwl eq 'delete'));
  $fwl2 = uc($fwl2) if ((defined $fwl2) and ($fwl2 eq 'delete'));

  # Processing arguments provided
  if (defined $help) {
    # Printing command usage
    &printUsage();
    &printProtocols($SIGprotocols_pt);
  } elsif (defined $version) {
    # Printing command version
    &printVersion();
  } elsif (defined $set) {
    # Analyzing edit mode request
      my $cfg_pt = &buildConfigStruct($id);
      my $ppflag = &updateConfigStruct($cfg_pt, $supportedParameters_pt, $gpcm, $logfile, $id, $ecr, $pcm, $fwl, $fwl2,
                                       $pro, $pro2, $crc, $type, $form, $zero, $crc2, $type2, $form2, $zero2, $SIGprotocols_pt);
      &editConfig($cfg_pt, $ppflag, $id);
  } else {
    print "ERROR: Bad command usage.  Please run script with the -h option.\n";
  }
}
###############################################################################
# END OF PROGRAM
###############################################################################
