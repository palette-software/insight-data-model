#!/bin/bash

set -e

ROOTDIR=`dirname $0`
MIGRATIONS_DIR=${ROOTDIR}

cd ${MIGRATIONS_DIR}

MIGRATION_VERSIONS=`ls -d v* | sort -V`

echo "All versions: [ ${MIGRATION_VERSIONS} ]"

#EXISTING_VERSION_STR=" v1.1.13 "
EXISTING_VERSION_STR=`psql -d palette -t -c "select version_number from palette.db_version_meta order by cre_date desc limit 1;"`

# Trim whitespace
EXISTING_VERSION=${EXISTING_VERSION_STR//[[:blank:]]/}
EXISTING_VERSION_IDX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${EXISTING_VERSION}" 'BEGIN{print index(a,b)}'`


echo "Found existing version: >>$EXISTING_VERSION<<"

for VERSION in $MIGRATION_VERSIONS
do
  LOCAL_INDEX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${VERSION}" 'BEGIN{print index(a,b)}'`
  if [[  $LOCAL_INDEX -gt $EXISTING_VERSION_IDX   ]]; then
    echo Need to run: $VERSION

    cd ${VERSION}

    psql -d palette -f "!install-up.sql"

    cd ..
  fi
done
