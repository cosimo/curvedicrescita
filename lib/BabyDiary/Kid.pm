package BabyDiary::Kid;

use strict;
use Date::Calc ();

sub new {
    my $class = shift;
    $class = ref $class || $class;
    bless { @_ } => $class;
}

sub color {
    my ($self) = @_;
    return $self->{color};
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub birthdate {
    my ($self) = @_;
    wantarray
        ? split '/', $self->{birthdate}
        : $self->{birthdate};
}

# Returns age in days
sub age {
    my ($self) = @_;
    my @today = localtime();
    my @bdate = reverse $self->birthdate;
    my $age = Date::Calc::Delta_Days(
        @bdate,
        1900 + $today[5], 1 + $today[4], $today[3]
    );
    return $age;
}

# Select chart for boy/girl and 0..2 or 2+ year old
sub chart {
    my ($self) = @_;
    my $gender = $self->gender();
    my $age    = $self->age();

    my $charts = [
        [ 'chart01', 'chart02' ],
        [ 'chart03', 'chart04' ],
    ];

    return $charts
        -> [ $age < 366 * 2 ? 0 : 1 ]
        -> [ $gender eq 'M' ? 0 : 1 ]
        ;
}

sub gender {
    my ($self) = @_;
    return uc $self->{gender} || 'M';
}

1;
