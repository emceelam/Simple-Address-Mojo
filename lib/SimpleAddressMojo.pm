package SimpleAddressMojo;

use Mojo::Base 'Mojolicious';
use Mojo::Util qw(url_escape);
use DBI;
use List::MoreUtils qw(mesh zip);
use LWP::Simple qw(get);
use JSON qw(decode_json);
use File::Slurp qw(read_file);
use FindBin;
use Data::Dumper;

# This method will run once at server start
sub startup {
  my $self = shift;
  my $dbh = get_dbh();

  if (-e "/tmp/prefork.pid") {
    my $pid = read_file ("/tmp/prefork.pid");
    chomp $pid;
    exit (0) if -e "/proc/$pid";
  }

  $self->secrets(['Mojo secret text here.']);
  $self->helper(dbh => sub { $dbh });

  # CORS
  $self->plugin('SecureCORS');
  $self->plugin('SecureCORS', { max_age => undef });

  # set app-wide CORS defaults
  $self->routes->to(
    'cors.origin'      => '*',
    'cors.credentials' => 1,
    'cors.methods'     => 'GET, POST, PUT, DELETE',
    'cors.headers'     => 'Content-Type',
  );

  # Router
  my $r = $self->routes;

  # REST API
  $r->cors('/api/addresses')->to(
    'cors.origin'      => '*',
    'cors.credentials' => 1,
    'cors.methods'     => 'POST',
    'cors.headers'     => 'Content-Type',
  );

  $r->get('/api/addresses' => sub {
    my $c = shift;
    my $sth = $dbh->prepare ("
      SELECT id, street, city, state, zip, lat, lng
        FROM addresses
    ");
    $sth->execute();
    my $rows = $sth->fetchall_arrayref();
    my @fields = qw/id street city state zip lat lng/;
    my @rows_hash = map { { mesh ( @fields, @$_ ) } } @$rows;
    $c->render(json => \@rows_hash);
  });

  $r->post('/api/addresses' => sub {
    my $c = shift;
    my %address;
    my $req_json = $c->req->json;
    @address{qw/street city state zip/} = @{$req_json}{qw/street city state zip/};
    my @missing = grep { !defined $address{$_} } keys %address;
    if (@missing) {
      $c->render(
        json => {
          status  => 404,
          message => ("missing query parameters: " . join(',', @missing)),
        },
        status => 404,  # NOT FOUND
      );
      return;
    }

    my $id;
    my $sth;
    $sth = $dbh->prepare("
      SELECT id
        FROM addresses
        WHERE street=?
          AND city=?
          AND state=?
          AND zip=?
    ");
    $sth->execute(@address{qw/street city state zip/});
    ($id) = $sth->fetchrow_array();
    if ($id) {
      $address{id} = $id;
      $c->render(json => \%address, status => '200');
      return;
    }

    $sth = $dbh->prepare("
      INSERT INTO addresses (street, city, state, zip)
        VALUES (?,?,?,?)
    ");
    $sth->execute(@address{qw/street city state zip/});
    $id = $dbh->last_insert_id("", "", "", "");
    $address{id} = $id;
    $c->render(json => \%address, status => '201');
  });

  $r->cors('/api/addresses/:id')->to(
    'cors.origin'      => '*',
    'cors.credentials' => 1,
    'cors.methods'     => 'GET, PUT, DELETE',
    'cors.headers'     => 'Content-Type',
  );

  $r->put('/api/addresses/:id' => sub {
    my $c = shift;
    my $id = $c->param('id');

    my %address;
    my $req_json = $c->req->json;
    @address{qw/street city state zip/} = @{$req_json}{qw/street city state zip/};

    my $sth = $dbh->prepare("
      UPDATE addresses
        SET street=?, city=?, state=?, zip=?, lat=?, lng=?
        WHERE id=?
    ");
    $sth->execute(@address{qw/street city state zip/}, undef, undef, $id);

    $address{id} = $id;
    $c->render(json => \%address, status => '202');
  });

  $r->get('/api/addresses/:id' => sub {
    my $c = shift;
    my $id = $c->param('id');
    my $sth = $dbh->prepare("
      SELECT id, street, city, state, zip, lat, lng
        FROM addresses
        WHERE id=?
    ");
    $sth->execute($id);
    my $row = $sth->fetchrow_hashref();
    $c->render(json => $row);
  });

  $r->delete('/api/addresses/:id' => sub {
    my $c = shift;
    my $id = $c->param('id');
    my $sth = $dbh->prepare("
      DELETE FROM addresses
        WHERE id=?
    ");
    $sth->execute($id);
    $c->render(text => 'deleted', status => '204');
  });

  $r->get('/api/addresses/:id/geocode' => sub {
    my $c = shift;
    my $id = $c->param('id');
    my $sth = $dbh->prepare("
      SELECT lat, lng, city, street, state, zip
        FROM addresses
        WHERE id=?
    ");
    $sth->execute($id);
    my $addr = $sth->fetchrow_hashref();

    # address_id not found
    if (!defined $addr) {
      $c->render(
        json => {
          status  => 404,
          message => $sth->err,
        },
        status => 404,  # NOT FOUND
      );
      return;
    }

    # lat and lng already in database
    if (defined $addr->{lat} && defined $addr->{lng} ) {
      $c->render(json => $addr);
      return;
    }

    my $lat_lng = get_lat_lng($addr);
    if (!defined $lat_lng) {
      $c->render(
        json   => {
          status  => 400,
          message => "failed to get latitude, longitude",
        },
        status => 400,
      );
      return;
    }
    $addr->{lat} = $lat_lng->{lat};
    $addr->{lng} = $lat_lng->{lng};
    $c->render(json => $addr);
  });
}

sub get_base_dir {
  return "$FindBin::Bin/..";  # directory above
}

sub get_script_dir {
  return get_base_dir() . "/script";
}

sub get_conf_dir {
  return get_base_dir();
}

sub get_dbh {
  state $dbh;

  if (!$dbh) {
    my $dir = get_script_dir();
    $dbh = DBI->connect ("dbi:SQLite:dbname=$dir/address.db", "", "")
      || die "SQLite connect fails";
  }
  return $dbh;
}

sub get_gmap_api_key {
  state $gmap_api_key;

  if (!$gmap_api_key) {
    my $conf_file = get_conf_dir() . "/address_app.conf.json";
    my $conf = JSON->new->relaxed(1)->decode(scalar read_file (
      $conf_file
    ));
    $gmap_api_key = $conf->{server_gmap_api_key}
      || die "missing server_gmap_api_key";
  }

  return $gmap_api_key;
}

# Note: this is intentionally designed so that any geocoding requesting must
# start with database verification. No database entry, no geocoding. No exception.
sub get_lat_lng {
  my $address = shift;

  my $dbh = get_dbh();
  my $sth;
  $sth = $dbh->prepare("
    SELECT id, lat, lng
      FROM addresses
      WHERE street=?
        AND city=?
        AND state=?
        AND zip=?
  ");
  $sth->execute(@$address{qw/street city state zip/});
  my ($id, $lat, $lng) = $sth->fetchrow_array();
  if (!$id) {
    print "get_lat_lng() address missing an id\n";
    return undef;
  }

  if ($lat || $lng) {
    return {lat => $lat, lng => $lng};
  }

  my ($street, $city, $state, $zip) = @$address{qw/street city state zip/};
  my $address_string = url_escape ("$street, $city, $state, $zip");
  my $gmap_api_key = get_gmap_api_key();
  my $url = "https://maps.googleapis.com/maps/api/geocode/json?address=$address_string&key=$gmap_api_key";
  my $res = LWP::Simple::get($url);
  my $geocoded = decode_json($res);
  my $lat_lng = $geocoded->{results}[0]{geometry}{location};
  if (!$lat_lng) {
    print "geocode fails: " . Dumper $res;
    return undef;
  }

  $sth = $dbh->prepare("
    UPDATE addresses
      SET lat=?, lng=?
      WHERE id=?
  ");
  $sth->execute(@$lat_lng{qw/lat lng/}, $id);

  return $lat_lng;
}


1;
