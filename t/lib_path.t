#!/usr/bin/env perl

use warnings;
use strict;
use Test::More tests => 5;

my $curr_path;

BEGIN { 
  use File::Basename qw(dirname);
  use Cwd qw(abs_path);
  $curr_path = abs_path(dirname( abs_path(__FILE__) ) . "/../lib");

  unshift @INC, $curr_path;
}

ok ($curr_path, $curr_path);

opendir(my $dir_h, $curr_path);
my @lib_files = grep {$_ =~ m{[.]pm$} } readdir($dir_h);
closedir($dir_h);

ok (@lib_files, "lib path has pm files");

use_ok ("SimpleAddressMojo");

my $script_dir = SimpleAddressMojo::get_script_dir();
ok ($script_dir, $script_dir);

my $conf_dir = SimpleAddressMojo::get_conf_dir();
ok ($conf_dir, $conf_dir);
