# $Id: CSV.pm,v 1.3 2007/06/05 21:55:15 cosimo Exp $

package Opera::File::CSV;

use strict;
use DBI;

sub new
{

	my($ref, $opt) = @_;
    my $class = ref $ref || $ref;

    my $dir      = $opt->{'dir'};
    my $filename = $opt->{'filename'};
    my $table    = $opt->{'table'};
	my $fields   = $opt->{'fields'};
	my $quotechar= exists $opt->{'quote_char'} ? $opt->{'quote_char'} : '"';

	my $dbh = DBI->connect('DBI:CSV:f_dir='.$dir);

	$dbh->{'csv_tables'}->{$table} = {
        'eol'         => qq[\r\n],
        'sep_char'    => qq[\t],
        'quote_char'  => $quotechar,
    	'always_quote'=> 0,
        'escape_char' => $quotechar,
        'file'        => $filename,
        'col_names'   => $fields
	};

    my $self = {
    	_dbh      => $dbh,
    	_table    => $table,
    	_fields   => $fields,
    	_dir      => $dir,
    	_filename => $filename
    };

	bless $self, $class;

}

sub dbh {
	$_[0]->{'_dbh'};
}

1;

#
# End of class

=pod 

=head1 NAME

Opera::File::CSV - base class to access CSV files through DBI

=head1 SYNOPSIS

Use as a base class, deriving from it.

=head1 INCOMPLETE!

=cut

