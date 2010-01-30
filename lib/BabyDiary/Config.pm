package BabyDiary::Config;

use strict;
use Carp;
use Config::Auto;

our $CONFIG_FILE = '../conf/babydiary.conf';
our $CONFIG_OBJ;

sub new {
	$CONFIG_OBJ ||= Config::Auto::parse($CONFIG_FILE) or croak "Can't find config file $CONFIG_FILE: $!";
	return $CONFIG_OBJ;
}

sub get {
	my ($self, $key) = @_;
	my $conf = BabyDiary::Config::new();
	if (! exists $conf->{$key}) {
		croak "Non-existent config key '$key'";
	}

	# Messy MS/DOS files
	my $value = $conf->{$key};
	$value =~ s{\r}{}g;
	return $value;
}

1;

