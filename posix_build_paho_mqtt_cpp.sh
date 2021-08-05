#!/bin/bash
#
# Build the Paho MQTT CPP Shared library required by the data_publish application.
#

set -ex

cmake -Bposix_build -H. -DCMAKE_INSTALL_PREFIX=./posix_build/_install
sudo ldconfig

cd posix_build
make clean
make

exit 0
