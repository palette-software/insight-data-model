#!/bin/bash

set -e

# Get the desired target version from the command line
if [ "$#" -gt 1 ]; then
  echo "Usage: $0 (<TARGET-VERSION>)"
  exit 1
fi

TARGET_VERSION=$1


DB_NAME=palette
SCHEMA_NAME=palette
VERSION_TABLE_NAME=db_version_meta

ROOTDIR=/opt/palette-insight-reporting

echo "Inside ${ROOTDIR}"

FULL_INSTALL_DIR=${ROOTDIR}/full-installs
MIGRATIONS_DIR=${ROOTDIR}/migrations

# Check if theres is a version table in the database
VERSION_TABLE_EXISTS=`psql -d ${DB_NAME} -t -c "select exists( select 1 from information_schema.tables where table_schema='${SCHEMA_NAME}' and table_name='${VERSION_TABLE_NAME}');"`
#VERSION_TABLE_EXISTS='f'

# Function to apply templates.
# Call like:
#
#   template_dir <INPUT_DIR>
#
# Returns the name of a temp directory with the templated contents.
# The caller is responsible for cleaning up the temporary directory.
template_dir () {
  IN_DIR=$1
  OUT_DIR=$(mktemp -d /tmp/insight-datamodel-install-sql.XXXXXX)

  #echo "Copying the contents of ${IN_DIR} to ${OUT_DIR}"
  cp -R $IN_DIR/*.sql $OUT_DIR

  # Do a replacement of #schema_name# in all *install* files
  sed -i "s/#schema_name#/${SCHEMA_NAME}/g" ${OUT_DIR}/*install*.sql

  # 'return' the output directory
  echo $OUT_DIR
}



# ============= FULL INSTALL ==============

# If no, do a full install
# Note there is no version check here. It is impossible to install
# a version lower than the latest full-install version.
if [ $VERSION_TABLE_EXISTS = 'f'  ]; then
  echo "VERSION TABLE DOES NOT EXIST, doing a full install"

  # Find the latest full install version
  pushd ${FULL_INSTALL_DIR}
  FULL_VERSIONS=`ls -d v* | sort -r -V`
  LATEST_FULL_INSTALL_VERSION=`echo $FULL_VERSIONS | cut -d' ' -f1`
  popd

  INSTALLER_DIR=${FULL_INSTALL_DIR}/$LATEST_FULL_INSTALL_VERSION

  # Check if the installer exists
  if [[ ! -d $INSTALLER_DIR ]]; then
    echo "Cannot find installer for version: ${LATEST_FULL_INSTALL_VERSION}"
    exit 1
  fi

  TEMPLATED_DIR=`template_dir ${INSTALLER_DIR}`

  # Go to the installer dir to have the correct include paths
  echo "Using temporary folder for install: ${TEMPLATED_DIR}"
  pushd ${TEMPLATED_DIR}

  # Run the full installer
  psql -d palette -f full_install.sql

  # Get back to the outer directory
  popd

  # Remove the templated directory
  rm -rf ${TEMPLATED_DIR}

  echo "-------------------- OK --------------------"

fi


# ==================== INCREMENTAL INSTALL ====================


# Go into the migrations dir, so listing files there wont
# contain any path prefixes
pushd $MIGRATIONS_DIR
# Get all the versions
MIGRATION_VERSIONS=`ls -d v* | sort -V`
EXISTING_VERSION_STR=`psql -d ${DB_NAME} -t -c "select version_number from ${SCHEMA_NAME}.${VERSION_TABLE_NAME} order by cre_date desc limit 1;"`

# Get the existing version's substring index in the versions list
EXISTING_VERSION=${EXISTING_VERSION_STR//[[:blank:]]/}
EXISTING_VERSION_IDX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${EXISTING_VERSION}" 'BEGIN{print index(a,b)}'`

# Go for the latest version if not specified
if [ "X" == "X$TARGET_VERSION" ]
then
    # We need to replace the newlines first to spaces as I was unable to use newline in awk split.
    TARGET_VERSION_IDX=`echo "$MIGRATION_VERSIONS" | sed ':a;N;$!ba;s/\n/ /g' | awk -F" " 'END{print length($0)-length($NF)+1}'`
else
    TARGET_VERSION_IDX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${TARGET_VERSION}" 'BEGIN{print index(a,b)}'`
fi

  # Check if the existing version is actually in the list of migrations
if [[ $TARGET_VERSION_IDX = 0 ]]; then
  echo "Cannot find target version: ${TARGET_VERSION}"
  exit 4
fi

  # Check if the existing version is actually in the list of migrations
if [[ $EXISTING_VERSION_IDX = 0 ]]; then
  echo "Cannot find existing version: ${EXISTING_VERSION}"
  exit 4
fi


# Iterate through all versions
for VERSION in $MIGRATION_VERSIONS
do
  LOCAL_INDEX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${VERSION}" 'BEGIN{print index(a,b)}'`

  # Check if this version is greater then the other
  if [[  $LOCAL_INDEX -gt $EXISTING_VERSION_IDX   ]]; then
    # Check if the local version is lower or equal to the target version
    if [[  $LOCAL_INDEX -le $TARGET_VERSION_IDX   ]]; then

      echo Need to run migration: $VERSION

      TEMPLATED_DIR=`template_dir ${VERSION}`

      # Go to the migration dir to have the correct include paths
      echo "Using temporary folder for migration: ${TEMPLATED_DIR}"
      pushd ${TEMPLATED_DIR}

      # Run the migration installer
      psql -d ${SCHEMA_NAME} -f "!install-up.sql"

      # Get back to the outer directory
      popd

      # Remove the templated directory
      rm -rf ${TEMPLATED_DIR}

    fi
  fi
done

# Get out of the migrations dir
popd

echo "-------------------- OK --------------------"
# We should be ok here too
exit 0


# ============= ERROR  ==============

# Signal if we dont understand the existence flag
echo "UNKNOWN VERSION TABLE EXISTENCE FLAG: ${VERSION_TABLE_EXISTS}"
exit 2
