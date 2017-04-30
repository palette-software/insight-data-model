#!/bin/sh

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e


# Check arg count
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <SCHEMA_NAME>"
  exit 1
fi

COMMAND_FILE_NAME="${TEMP}/insight-reporting-full-install-`date +%s`.sql"
echo "[+] Using temporary commands file: ${COMMAND_FILE_NAME}"

cmd="s/#schema_name#/$1/g"
sed $cmd full_install.sql > ${COMMAND_FILE_NAME}

echo "[+] Running psql"
psql -d palette -f ${COMMAND_FILE_NAME}

echo "[-] Removing temporary command file"
rm -v ${COMMAND_FILE_NAME}
