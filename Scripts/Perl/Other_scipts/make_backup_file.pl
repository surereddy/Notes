#! /usr/bin/perl -w

# $Id: make_backup_file.pl,v 1.4.2.5 2006/02/24 16:58:24 sholland Exp $
#
# SYNPOSIS
#    make_backup_file.pl [database] [config] [docs] \
#                       [certs] [promtps] [branding] [xlat] [sessions]
#
# DESCRIPTION
#    Build a backup file, compressed with gzip but in a tar format, which
#    is then further split into a sequence of smaller files and an md5
#    parts list - for more efficient movement of files from one system
#    to another.
#
#    The size of each "chunk" comes from /usr/eiab/eiab.conf variable
#    BACKUP_CHUNKSIZE, defaulting to 512m (half a gig).
#
#    Exit code is zero for success, non-zero otherwise.

use strict;
use Sys::Hostname;

select STDOUT;
$| = 1;

my $backupTmpDir       = "/slides/.backup";
my $restoreDir         = "/slides/.restore";
my $previousDir        = "/slides/.saveprevious";
my $tarArgs            = "";
my $filesFile          = $backupTmpDir."/filesFile$$";
my $markerFile         = "edial_backup_marker";
my $findErrs           = $backupTmpDir."/findErrs";
my $dbErrFile  = "dbErrs";
my $dbDumpFile         = "edib.dump";
my $irpDumpFile        = "irpdb.dump";

# Build the backup file prefix name
my $host = hostname();
my $dateprefix=`date +%Y%m%d-%H%M-`;
chomp $dateprefix;
my $backupFilePrefix="$dateprefix$host-backup.";

# Known list of tarArgs we always use.

$tarArgs .= " --exclude /slides/.userids/audio_logs";
$tarArgs .= " --exclude /slides/.saveprevious";
$tarArgs .= " --exclude /slides/tmp/saveprevious.tar.gz";
$tarArgs .= " --exclude /slides/.restore";
$tarArgs .= " --exclude $backupTmpDir";
$tarArgs .= " --exclude lost+found";
$tarArgs .= " --files-from=$filesFile";

#
# Make sure we have a clean backup temp directory, the cd there for all
# remaining operations.  Also remove remnants of old backups from previous
# versions.
#
print "Clearing backup directory\n";
deleteLegacyBackupDirs();
`sudo rm -rf $backupTmpDir $restoreDir`;
if (-d $backupTmpDir || -d $restoreDir) {
    my_bad("Failed to remove $backupTmpDir or $restoreDir");
}

`mkdir -p $backupTmpDir`;
if (!-d $backupTmpDir) {
    my_bad("Failed to create $backupTmpDir");
}
chdir($backupTmpDir) or my_bad("Can't chdir to $backupTmpDir");

#
# Create the list of files to tar.
#
print "Creating list of files to back up\n";
system("cp /dev/null $filesFile");
if ($?) { my_bad("Failed to create $filesFile in $backupTmpDir"); }

#
# Version marker is in every backup.
#
print "Creating version marker\n";
if ($?) { my_bad("server buildinfo failed"); }
my $buildInfo = `/usr/server/server buildinfo`;
if ($?) { my_bad("server buildinfo failed") };
open MARKER, ">$markerFile";
print MARKER "$buildInfo\n";
close MARKER;
addToTar("$markerFile");

if(!grep (/^verify$/, @ARGV))
{
	collectFiles();
}

my_bad("Not enough free space for backup on /slides\n") if (!isEnoughFreeSpace());

#
# Build the internal tar file - compressing and then running it
# through split to keep files to a maximum size
#
my $chunk = getChunkSize();
print "Building initial tar file\n";

# Errors to null OK, as we check return code.
my $tarRslts = `/bin/tar psPzcf - $tarArgs 2>&1 | /usr/bin/split -b$chunk - $backupFilePrefix`;
if ($? != 0) {
    my_bad("Error creating tar file: exit status $?\nOutput:\n$tarRslts");
}

# Remove useless files
qx{sudo rm -rf $filesFile $markerFile $findErrs};
if (-e $filesFile || -e $markerFile || -e $findErrs) {
    my_bad("Failed to remove $filesFile, $findErrs or $markerFile");
}

qx{sudo rm -rf $dbDumpFile $irpDumpFile $dbErrFile};
if (-e $dbDumpFile || -e $irpDumpFile || -e $dbErrFile) 
{
	my_bad("Failed to remove $dbDumpFile, $irpDumpFile or $dbErrFile");
}

