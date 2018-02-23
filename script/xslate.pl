#!/usr/bin/env perl

use warnings;
use strict;
use Text::Xslate;
use File::Slurp qw(read_file);
use Mojo::JSON qw(decode_json);

my $tx = Text::Xslate->new(
  suffix => '.html.tx',
  syntax => 'Kolon',
  type => 'html',   # html escaping
);

my $conf = decode_json(read_file ('address_app.conf'));
my $api_key = $conf->{api_key};
my $host    = $conf->{host};
my $port    = $conf->{port};
print $tx->render('address_app.html.tx', {
  api_key   => $conf->{api_key},
  host_port => "$host:$port",
});
