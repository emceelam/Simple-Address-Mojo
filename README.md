# NAME

Simple Adddress App

# DESCRIPTION

This is the REST side of a simple address app, utilizing Google Maps. The REST side is coded with Mojolicious.

# SYNOPSIS

Run REST server

    ./script/simple_address_mojo prefork


# GETTING A GOOGLE MAP API KEY

Get a [Google Map API key](https://developers.google.com/maps/documentation/javascript/get-api-key).

If you are running on a public web server, you need a google map API key with Key Restriction set to "IP Addresses"

If you are running on a localhost, you can generate your API key, and set Key restriction to "None".

# INSTALL

Open terminal

    sudo cpanm \
      Mojolicious \
      Mojolicious::Plugin::SecureCORS \
      File::Slurp \
      JSON \
      DBD::SQLite \
      LWP::Simple

    make

    vi address_app.conf.json
      # Add API key(s)

Now run it

    ./script/simple_address_mojo prefork

Connect to the REST server with the [client](https://github.com/emceelam/Simple-Address-Client)

# AUTHOR

Lambert Lum

![email address](http://sjsutech.com/small_email.png)

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Lambert Lum

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
