package BabyDiary::Chart;

use strict;
use Carp;
use PDF::API2;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my %opt = @_;
    if (! $opt{kid}) {
        croak("'kid' object required to create a chart!");
    }
    bless { %opt }, $class;
}

sub draw_weight_chart {
    my ($self, $points) = @_;

    if (! $points || ref $points ne 'ARRAY') {
        return;
    }

    my $kid = $self->kid();

    # Get graphics and text contexts
    my $page = $self->page();
    my $gfx = $page->gfx();
    my $txt = $page->text();

    my $birthdate = [ $kid->birthdate() ];
    
    # Setup a simple font
    $txt->font($self->pdf->corefont('Helvetica', -encoding=>'utf8'), 4);
    $txt->fillcolor('black');

    # Trace first point
    my $first_point = $points->[0];
    my ($x, $y) = $self->calc_point_xy($kid, $first_point);
    $gfx->strokecolor($self->kid->color);
    $gfx->move($x, $y);

    # Draw lines from first point onwards
    for (@$points) {
        my $p = $_;
        ($x, $y) = $self->calc_point_xy($kid, $p);
        $gfx->line($x, $y);
        $gfx->stroke();
        $self->draw_weight_point($x, $y, 'black');

        my $label = sprintf("%.2f", $p->[3]);
        my $str_width = $txt->advancewidth($label);
        $txt->translate($x - $str_width / 2, $y + 5);
        $txt->text($label);

        $gfx->move($x, $y);
    }

    # Draw text: name and dates
    $txt->font($self->pdf->corefont('Helvetica-Bold', -encoding=>'utf8'), 14);
    $txt->fillcolor('black');
    my $text_x = 354;
    my $text_y = 150;
    $txt->translate($text_x, $text_y + 45);
    $txt->text($kid->name);
    $txt->font($self->pdf->corefont('Helvetica', -encoding=>'utf8'), 9);
    $txt->translate($text_x, $text_y + 25);
    $txt->text('Data di nascita: ' . $kid->birthdate);
    $txt->translate($text_x, $text_y + 15);
    my @today = localtime();
    $txt->text('Crescita al: ' . $today[3] . '/' . ($today[4] + 1) . '/' . (1900+$today[5]));
    $txt->translate($text_x, $text_y);
    $txt->text('www.curvedicrescita.com');

    # Draw reference points
    my $range = $self->range;
    my @chart_limits;

    if ($range eq '0_2') {
        @chart_limits = (24, 15);
    }
    elsif ($range eq '0_5') {
        @chart_limits = (60, 24);
    }

    my $x1 = $self->age_x(0);
    my $x2 = $self->age_x($chart_limits[0]);
    my $y1 = $self->weight_y(0);
    my $y2 = $self->weight_y($chart_limits[1]);

    $self->draw_weight_point($x1, $y1);
    $self->draw_weight_point($x2, $y1);
    $self->draw_weight_point($x1, $y2);
    $self->draw_weight_point($x2, $y2);

    return;
}

sub calc_point_xy {
    my ($self, $kid, $point) = @_;
    my ($day, $month, $year, $weight) = @$point;
    my $age = $self->date_diff($kid->birthdate, $day, $month, $year);
    $age /= 30.4375;  # from WHO charts documentation
    my $x = $self->age_x($age);
    my $y = $self->weight_y($weight);
    return ($x, $y);
}

{
    require Date::Calc;
    sub date_diff {
        my ($self, $d1, $m1, $y1, $d2, $m2, $y2) = @_;
        my $age = Date::Calc::Delta_Days(
            $y1, $m1, $d1,
            $y2, $m2, $d2
        );
        return $age;
    }
}

sub draw_weight_point {
    my ($self, $x, $y, $color) = @_;
    $color ||= $self->kid->color();
    $self->draw_cross($x, $y, $color, 4);
    return;
}

sub draw_cross {
    my ($self, $x, $y, $color, $size) = @_;

    if (! defined $color) { $color = $self->kid->color }
    if (! defined $size)  { $size = 10 }

    my $size_2 = $size / 2;
    my $gfx = $self->page->gfx;

    # Set stroke color
    $gfx->strokecolor($color);

    # Vert. line
    $gfx->move($x - $size_2, $y);
    $gfx->line($x + $size_2, $y);
    $gfx->stroke();

    # Horiz. line
    $gfx->move($x, $y + $size_2);
    $gfx->line($x, $y - $size_2);
    $gfx->stroke();

    return;
}

sub draw_grid {
    my ($self, $color, $step, $width, $height) = @_;

    if (! defined $width)  { $width  = -500 }
    if (! defined $height) { $height = -500 }
    if (! defined $step)   { $step   = 10 }
    if (! defined $color)  { $color  = $self->kid->color }

    for (my $x=0; $x <= $width; $x += $step) {
        for (my $y=0; $y <= $height; $y += $step) {
            $self->draw_cross($x, $y, $color, 6);
        }
    }

    return;
}

sub filename {
    $_[0]->{filename};
}

sub page {
    my $self = shift;
    if (exists $self->{__page}) {
        return $self->{__page};
    }
    else {
        $self->{__page} = $self->pdf->openpage(1);
    }
    return $self->{__page};
}

sub pdf {
    my $self = shift;
    if (exists $self->{__pdf}) {
        return $self->{__pdf};
    }
    else {
        warn "Trying to open {" . $self->filename . "}\n";
        $self->{__pdf} = PDF::API2->new();
        $self->{__pdf}->mediabox($self->mediabox());
        my $chart = PDF::API2->open($self->filename);
        if (! $chart) {
            croak("Can't open chart: " . $self->filename);
        }
        $self->{__pdf}->importpage($chart, 1);
    }
    return $self->{__pdf};
}

sub type {
    my ($self) = @_;
    return $self->{type};
}

sub kid {
    my ($self) = @_;
    return $self->{kid};
}

sub save {
    my ($self, $name) = @_;
    $name ||= $self->filename() . '.new.pdf';
    return $self->pdf->saveas($name);
}

sub range {
    my ($self) = @_;

    # Custom range was specified at construction time
    if (exists $self->{range}) {
        return $self->{range};
    }

    my $age = $self->kid->age();
    my $range = $age > 2 * 365 ? '0_5' : '0_2';

    return $range;
}

1;
