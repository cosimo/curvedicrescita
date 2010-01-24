package BabyDiary::File::Babies;

use strict;
use base qw(BabyDiary::File::SQLite);

use constant TABLE  => 'babies';
use constant FIELDS => [ qw(id parent1 parent2 gender name realname pic birthdate birthdate_d birthdate_m birthdate_y birthtime zodiac city country lat lon modified memo) ];

1;

#
# End of class

