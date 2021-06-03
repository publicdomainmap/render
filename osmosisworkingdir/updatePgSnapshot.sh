#!/bin/sh

# --read-replication-interval-init <-- must be run the first time to make the state.txt file
START_FILE=./start.txt
EXPIRED_FILE=./expired.txt

if [ -f "$START_FILE" ]; then
  START_TIME=$(cat $START_FILE)
  APPEND="--append"
else 
  START_TIME="2000-01-01_00:00:00" #yyyy-MM-dd_HH:mm:ss
  APPEND="--create"
fi
END_TIME=$(date +'%Y-%m-%d_%H:%M:%S')

echo "Starting at: " $START_TIME
echo "Ending at: " $END_TIME

osmosis \
  --read-apidb-change host=$PGHOST database=$OSM_POSTGRES_DB password=$OSM_POSTGRES_PASSWORD user=$OSM_POSTGRES_USER \
    intervalBegin=$START_TIME intervalEnd=$END_TIME validateSchemaVersion=no \
  --simplify-change --write-xml-change - | \
osm2pgsql \
 $APPEND \
 --input-reader=xml \
 --database="host=$PGHOST port=$PGPORT dbname=$PGS_POSTGRES_DB user=$PGS_POSTGRES_USER password=$PGS_POSTGRES_PASSWORD" \
 --cache 1000 \
 --number-processes 4 \
 --expire-tiles 8-15 \
 --expire-output=$EXPIRED_FILE \
 --slim \
 - \
 && echo $END_TIME > $START_FILE

#TODO Expire Tiles with the $EXPIRED_FILE
