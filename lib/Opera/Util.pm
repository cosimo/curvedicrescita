# $Id$

# Misc utility functions
package Opera::Util;

use strict;
use CGI ();
use Time::Piece;

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

