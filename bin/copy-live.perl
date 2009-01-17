#!c:\dev\perl510\bin\perl.exe

# ==============================================================
# COPY A SINGLE FILE TO THE LIVE SERVER
# 
# Usage: copy_live.pl htdocs\css\master.css
#
# ==============================================================

BEGIN {
    # Unbuffer stdout to make results appear as soon as possible
    $| = 1;
}

use strict;
use warnings;
use lib 'lib';
use Getopt::Long;
#use BabyDiary::Deploy;

our $USER   = 'cosimo';
our $SERVER = 'satsrv02.satelgroup.net';
our $FOLDER = '/var/www2/www.curvedicrescita.com';

our $TARGET = $USER . '@' . $SERVER . ':' . $FOLDER;

my @files = @ARGV;
my $files_to_go = @files;
my $transferred = 0;

# Silently exit if no file
if (! @files) {
    exit;
}

for my $file (@files) {

    # We need to convert the #! line to a standard linux server
    #my $tmp_copy = BabyDiary::Deploy::temporary_copy($file);
    #BabyDiary::Deploy::process_file($tmp_copy);
    #BabyDiary::Deploy::deploy_live($tmp_copy);

    my $dest_file = $file;

    # Remove Windows drive letter (if any)
    $dest_file =~ s{^\w:}{};

    # Dest path has forward slashes
    $dest_file =~ s{\\}{/}g;

    my $copy_cmd = qq{scp $file $TARGET/$dest_file >NUL};
    my $status = system($copy_cmd);

    # Transfer failed
    if (0 != $status) {
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

