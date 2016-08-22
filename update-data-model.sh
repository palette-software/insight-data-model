#!/usr/bin/env bash

data_model_version=$1
if [[ -n "$data_model_version" ]]; then
    echo "Requested data model version: $data_model_version"
else
    echo "No data model version specified. Trying to install the latest one."
fi

# We need to make sure we don't get our latest package from yum cache.
sudo yum clean all
sudo yum install -y palette-insight-reporting

# Figure out the relative path from the current working directory to the path of this script being run
SCRIPT_PATH="`dirname \"$0\"`"

# Find a place which is available both for centos and gpadmin user. For example /tmp will do.
cp -f $SCRIPT_PATH/gpadmin-install-data-model.sh /tmp/
sudo chown gpadmin:gpadmin /tmp/gpadmin-install-data-model.sh
sudo su -c "/tmp/gpadmin-install-data-model.sh $data_model_version" gpadmin
rm /tmp/gpadmin-install-data-model.sh
