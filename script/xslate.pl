#!/usr/bin/env perl

use warnings;
use strict;
use Text::Xslate;
use File::Slurp qw(read_file);

my $tx = Text::Xslate->new(
  suffix => '.html.tx',
  syntax => 'Kolon',
  type => 'html',   # html escaping
);

my $api_key = read_file('/home/www/sjsutech/www/namco/gmap_api_referer_key.txt');
$api_key =~ s{^\s*(.+?)\s*$}{$1};

print $tx->render('address_app.html.tx', {
  api_key => $api_key,
});