#!/usr/bin/env bash

# Example usage:
#     ./freeze-requirement.sh <package_name> <arch> <target-spec-file>

set -e

# Check arg count
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <package_name> <arch> <target-spec-file>"
  exit 1
fi

PACKAGE_NAME=$1
CHANNEL_ARCH=$2
TARGET_SPEC_FILE=$3

# Query the latest RPM version number of the specified package
LATEST_VERSION=$(curl https://rpm.palette-software.com/centos/dev/${CHANNEL_ARCH}/ | grep ${PACKAGE_NAME} | sed -e"s/.*${PACKAGE_NAME}-[v]*\([0-9.-]*\)\.${CHANNEL_ARCH}.*/\1/g" | sort -V | tail -1)
# Replace the requirement line in the specified spec file
# For example this script would turn a line like this
#   Requires: palette-insight-agent
# into
#   Requires: palette-insight-agent = 2.0.11
sed -i "s/Requires: ${PACKAGE_NAME}/Requires: ${PACKAGE_NAME} = ${LATEST_VERSION}/g" ${TARGET_SPEC_FILE}
