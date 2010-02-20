#!/usr/bin/env bash
# build_rsync.sh
# @author Filipp Lepalaan <filipp@mcare.fi>
# Build the most recent version of rsync
# with necessary patches.
# All thanks to Mike Bombich
# http://www.bombich.com/mactips/rsync.html

USAGE="$(basename $0) rsync_version"
BACK=$PWD

if [[ -z $1 ]]; then
  echo $USAGE 2>&1
  exit 1
fi

RSYNC_VERSION=$1
mkdir /tmp/build_rsync > /dev/null 2>&1
cd /tmp/build_rsync

echo "Downloading rsync..."
curl --progress -O http://rsync.samba.org/ftp/rsync/rsync-${RSYNC_VERSION}.tar.gz > /dev/null 2>&1
curl --progress -O http://rsync.samba.org/ftp/rsync/rsync-patches-${RSYNC_VERSION}.tar.gz > /dev/null 2>&1

echo "Extracting rsync..."
tar -zxvf rsync-${RSYNC_VERSION}.tar.gz
tar -zxvf rsync-patches-${RSYNC_VERSION}.tar.gz
cd rsync-${RSYNC_VERSION}

echo "Building rsync..."
patch -p1 <patches/fileflags.diff
patch -p1 <patches/crtimes.diff
./prepare-source
./configure
make
cp ./rsync "${BACK}"

rm -r /tmp/build_rsync
