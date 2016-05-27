#!/bin/bash

set -ev

if [ "$#" -ne 1 ]; then
   echo "Usage: $0 <OUTPUT_BASE_PATH>"
   exit 1
fi

THIS_DIR=`dirname $0`
MIGRATIONS=$THIS_DIR/../migrations
RPM_ROOT=$THIS_DIR/_root
OUTPUT_BASE_PATH=$1

for filename in $MIGRATIONS/v*; do
  VERSION=`basename $filename`
  echo "+ packing $VERSION"

  echo "  - Creating output directory"
  mkdir -p $OUTPUT_BASE_PATH/$VERSION/

  echo "  - Copying files"
  cp -v $filename/*.sql $OUTPUT_BASE_PATH/$VERSION/
done
