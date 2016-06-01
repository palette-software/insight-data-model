#!/bin/sh
if [ "$#" -ne 1 ]; then
   echo "Illegal number of parameters"
   exit 1
fi
cmd="s/#schema_name#/$1/g"
sed -i $cmd full_install.sql
psql -d palette -f full_install.sql
cmd="s/$1/#schema_name#/g"
sed -i $cmd full_install.sql