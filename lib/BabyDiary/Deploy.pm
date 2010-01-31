# $Id$

package BabyDiary::Deploy;

use strict;
use warnings;
use File::Spec;
use File::Path;

BEGIN {
	$ENV{LANG} = '';
}

our $SVN_ROOT = 'file:///svnroot/curvedicrescita.com';
our $SVN = 'svn';
our $TAR = 'tar';
our $DEV_NULL = $^O eq 'MSWin32' ? 'NUL' : '/dev/null';

sub user {
    'cosimo';
}

sub password {
    '';
}

sub host {
    'satsrv02.satelgroup.net';
}

sub folder {
    '/var/www2/www.curvedicrescita.com';
}

sub ssh_dest {
    my $url = user() . '@' . host() . ':' . folder();
    return $url;
}

sub windows_to_unix_path {
    my ($file) = @_;

    # Remove Windows drive letter (if any)
    $file =~ s{^\w:}{};

    # Dest path has forward slashes
    $file =~ s{\\}{/}g;

    return $file;
}

sub deploy_live {
    my ($file, $dest) = @_;

    $file = windows_to_unix_path($file);

    if (! defined $dest) {
        $dest = ssh_dest() . '/' . $file;
    }

    #my $copy_cmd = qq{d:\\bin\\pscp $file $dest >$DEV_NULL};
    my $copy_cmd = qq{scp $file $dest >$DEV_NULL};
    #print $copy_cmd, "\n";

    my $status = system($copy_cmd);
	$status >>= 8;

    return (0 == $status);
}

sub new_revision {
	my @svn_info = `$SVN info templates/revision`;
	my $svn_info = join("", @svn_info);
	my $new_rev;

	if ($svn_info =~ m{Last Changed Rev: (\d+)}sim) {
		$new_rev = $1;
	}

	return $new_rev;
}

sub launch_missiles {
	my ($tree) = @_;

	$tree ||= 'trunk';
	$tree = "$SVN_ROOT/$tree";

	my $rev = new_revision();
	my $dest = "deploy-r$rev-" . time();

	print "- exporting svn source tree (r$rev)\n";

	my $export_cmd = "$SVN export $tree $dest >$DEV_NULL";
	my $status = system($export_cmd);

	$status >>= 8;

	my @exclude_dirs = qw(blog charts database/data dns docs gfx logs);
	for (@exclude_dirs) {
		print "- excluding dir $_\n";
		File::Path::rmtree(File::Spec->catdir($dest, $_));
	}

	# Convert all shebang lines to /usr/bin/perl
	#for (qw(bin exec)) {
	#	opendir my $dir, $_;
	#	my @files = grep { $_ =~ m{\.(pl|perl)$} } readdir $dir;
	#	closedir $dir;
	#	for (@files) {
	#		
	#	}
	#
	#}

	print "- creating deployment archive $dest.tar.gz\n";

	my $tar = 'tar';
	my $tar_cmd = "$tar cf $dest.tar $dest";
	system($tar_cmd);
	system("gzip --best $dest.tar");
	system("ls -l $dest.tar.gz");
	system("rm -rf $dest");

	return (0 == $status);
}

1;
