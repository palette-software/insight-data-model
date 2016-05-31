#!/bin/bash

set -e

ROOTDIR=`dirname $0`
MIGRATIONS_DIR=${ROOTDIR}/migrations


MIGRATION_VERSIONS=`ls ${MIGRATIONS_DIR} | sort -V`


#EXISTING_VERSION="v1.1.11"
EXISTING_VERSION=`psql -d palette -t -c "select version_number from palette.db_version_meta order by cre_date desc limit 1;"`
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
