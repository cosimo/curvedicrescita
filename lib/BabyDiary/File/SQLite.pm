# $Id$

# Custom MYSQL driver for BabyDiary::File::Base class
package BabyDiary::File::SQLite;

use strict;
use Carp;
use base qw(Opera::File::SQLite);

use constant DBNAME => 'E:/users/cosimo/Desktop/curvedicrescita.com/database/data/babydiary.sqlite';
use constant DBUSER => '';
use constant DBPASS => '';

1;

