package SimpleAddressMojo;

use Mojo::Base 'Mojolicious';
use Mojo::Util qw(url_escape);
use DBI;
use List::MoreUtils qw(mesh zip);
use LWP::Simple qw(get);
use JSON;
use File::Slurp qw(read_file);
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use Data::Dumper;

# This method will run once at server start
sub startup {
  my $self = shift;
  my $dbh = get_dbh();

  $self->secrets(['Mojo secret text here.']);
  $self->helper(dbh => sub { $dbh });

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

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

  # Web page
  $r->get('/' => sub {
    my $c = shift;
    $c->redirect_to('/address_app.html');
  });

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
    $address{id} = $id;
    $address{lat} = undef;
    $address{lng} = undef;

    my $sth = $dbh->prepare("
      UPDATE addresses
        SET street=?, city=?, state=?, zip=?, lat=?, lng=?
        WHERE id=?
    ");
    $sth->execute(@address{qw/street city state zip lat lng id/});
    $c->render(json => \%address, status => '202');
  });
  
  $r->get('/api/addresses/:id' => sub {
    my $c = shift;
    my $id = $c->param('id');
    my $sth = $dbh->prepare("
      SELECT id, street, city, state, zip
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
  
  $r->get('/api/geocode' => sub {
    my $c = shift;
    my %address;  

    @address{qw/street city state zip/} = (
      $c->param('street') || '',
      $c->param('city'  ) || '',
      $c->param('state' ) || '',
      $c->param('zip'   ) || '',
    );
    my %errors;
    foreach my $k (keys %address) {
      $address{$k} =~ s{^\s+(.+?)\s+}{$1};
      if (!length($address{$k})) {
        $errors{$k} = "$k is empty";
      }
    }
    if ($address{zip} =~ m{\D}) {
      $errors{zip} = "zip must be entirely numbers";
    }
    if (%errors) {
      $c->render(
        json => {
          status  => 400,
          message => "Validation failed",
          errors  => [
            map {  { field => $_, message => $errors{$_} } } keys %errors
          ],
        },
        status => 400,
      );
      return;
    }
    my $lat_lng = get_lat_lng(\%address);
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
    $c->render(json => $lat_lng);
  });
}

sub get_script_dir {
  state $dir || dirname(abs_path($0));
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
    my $dir = get_script_dir();
    my $conf = decode_json(read_file ("$dir/address_app.conf"));
    $gmap_api_key = $conf->{server_gmap_api_key}
      || die "missing server_gmap_api_key";
  }

  return $gmap_api_key;
}

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
  my $geocoded = JSON->new->relaxed(1)->decode($res);
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
