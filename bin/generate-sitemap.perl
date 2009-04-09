#!/usr/bin/env perl
#
# Google sitemap generator 
# 
# $Id$

use strict;
use warnings;
use lib '../lib';
use BabyDiary::Sitemap;

BabyDiary::Sitemap::generate();

