FROM alpine:latest

LABEL maintainer="Lambert Lum"
LABEL description="Simple Address REST server (Mojolicious)"

WORKDIR /root

COPY . .

RUN apk add g++ make wget curl perl-dev perl-app-cpanminus \
     perl-mojolicious perl-json perl-file-slurp \
     sqlite sqlite-dev perl-dbd-sqlite \
     openssl perl-io-socket-ssl perl-net-ssleay \
  && cpanm \
      Mojolicious::Plugin::SecureCORS \
  && make script/address.db \
  && apk del g++ make wget curl \
      perl-dev perl-app-cpanminus \
  && rm -rf /usr/local/share/man/* .cpanm

ENTRYPOINT ["./script/simple_address_mojo", "prefork"]

EXPOSE 3000/tcp
