# NAME

Simple Adddress App

# DESCRIPTION

This is a simple address app, utilizing Google Maps, AJAX, and REST. The REST side is coded with Perl Mojolicious.

# SYNOPSIS

Run REST server

    ./script/simple_address_mojo daemon

From web browser

    http://localhost:3000/address_app.html

# Getting a Google Map API KEY

Get a [Google Map API key](https://developers.google.com/maps/documentation/javascript/get-api-key).

If you are running on a public web server, you need two Google Map API keys, one for browser, another for server. For the browser, generate an API key and set Key Restriction to "HTTP referrers". For the server, generate an API key and set Key Restriction to "IP Addresses"

If you are running on a localhost, you can use a single API key for both browser and server. When you generate your API key, set Key restriction to "None".

# INSTALL

Open terminal

    sudo cpanm \
      Mojolicious \
      File::Slurp \
      JSON \
      DBD::SQLite \
      Text::Xslate \
      Mojolicious::Plugin::SecureCORS

    make

    vi address_app.conf.json
      # Add API key(s)
      # Set hostname if public web server

    make
      # uses modified address_app.conf to regenerate files

Now run it

    ./simple_address_mojo daemon


# AUTHOR

Lambert Lum

![email address](http://sjsutech.com/small_email.png)

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Lambert Lum

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