#
# Generate the md5 checksum
#
print "Generating md5 checksum file\n";
qx{/usr/bin/md5sum * > $backupFilePrefix"md5"};
my_bad("Could not generate checksum file") if ($?);

print "Done\n";
exit 0;

#*************************functions*********************************************
sub my_bad 
{ 
	my $msg = shift; 
	print $msg; 
	exit 1; 
}

sub addToTar 
{
	my $arg        = shift;
	system "find $arg -type f >> $filesFile 2>$findErrs";
	if ($?) 
	{
		open(FE, "<$findErrs") or my_bad("Can't open $findErrs");
		while (<FE>) 
		{
			if (not /No such file or directory/) 
			{
				my_bad("find error: $_");
			}
		}
	}
}

sub getChunkSize {
	# The following number is measured in megabytes - and we handle
	# if BACKUP_CHUNKSIZE is not set.
	my $value = $ENV{'BACKUP_CHUNKSIZE'} || "512\n";
	chomp $value;
	
	$value = (2047) if ($value>2047);   # 2 gig limit minus 1
	$value =~ s/(\d+)/$1m/;    # Always put an m on the end for megabytes
	return $value;
}

sub deleteLegacyBackupDirs {
  `sudo rm -rf /slides/backup`;
  if (-d "/slides/backup") {
    my_bad("Failed to remove /slides/backup");
  }
}

#
# We are going to calculate if there is enough free space, and
# we do so in a very rough fashion, since we know that the size
# of our /slides partition dwarfs all the others.
#
# Calculate the total amount of disk space used by '/', '/slides', '/var', in 1K chunks.
# Calculate the total amount of disk space in /slides we know
# we are going to wipe out. Subtract.  If that remainder is
# less than half the free space in /slides, we are good to go,
# and we return true.
sub isEnoughFreeSpace 
{
	print "Calculating free disk space\n";
	my $TotalDiskUsed = 0;
	open HFILES, $filesFile;
	while(<HFILES>)
	{
		open (FILESIZE, "/usr/bin/du -slk $_ 2>/dev/null |") || die ("Could not run du");
		while (<FILESIZE>) 
		{
			$TotalDiskUsed += (split)[0];  # used, filename
		}
		close(FILESIZE);
	}
	close(HFILES);


	open( TOTUSED, "/bin/df -lk 2>/dev/null |") || die ("Could not run df");
	while (<TOTUSED>) 
	{
		next if !m/\/slides$/;
		$TotalDiskUsed += (split)[2];  # Name, Total, Used, Free, %free, Mount
	}
	close(TOTUSED);
	
	
	my $SlidesFreeSpace = 0;
	open( SLIDEFREE, "/bin/df -lk /slides 2>/dev/null |") ||
	die ("Could not run df");
	while (<SLIDEFREE>) {
	next if m/^Filesystem/;
	$SlidesFreeSpace += (split)[3];  # Name, Total, Used, Free, %free, Mount
	}
	close(SLIDEFREE);
	
	my $SlidesToDelete = 0;
	open (SLIDESDEL, "/usr/bin/du -slk $backupTmpDir $restoreDir $previousDir".
	" 2>/dev/null |") || die ("Could not run du");
	while (<SLIDESDEL>) {
	$SlidesToDelete += (split)[0];  # used, filename
	}
	close(SLIDESDEL);
	
	my $usedSpace=($TotalDiskUsed-$SlidesToDelete);
	
	my $retval = (($SlidesFreeSpace/$usedSpace)>=2);
	return $retval;
}

