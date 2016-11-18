#!/bin/bash

# Stop on first error
set -e

mkdir -p var/log/palette-insight-reporting

# Create the full installer
sed -i "s/#version_number#/$TRAVIS_TAG/g" ./full_install.sql
cat full_install.sql
zip -r -j $FULL_INSTALL_ZIP functions/*.sql tables/*.sql tables/*.SQL views/*.sql full_install.sql full_install.sh

# Create the incremental installer
export LATEST_MIGRATION_VERSION=`./maxversion.sh`
echo "$LATEST_MIGRATION_VERSION"
zip -r -j $INCREMENTAL_INSTALL_ZIP migrations/$LATEST_MIGRATION_VERSION/*.sql
