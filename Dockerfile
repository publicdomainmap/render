FROM openjdk:17-slim-buster

MAINTAINER Arne Schubert <atd.schubert@gmail.com>

ARG OSMOSIS_URL="https://github.com/openstreetmap/osmosis/releases/download/0.48.3/osmosis-0.48.3.tgz"
ARG OSM2PGSQL_VERSION=1.5.1
ARG OSM2PGSQL_URL="https://github.com/openstreetmap/osm2pgsql/archive/refs/tags/$OSM2PGSQL_VERSION.tar.gz"
ENV OSMOSIS_URL $OSMOSIS_URL
ENV OSM2PGSQL_URL $OSM2PGSQL_URL

RUN apt-get update && apt-get install -y \
  cmake \
  curl \
  g++ \
  libboost-dev \
  libboost-filesystem-dev \
  libboost-system-dev \
  libbz2-dev \
  libexpat1-dev \
  liblua5.3-dev \
  libpq-dev \
  libproj-dev \
  lua5.3 \
  make \
  pandoc \
  zlib1g-dev \
&& rm -rf /var/lib/apt/lists/*

RUN set -x \
  && useradd -ms /bin/bash osmosis \
  && mkdir -p /opt/osmosis \
  && curl -L $OSMOSIS_URL | tar xz -C /opt/osmosis \
  && ln -s /opt/osmosis/bin/osmosis /usr/local/bin/osmosis

# osm2pgsql
RUN mkdir /opt/osm2pgsql \
    && curl -L $OSM2PGSQL_URL | tar xz -C /opt/osm2pgsql \
    && cd /opt/osm2pgsql/osm2pgsql-$OSM2PGSQL_VERSION \
    && mkdir ./build \
    && cd ./build \
    && cmake .. \
    && make \
    && make install \
    && cd / \
    && rm -rf /opt/osm2pgsql 
