#!/usr/bin/env perl

use warnings;
use strict;
use Cwd qw(abs_path);
use File::Basename qw(dirname);

use Mojo::Base - strict;
use Test::More tests => 10;
use Test::Mojo;

my $t = Test::Mojo->new();

my $domain = 'localhost';
my $port = 3000;
my $url = "http://$domain:$port";
$t->get_ok("$url/api/addresses")
  ->status_is(200);

$t->get_ok("$url/api/addresses/1")
  ->status_is(200);

$t->get_ok("$url/api/addresses/1/geocode")
  ->status_is(200);

$t->post_ok("$url/api/addresses")
  ->status_is(404)
  ->json_like(
    '/message' => qr{^missing query parameters:\s[a-zA-Z,]+$},
    'missing query parameters')
  ->json_has('/status');

