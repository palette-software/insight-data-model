#!/bin/bash

set -e

ROOTDIR=`dirname $0`
MIGRATIONS_DIR=${ROOTDIR}/migrations


MIGRATION_VERSIONS="v1.1.7 v1.1.8 v1.1.9 v1.1.10 v1.1.11 v1.1.12 v1.1.13 v1.1.14 v1.1.15 v1.1.16 v1.1.17 v1.1.17.1"


#EXISTING_VERSION="v1.1.14"
EXISTING_VERSION=`psql -d palette -c -t "select version_number from palette.db_version_meta limit 1;"`
EXISTING_VERSION_IDX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${EXISTING_VERSION}" 'BEGIN{print index(a,b)}'`




for VERSION in $MIGRATION_VERSIONS
do
  LOCAL_INDEX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${VERSION}" 'BEGIN{print index(a,b)}'`
  if [[  $LOCAL_INDEX -gt $EXISTING_VERSION_IDX   ]]; then
    echo Need to run: $VERSION

    cd ${MIGRATIONS_DIR}/${VERSION}

    psql -d palette -f "!install-up.sql"

    cd ../..
  fi
done
