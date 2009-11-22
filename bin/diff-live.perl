#!c:\dev\perl510\bin\perl.exe

# ==============================================================
# DIFF A SINGLE FILE FROM THE LIVE SERVER
# 
# Usage: diff-live.perl htdocs\css\master.css
#
# $Id$
# ==============================================================

BEGIN {
    # Unbuffer stdout to make results appear as soon as possible
    $| = 1;
}

use strict;
use warnings;
use lib 'lib';
use File::Find;
use File::Spec;
use Getopt::Long;
use BabyDiary::Deploy;

our $TARGET = BabyDiary::Deploy::ssh_dest();

{
	my @all_files;

	sub non_dot_dot {
		my $file = $_;
		#print "- Exam {$file} {$File::Find::dir} {$File::Find::name}\n";
		if ($file =~ m{^\..+}) {
			$File::Find::prune = 1;
			return;
		}
		if (-d $file) {
			return;
		}
		#print "- Adding $File::Find::name\n";
		push @all_files, $File::Find::name;
	}

	sub recursive_find {
		my @files = @_;
		@all_files = ();

		#print "- Recfind (@files)\n";

		for my $folder_or_file (@files) {

			if (-l $folder_or_file) {
				#print "- Skipped link $folder_or_file\n";
				next;
			}

			if (-f $folder_or_file) {
				#print "- Adding file [$folder_or_file]\n";
				push @all_files, $folder_or_file;
				next;
			}

			if (-d $folder_or_file) {
				#print "- Recursing [$folder_or_file]\n";
				File::Find::find(\&non_dot_dot, $folder_or_file);
			}

		}

		for (@all_files) {
			print "- $_\n";
		}

		return @all_files;
	}

}

my @files = @ARGV;
my $files_to_go = @files;
my $diffs = 0;
my $recursive = 0;

if ($files[0] eq '-r' || $files[0] eq '--recursive') {
	$recursive++;
	shift @files;
}

# Silently exit if no file
if (! @files) {
    exit 1;
}

if ($recursive) {
	@files = recursive_find(@files);
}

if (grep { $_ =~ m{database/data} } @files) {
    print "You can't diff the database. Crazy!!!\n";
    exit 2;
}

for my $file (@files) {

    my $dest_file = BabyDiary::Deploy::windows_to_unix_path($file);
    my $copy_cmd = qq{d:\\bin\\scp $TARGET/$dest_file $file.tmp.$$ >NUL};
    my $status = system($copy_cmd);

    # Transfer failed
    if (0 != $status) {
        print " ! $file (TRANSFER FAILED)", "\n";
    }

    print "Diff of `$file'...\n";

    my $diff_cmd = qq{diff -ub $file $file.tmp.$$};
    $status = system($diff_cmd);

    if (0 != $status) {
        $diffs++;
    }

    unlink "$file.tmp.$$";
}

print "$diffs files have differences from production install.\n";

