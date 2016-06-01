#!/bin/bash

set -e

# Get the desired target version from the command line
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <TARGET-VERSION>"
  exit 1
fi

TARGET_VERSION=$1


DB_NAME=palette
SCHEMA_NAME=palette
VERSION_TABLE_NAME=db_version_meta

ROOTDIR=$(readlink --canonicalize `dirname $0`)

echo "Inside ${ROOTDIR}"

FULL_INSTALL_DIR=${ROOTDIR}/full-installs
MIGRATIONS_DIR=${ROOTDIR}/migrations

# Check if theres is a version table in the database
VERSION_TABLE_EXISTS=`psql -d ${DB_NAME} -t -c "select exists( select 1 from information_schema.tables where table_schema='${SCHEMA_NAME}' and table_name='${VERSION_TABLE_NAME}');"`
#VERSION_TABLE_EXISTS='f'

# Function to apply templates
template_dir () {
  IN_DIR=$1
  OUT_DIR=$(mktemp -d /tmp/insight-datamodel-install-sql.XXXXXX)

  #echo "Copying the contents of ${IN_DIR} to ${OUT_DIR}"
  cp -R $IN_DIR/*.sql $OUT_DIR


  # Do a replacement of #schema_name#
  #echo "Replacing #schema_name# with ${SCHEMA_NAME}"
  sed -i "s/#schema_name#/${SCHEMA_NAME}/g" ${OUT_DIR}/*.sql

  # 'return' the output directory
  echo $OUT_DIR
}

# If no, do a full install
if [ $VERSION_TABLE_EXISTS = 'f'  ]; then
  echo "VERSION TABLE DOES NOT EXIST, doing a full install"

  INSTALLER_DIR=${FULL_INSTALL_DIR}/$TARGET_VERSION

  # Check if the installer exists
  if [[ ! -d $INSTALLER_DIR ]]; then
    echo "Cannot find installer for version: ${TARGET_VERSION}"
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

  # We should be A-OK here
  exit 0
fi

# If yes, do an incremental install
if [ $VERSION_TABLE_EXISTS = 't'  ]; then
  # Go into the migrations dir, so listing files there wont
  # contain any path prefixes
  pushd $MIGRATIONS_DIR
  # Get all the versions
  MIGRATION_VERSIONS=`ls -d v* | sort -V`
  EXISTING_VERSION_STR=`psql -d ${DB_NAME} -t -c "select version_number from ${SCHEMA_NAME}.${VERSION_TABLE_NAME} order by cre_date desc limit 1;"`

  # Get the existing version's substring index in the versions list
  EXISTING_VERSION=${EXISTING_VERSION_STR//[[:blank:]]/}
  EXISTING_VERSION_IDX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${EXISTING_VERSION}" 'BEGIN{print index(a,b)}'`

  TARGET_VERSION_IDX=`awk -v a="${MIGRATION_VERSIONS}" -v b="${TARGET_VERSION}" 'BEGIN{print index(a,b)}'`



    # Check if the existing version is actually in the list of migrations
  if [[ $TARGET_VERSION_IDX = 0 ]]; then
    echo "Cannot find target version: ${TARGET_VERSION} in versions: ${MIGRATION_VERSIONS}"
    exit 4
  fi

    # Check if the existing version is actually in the list of migrations
  if [[ $EXISTING_VERSION_IDX = 0 ]]; then
    echo "Cannot find existing version: ${EXISTING_VERSION} in versions: ${MIGRATION_VERSIONS}"
    exit 4
  fi


  # Iterate through all versiosn
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

	# Run the full installer
	psql -d palette -f "!install-up.sql"

	# Get back to the outer directory
	popd

	# Remove the templated directory
	rm -rf ${TEMPLATED_DIR}

      fi
    fi
  done

  # Get out of the migrations dir
  popd

  # We should be ok here too
  exit 0
fi



# Signal if we dont understand the existence flag
echo "UNKNOWN VERSION TABLE EXISTENCE FLAG: ${VERSION_TABLE_EXISTS}"
exit 2