sub collectFiles
{
	#
	# Start collecting various components named by the args.
	#
	if (grep (/^database$/, @ARGV) or grep (/^all$/, @ARGV)) 
	{
		print "Checking databases\n";
		$ENV{"PGUSER"} = "postgres";
		
		# Vacuum the edib database and rebuild the query plans for performance
		my @edibresult = qx(psql -U'postgres' edib -c'VACUUM FULL ANALYZE' 2>&1);
		foreach (@edibresult) 
		{
			chomp($_);
			my_bad("Database vacuum error $_")
			if ( /^ERROR\s*\:/
			or /FATAL\s*/
			or /unable\s*/);
		}
		
		# Vacuum the irpedb database and rebuild the query plans for performance
		my @irpresult = qx(psql -U'postgres' irpedb -c'VACUUM FULL ANALYZE' 2>&1);
		foreach (@irpresult) {
			chomp($_);
			my_bad("Database vacuum error $_")
			if ( /^ERROR\s*\:/
			or /FATAL\s*/
			or /unable\s*/);
		}
		
		print "Dumping and compressing edib database\n";
		my $dbDumpCmd = "/usr/local/pgsql/bin/pg_dump -U postgres -v edib 2>$dbErrFile";
		my @dbcmdErrs   = qx{$dbDumpCmd > $dbDumpFile};
		mybad(join ' ', @dbcmdErrs) if ($#dbcmdErrs >= 0);
		open ERRS, "<$dbErrFile";
		while (<ERRS>) 
		{
			chomp($_);
			if (/^ERROR\s*\:/ or /FATAL\s*/ or /unable\s*/) 
			{
				unlink($dbDumpFile);
				my_bad(" EDIB Database dump error $_ ");
			}
		}
		if (! -r $dbDumpFile) 
		{
			unlink($dbDumpFile);
			my_bad(" Unable to read edib system data dump, no data was saved !");
		
		}
		addToTar("$dbDumpFile");
		
		print "Dumping and compressing irpedb database\n";
		my $irpDumpCmd = "/usr/local/pgsql/bin/pg_dump -U postgres -v irpedb 2>$dbErrFile";
		my @irpcmdErrs   = qx{$irpDumpCmd > $irpDumpFile};
		mybad(join ' ', @irpcmdErrs) if ($#irpcmdErrs >= 0);
		open ERRS, "<$dbErrFile";
		while (<ERRS>) 
		{
			chomp($_);
			if (/^ERROR\s*\:/ or /FATAL\s*/ or /unable\s*/) 
			{
				unlink($dbDumpFile);
				my_bad(" IRPEDB Database dump error $_ ");
			}
		}
		if (! -r $irpDumpFile) 
		{
			unlink($irpDumpFile);
			my_bad(" Unable to read irpedb system data dump, no data was saved !");
		
		}
		addToTar("$irpDumpFile");
		
		
	}
	
	if (grep (/^config$/, @ARGV) or grep (/^all$/, @ARGV)) 
	{
		print "Backing up config files\n";
		addToTar("/usr/eiab/eiab.site");
		addToTar("/usr/eiab/eiab.conf");
		addToTar("/usr/eiab/eiab.defaults");
		addToTar("/usr/local/apache/cgi-bin/buddies/sip_buddies.conf");
		addToTar("/var/log/eiablog/");
		addToTar("/var/log/eiabmaillog/");
		addToTar("/usr/mcu/prompts.conf");
		addToTar("/usr/local/sipcfgmgr/margarita.xml");
		addToTar("/usr/local/sipcfgmgr/uaconfig.xml");
	}
	
	if (grep (/^docs$/, @ARGV) or grep (/^all$/, @ARGV)) 
	{
		print "Backing up docs\n";
		system "find /slides/ -type f >> $filesFile 2>$findErrs";
		if ($?) { my_bad("Failed find command for /slides/"); }
		addToTar("/usr/tns/moh/");
		addToTar("/slides/.userids/");
	}
	
	if (grep (/^certs$/, @ARGV) or grep (/^all$/, @ARGV)) 
	{
		print "Backing up certs\n";
		addToTar("/usr/muxer/rsa*cert.pem");
		addToTar("/usr/muxer/rsa*key.pem");
	}
	
	if (grep (/^prompts$/, @ARGV) or grep (/^all$/, @ARGV)) 
	{
		print "Backing up prompts\n";
		addToTar("/usr/tns/promptsets/");
	}
	
	if (grep (/^branding$/, @ARGV) or grep (/^all$/, @ARGV)) 
	{
		print "Backing up branding\n";
		addToTar("/usr/local/apache/htdocs/branding/");
	}
	
	if (grep (/^xlat$/, @ARGV) or grep (/^all$/, @ARGV)) 
	{
		print "Backing up translations\n";
		addToTar("/usr/local/apache/htdocs/content/");
	}
	
	if (grep (/^sessions$/, @ARGV) or grep (/^all$/, @ARGV)) 
	{
		print "Backing up sessions\n";
		addToTar("/var/log/sessionlogs/");
	}
}

#************************end functions*******************************************

