# NAME

Simple Adddress App

# SYNOPSIS

Run REST server

    ./script/simple_address_mojo daemon

From web browser

    http://localhost:3000/address_app.html

# INSTALL

    sudo cpanm \
      Mojolicious \
      File::Slurp \
      JSON \
      DBD::SQLite \
      Text::Xslate \
      Mojolicious::Plugin::SecureCORS
    cd script
    make

# DESCRIPTION

This is a simple address app, utilizing Google Maps, AJAX, and REST. The REST side is coded with Perl Mojolicious.

# AUTHOR

Lambert Lum

![email address](http://sjsutech.com/small_email.png)

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Lambert Lum

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
