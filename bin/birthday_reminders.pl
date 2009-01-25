#!/usr/bin/env perl

use strict;
use warnings;

=cut

use lib '../lib';
use BabyDiary::Notifications;

BabyDiary::Notifications::send_birthday_reminders();


