# $Id$

# Misc utility functions
package Opera::Util;

use strict;
use CGI ();
use Time::Piece;
use DateTime;

our $HAVE_UNACCENT = eval 'use Text::Unaccent (); return 1';

{
    my $time_obj;

    # Generate dates in SQL ISO format (YYYY-MM-DD hh:mm:ss)
    # for MySQL timestamp field values
    sub current_timestamp {
        my $ts;
        $time_obj ||= Time::Piece->new();
        $ts  = $time_obj->ymd();
        $ts .= ' ';
        $ts .= $time_obj->hms();
        return($ts);
    }

	sub format_date {
		my ($date) = @_;
		$date =~ s{^ (\d+) \- (\d+) \- (\d+) \s+ (\d+) : (\d+) : (\d+) $}{$3.$2.$1 $4:$5}x;
		return $date;
	}

}

sub format_date_iso8601 {
	my ($date) = @_;
	# Convert SQL date to ISO8601 that Google accepts
	$date =~ s{^ (\d+ \- \d+ \- \d+) \s+ (\d+ : \d+ : \d+) $}{$1T$2+01:00}x;
	return $date;
}

#
# Trim from a string both leading and trailing spaces
#
sub btrim {
    my $string = $_[0];
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return($string);
}

#
# Make a "marker" style background appear around selected words
#
sub highlight_term {
    my($term, $text_ref) = @_;

    # Case insensitive search for words
    if (defined $term && $term ne '') {
        ${$text_ref} =~ s{\b($term)\b}{<span class="highlight">$1</span>}gi;
    }
	
	return;
}

#http://www.google.com/search?client=opera&q=bambini%20e%20%22curve%20di%20crescita%22&sourceid=opera&ie=utf-8&oe=utf-8
sub search_url_terms {
	my ($url) = @_;

	# No referrer, so not possible to highlight terms
	if (! $url && exists $ENV{HTTP_REFERER}) {
		$url = $ENV{HTTP_REFERER};
	}

	if (! $url) {
		return;
	}

	# Get search engine terms
	my $terms = q{};
	if ($url =~ m{https?:// .*/ search \? .* &? q=([^&]+)}x) {
		$terms = $1;
	}
	elsif ($url =~ m{https?:// .*/ search \? .* &? query=([^&]+)}x) {
		$terms = $1;
	}

	if (! $terms) {
		return;
	}

	$terms = CGI->unescape($terms);

	my @words;
	while ($terms =~ m{("[^"]+")}g) {
		push @words, substr($1, 1, -1);
	}	

	if ($terms =~ m{\S}) {
		push @words, split m{\s+}, $terms;
	}

	# Remove stopwords
	for (0 .. $#words) {
		if (length($words[$#words - $_]) < 4) {
			delete $words[$#words - $_];
		}
	}

	return @words;
}

# Poor man's slug
sub slug {
	my ($string, $date) = @_;
	my $slug = lc $string;

	if (defined $date) {
		$date =~ s{^(\d+)-(\d+)-(\d+).*$}{$1/$2/$3};
	}

	$slug =~ s{\b(il|la|lo|gli|le|d|di|del|delle|degli|della|a|al|allo|alla|alle|agli|ad|da|in|con|su|per|tra|fra|un|uno|una|e|i|o|oppure|che|nel|nella|negli|nelle|sul|sullo|sulla|sugli|sulle)\b}{}g;

	if ($HAVE_UNACCENT) {
		$slug = Text::Unaccent::unac_string('utf-8', $slug);
	}

	$slug =~ s{[^a-z0-9\s-]}{}g;
	$slug =~ s{\s+}{ }g;

	$slug = btrim($slug);
	$slug = substr($slug, 0, 60);
	$slug =~ y{ }{-}d;

	$slug =~ s{\-\-+}{-}g;
	$slug =~ s{^\-+}{};
	$slug =~ s{\-+$}{};

	if (defined $date) {
		$slug = "$date/$slug";
	}

	return $slug;
}

sub format_date_natural {
	my ($date, $locale) = @_;

	$locale ||= 'it';

	my $text = $date;
	my $now = time();
	my $epoch = 0;

	# Unix epoch
	if ($date =~ m{^\d+$}) {
		$epoch = $date;
	}
	# SQL/ISO (yyyy-mm-dd hh:mn:ss)
	else {
		my (@bits) = $date =~ m{^ (\d+) \- (\d+) \- (\d+) \s+ (\d+) : (\d+) : (\d+) $}x;

		my $dt = DateTime->new(
			year   => $bits[0],
		    month  => $bits[1],
		    day    => $bits[2],
		    hour   => $bits[3],
		    minute => $bits[4],
		    second => $bits[5],
		    time_zone  => 'Europe/Rome',
		);
		if (! $dt) {
			return $text;
		}
		$epoch = $dt->epoch();
	}

	# Convert from epoch to natural text
	my $dt = DateTime->from_epoch(
		epoch => $epoch,
		locale => $locale
	);

	$text  = $dt->day() . ' ' . $dt->month_name . ' ' . $dt->year();
	$text .= ' ';
	$text .= $dt->hms();

	return $text;
}

1;

#
# End of module

=pod

=head1 NAME

Opera::Util - Misceallaneous utility functions

=head1 SYNOPSIS

  my $string = ' BLA BLA BLA    ';
  my $trimmed = Opera::Util::btrim($string);
  # $trimmed = 'BLA BLA BLA';

  my $ts = Opera::Util::current_timestamp();
  # $ts = '2007-06-05 21:57:28';

=head1 DESCRIPTION

Ungrouped utility functions. If they grow into something more organized, they
will be split in date/time, string, ...

=head1 METHODS

Brief explanation of main methods for this class

=over -

=item btrim($str)

Trims leading and trailing spaces from a string. Returns result in another string.

=item current_timestamp()

Returns the current timestamp as string in MySQL compatible format.
Example: '2007-06-05 21:57:28'

=back

=head1 SEE ALSO

=over -

=item L<Time::Piece>

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut

