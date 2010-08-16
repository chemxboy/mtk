#!/usr/bin/env bash
# clone all partitions of a drive
# and try not to waste space
# @author Filipp Lepalaan <filipp@mcare.fi>

if [[ $USER != "root" ]]; then
  echo "Insufficient privileges!" 2>&1
  exit 1
fi

if [[ $# -lt 2 ]]; then
  echo "Usage: $(basename $0) source destination" 2>&1
  exit 1
fi

SOURCE=$1
TARGET=$2

TMPFILE="/tmp/$(uuidgen)"

# Get size of source
diskutil info -plist $SOURCE > "${TMPFILE}".plist
SOURCE_SIZE=`defaults read $TMPFILE TotalSize`

# Get size of destination
diskutil info -plist $TARGET > $TMPFILE
TARGET_SIZE=`defaults read $TMPFILE TotalSize`
rm $TMPFILE

if [[ $TARGET_SIZE < $SOURCE_SIZE ]]; then
  echo "Warning: target drive is smaller than source!" 2>&1
fi

if [[ $TARGET_SIZE == $SOURCE_SIZE ]]; then
  echo "Drives are identical, cloning with dd..."
  diskutil quiet unmountDisk $SOURCE
  diskutil quiet unmountDisk $TARGET
  dd bs=16m if="/dev/r${SOURCE}" of="/dev/r${TARGET}" conv=noerror,sync
  diskutil quiet mountDisk $SOURCE
  diskutil quiet mountDisk $TARGET
  exit 0
fi
