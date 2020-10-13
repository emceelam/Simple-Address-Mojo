# Docker

You should already have docker installed. If not, please read [Install Docker Engine](https://docs.docker.com/engine/install/)

Add your Google Map API key

    cp address_app.conf.example address_app.conf.json
    vi address_app.conf.json

Build and run a docker container

    docker image build --tag=simple_address_mojo:latest --file=Dockerfile .

    docker container run \
      --rm \
      --detach \
      --name simple_address_mojo \
      --publish 3000:3000 \
      simple_address_mojo:latest

When you are done

    docker container stop simple_address_mojo
