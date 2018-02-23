#!/usr/bin/env perl

use warnings;
use strict;
use Text::Xslate;
use File::Slurp qw(read_file);
use JSON;

my $tx = Text::Xslate->new(
  suffix => '.html.tx',
  syntax => 'Kolon',
  type => 'html',   # html escaping
);
my $conf = JSON->new->relaxed(1)->decode( scalar read_file ('address_app.conf'));
my $api_key = $conf->{browser_gmap_api_key} || die "missing browser_gmap_api_key";
my $host    = $conf->{host} || die "missing host";
my $port    = $conf->{port} || die "missing port";
print $tx->render('address_app.html.tx', {
  api_key   => $api_key,
  host_port => "$host:$port",
});
