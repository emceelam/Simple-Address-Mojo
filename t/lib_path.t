#!/usr/bin/env perl

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use warnings;
use strict;
use Test::More tests => 3;

use_ok ("SimpleAddressMojo");

my $script_dir = SimpleAddressMojo::get_script_dir();
ok ($script_dir, $script_dir);

my $conf_dir = SimpleAddressMojo::get_conf_dir();
ok ($conf_dir, $conf_dir);
