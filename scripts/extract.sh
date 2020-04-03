#!/bin/sh

# $1: CODABIX_SETUP_FILE

echo "Running extract.sh"

codabix_setup_file=$1

echo "Setup file: $codabix_setup_file"

chmod +x $codabix_setup_file
.$codabix_setup_file --noexec --target /tmp/extract
mv /tmp/extract/$(ls /tmp/extract/ | head -n 1) /tmp/codabix
