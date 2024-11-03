#!/bin/bash
# SPDX-FileCopyrightText: 2021-2023, Carles Fernandez-Prades <carles.fernandez@cttc.es>
# SPDX-FileCopyrightText: 2024, Max Wipfli <mail@maxwipfli.ch>
# SPDX-License-Identifier: MIT

# Acknowledgement:
# Source of this file can be found in https://github.com/carlesfernandez/docker-petalinux2. Reused with minor modifications.

# Main updates:
# Using petalinux version 2024.1, removing Vivado related parts.

# Petalinux version
PLNX_VER="2024.1"

cd libraries/qemu || exit

# Check for Petalinux installer
PLNX="petalinux-v2024.1-05202009-installer.run"
if [ ! -f "$PLNX" ] ; then
    echo "$PLNX installer not found"
    cd ..
    exit 1
fi

cd ../..

# shellcheck disable=SC2009
if ! ps -fC python3 | grep "http.server" > /dev/null ; then
    python3 -m "http.server" &
    HTTPID=$!
    echo "HTTP Server started as PID $HTTPID"
    trap 'kill $HTTPID' EXIT QUIT SEGV INT HUP TERM ERR
fi

echo "Creating Docker image petalinux:$PLNX_VER..."
time docker build --build-arg PETA_VERSION="${PLNX_VER}" --build-arg PETA_RUN_FILE="${PLNX}" -t petalinux:"${PLNX_VER}" .

[ -n "$HTTPID" ] && kill "$HTTPID" && echo "Killed HTTP Server"
