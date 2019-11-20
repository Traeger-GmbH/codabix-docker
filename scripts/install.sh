#!/bin/sh

# $1: CODABIX_SETUP_FILE

echo "Running install.sh"

codabix_setup_file=$1

echo "Setup file: $codabix_setup_file"

chmod +x $codabix_setup_file
.$codabix_setup_file --noexec --target /tmp/extracted
ls /tmp/extracted/ | head -n 1
mkdir -p /opt/traeger/codabix
cp -r ./tmp/extracted/$(ls /tmp/extracted/ | head -n 1) /opt/traeger/codabix
ln -sf /opt/traeger/codabix/$(ls /tmp/extracted/ | head -n 1)/CoDaBix-Shell /bin/codabix
