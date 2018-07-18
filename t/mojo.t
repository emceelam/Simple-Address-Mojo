#!/usr/bin/env perl


use warnings;
use strict;
use Cwd qw(abs_path);
use File::Basename qw(dirname);

BEGIN {
  unshift @INC, abs_path(dirname( abs_path(__FILE__) ) . "/../lib");
}

use Mojo::Base - strict;
use Test::More tests => 2;
use Test::Mojo;

my $t = Test::Mojo->new('SimpleAddressMojo');

$t->get_ok('/api/addresses')
  ->status_is(200);
