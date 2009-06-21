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
use Getopt::Long;
use BabyDiary::Deploy;

our $TARGET = BabyDiary::Deploy::ssh_dest();

my @files = @ARGV;
my $files_to_go = @files;
my $diffs = 0;

# Silently exit if no file
if (! @files) {
    exit 1;
}

if (grep { $_ =~ m{database/data} } @files) {
    print "You can't diff the database. Crazy!!!\n";
    exit 2;
}

for my $file (@files) {

    my $dest_file = BabyDiary::Deploy::windows_to_unix_path($file);
    my $copy_cmd = qq{scp $TARGET/$dest_file $file.tmp.$$ >NUL};
    my $status = system($copy_cmd);

    # Transfer failed
    if (0 != $status) {
        print " ! $file (TRANSFER FAILED)", "\n";
    }

    print "Diff of `$file'...\n";

    my $diff_cmd = qq{diff -ub $file.tmp.$$ $file};
    $status = system($diff_cmd);

    if (0 != $status) {
        $diffs++;
    }

    unlink "$file.tmp.$$";
}

print "$diffs files have differences from production install.\n";

