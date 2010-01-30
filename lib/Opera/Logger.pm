# $Id$

# Logging class
package Opera::Logger;

use strict;
use File::Path     ();
use File::Basename ();
use BabyDiary::Config;

# Default path for logging
$Opera::Logger::APP_LOG_FILE = BabyDiary::Config->get('application_log_file');

# Constructor
sub new
{
	my( $class, %opt ) = @_;

    # Logger type (File, Syslog, Mysql?)
    my $type     = $opt{type};
    my $filename = $opt{file} || default_filename();

	my %obj = (
		file     => $filename,
		loglevel => 'info'
	);

	my $self = bless \%obj, $class;

    # Create dir if does not exist
	if( ! -d File::Basename::dirname($self->{file}) ) {
		File::Path::mkpath( File::Basename::dirname($self->{file}), 0, 0755 );
	}

	# Open file in append mode at the start and save reference
	if( open(my $log_fh, '>>' . $self->{file}) )
    {
		$self->{fh} = $log_fh;

		# Unbuffer writes to logfile
		my $oldfh = select $self->{fh};
		$| = 1;
		select $oldfh;
	}
    else
    {
		warn('Could not open ' . $self->{file} . ' to start logging');
	}

	return $self;
}

#
# Colorize log output depending on log level
#
sub colorize
{
    my($self, $level, $r_msg) = @_;

    my $start_col = '';
    my $end_col   = chr(0x1B) . '[0m';

    # Colorize 'warning' messages with yellow
    if($level eq 'warn')
    {
        $start_col = chr(0x1B) . '[1;33m';
    }
    # Colorize 'error' messages with red
    elsif($level eq 'error')
    {
        $start_col = chr(0x1B) . '[1;31m';
    }
    # Add colorize ascii strings on head and tail of array
    if($start_col ne '')
    {
        unshift @$r_msg, $start_col;
        push    @$r_msg, $end_col;
    }
    return;
}

# Provide a suitable filename default
sub default_filename
{
	return $Opera::Logger::APP_LOG_FILE;
}

#
# Transforms ref data structures into strings to be logged
#
sub dumper
{
    my($self, $r_msg) = @_;

    # Empty list, do nothing
    if(!$r_msg)
    {
        return;
    }

    # Transform complex data structures in strings
    for my $elem (@$r_msg)
    {
        my $type = ref $elem;
        if($type eq 'ARRAY')
        {
            $elem = join(' ', @$elem);
        }
        elsif($type eq 'HASH')
        {
            $elem = join( ', ', map { $_ . '=`' . $elem->{$_} . '\'' } keys %$elem);
        }
    }

    return;
}

# Returns filename. Accessor.
sub filename
{
	my $self = shift();
	$self->{file} ||= $self->default_filename();
	return $self->{file};
}

# Writes to log file
sub write
{
	my($self, $level, @msg) = @_;
    my $ok = 1;

    # Obtain log handle and write into file
    if(my $fh = $self->handle())
    {

        # Dump references into strings
        $self->dumper(\@msg);

        # Colorize log messages depending on log level
        $self->colorize($level, \@msg);

        # Convert CR,LF chars, to avoid line breaks into logfile
        tr/\r\n/^M/s for @msg;
        print $fh join("\t", scalar localtime, $0, $$, $level, join($,,@msg)), "\n";
    }
    # Handle not available?
    else
    {
        $ok = 0;
    }

    return($ok);
}

# Access logfile filehandle
sub handle
{
	my $self = shift;
	return $self->{'fh'};
}

# Wrapper methods for special log levels
sub error
{
    my $self = shift;
    $self->write('error', @_);
}

sub warn
{
    my $self = shift;
    $self->write('warn', @_);
}

sub notice
{
    my $self = shift;
    $self->write('notice', @_);
}

1;

#
# End of class

=head1 NAME

Opera::Logger - Centralized text file logging for Opera::Application

=head1 SYNOPSIS

  my $logger = Opera::Logger->new( type=>'file', file=>'/tmp/mylog.txt' );

  $logger->notice('Session is expired. Creating new');
  $logger->warn('User has modified cookie "SID"!');
  $logger->error('Database record [...] invalid!');
  $logger->write('warn', 'Test of log() method');

=head1 METHODS

=over -

=item new(%options)

Class constructor.
Allowed options are "type" to specify the log type. For now its only "file".
Other types could be "syslog" or "database"?
Other option is "file" to specify the log file you want to append information to.

Default is provided in the C<$Opera::Logger::APP_LOG_FILE> variable.

=item notice(@log_message)

=item warn(@log_message )

=item error(@log_message )

All alias methods that wrap to C<write()>.

=item write( $level, @log_message )

Writes a message into application log file. Message can be split in many elements
(the C<@log_message> array), or be only one. If an element is an arrayref or hashref,
it is expanded in a string before logging.

Carriage return/line feeds are automatically converted to non-printable char (^M)
before outputting to log.

=item Other methods

All other methods are considered internal.

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
