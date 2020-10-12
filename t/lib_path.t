#!/usr/bin/env perl

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use warnings;
use strict;
use Scalar::Util qw(looks_like_number);
use Test::More tests => 6;

use_ok ("SimpleAddressMojo");

my $script_dir = SimpleAddressMojo::get_script_dir();
ok ($script_dir, $script_dir);

my $conf_dir = SimpleAddressMojo::get_conf_dir();
ok ($conf_dir, $conf_dir);

my $dbh = SimpleAddressMojo::get_dbh();
isa_ok($dbh, "DBI::db");
my $sth = $dbh->prepare ("
  SELECT id, street, city, state, zip
    FROM addresses
    LIMIT 1
");
$sth->execute();
my $address = $sth->fetchrow_hashref();

my $lat_lng = SimpleAddressMojo::get_lat_lng($address);
ok (looks_like_number($lat_lng->{lat}), "lat looks like number");
ok (looks_like_number($lat_lng->{lng}), "lng looks like number");
