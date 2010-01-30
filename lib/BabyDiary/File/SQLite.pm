# $Id$

# Custom MYSQL driver for BabyDiary::File::Base class
package BabyDiary::File::SQLite;

use strict;
use Carp;
use BabyDiary::Config;
use base qw(Opera::File::SQLite);

use constant DBNAME => BabyDiary::Config->get('database_name');
use constant DBUSER => '';
use constant DBPASS => '';

1;

