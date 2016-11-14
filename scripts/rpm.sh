#!/bin/bash

# Build the RPM file
PACKAGEVERSION=${PACKAGEVERSION:-$TRAVIS_BUILD_NUMBER}
export PACKAGEVERSION

if [ -z "$VERSION" ]; then
    echo "VERSION is missing"
    exit 1
fi

if [ -z "$PACKAGEVERSION" ]; then
    echo "PACKAGEVERSION is missing"
    exit 1
fi

echo "Building RPM version $VERSION"
pushd rpm-build

# # Freeze the dependencies of requirements
export SPEC_FILE=palette-insight-reporting.spec
# - ./freeze-requirement.sh palette-greenplum-installer x86_64 ${SPEC_FILE}
# - ./freeze-requirement.sh palette-insight-toolkit x86_64 ${SPEC_FILE}
# - ./freeze-requirement.sh palette-insight-reporting-framework x86_64 ${SPEC_FILE}
# # Show the contents of the modified (frozen versions) spec file
# - cat ${SPEC_FILE}

# Create directories
mkdir -p _root/opt/palette-insight-reporting/full-installs
mkdir -p _root/opt/palette-insight-reporting/migrations
mkdir -p _root/etc/palette-insight-server
mkdir -p _build

# As dirs +1 returns paths with a tilde in them, we need to expand it
export SRC_DIR=$(eval echo `dirs +1`)

cp $SRC_DIR/gpadmin-install-data-model.sh _root/opt/palette-insight-reporting/
cp $SRC_DIR/insight-datamodel-install.sh _root/opt/palette-insight-reporting/
cp -R $SRC_DIR/full-installs/v* _root/opt/palette-insight-reporting/full-installs
cp -R $SRC_DIR/migrations/v* _root/opt/palette-insight-reporting/migrations
cp $SRC_DIR/workflow_reporting.yml _root/etc/palette-insight-server
cp $SRC_DIR/workflow_reporting_delta.yml _root/etc/palette-insight-server

# NOTE: Full installs are not required now. We are going to do them manully, in case we need a new one.
# # Clean the destination for the current version
# - rm -rfv $CURRENT_VERSION_FULL_INSTALL_DIR

# # Overwrite the currently tagged versions directory with the
# - unzip $SRC_DIR/$FULL_INSTALL_ZIP -d $CURRENT_VERSION_FULL_INSTALL_DIR

# Pack the rpm archvie
rpmbuild --quiet -bb --buildroot "$(pwd)/_root" --define "_rpmdir $(pwd)/_build" --define "version $VERSION" --define "buildrelease $PACKAGEVERSION" ${SPEC_FILE} || exit 2

# Pack it as a zip also
zip -qr $SRC_DIR/$PACKED_ZIP _root/opt/palette-insight-reporting || exit 2
popd
