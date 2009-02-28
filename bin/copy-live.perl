#!c:\dev\perl510\bin\perl.exe

# ==============================================================
# COPY A SINGLE FILE TO THE LIVE SERVER
# 
# Usage: copy_live.pl htdocs\css\master.css
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

my @files = @ARGV;
my $files_to_go = @files;
my $transferred = 0;

# Silently exit if no file
if (! @files) {
    exit 1;
}

if (grep { $_ =~ m{database[/\\]data} } @files) {
    print "You can't touch the database. Crazy!!!\n";
    exit 2;
}

for my $file (@files) {

    # We need to convert the #! line to a standard linux server
    #my $tmp_copy = BabyDiary::Deploy::temporary_copy($file);
    #BabyDiary::Deploy::process_file($tmp_copy);
    #BabyDiary::Deploy::deploy_live($tmp_copy);
    my $status = BabyDiary::Deploy::deploy_live($file);

    # Transfer failed
    if (! $status) {
        print " ! $file", "\n";
    }

    # Transfer ok
    else {
        print " + $file", "\n";
        $transferred++;
    }

}

print "Transferred $transferred/$files_to_go files.\n";

if ($transferred < $files_to_go) {
    print "\n**** FAILED ****\n";
}

