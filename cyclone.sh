#!/usr/bin/env bash
# clone all partitions of a drive and try not to waste space
# @author Filipp Lepalaan <filipp@mcare.fi>
# @package mtk

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

# Make sure we're not operating on the boot drive
if [[ mount | head -n 1 | egrep -q "${SOURCE}|${TARGET}" ]]; then
  echo "Error: cannot operate on the boot drive" 2>&1
  exit 1
fi

TMPFILE="/tmp/$(uuidgen)"

trap "killall dd; rm ${TMPFILE}; echo 'Cleaning up...'; exit 255" SIGINT SIGTERM

# Get size of source
/usr/sbin/diskutil info -plist $SOURCE > "${TMPFILE}".plist
SOURCE_SIZE=`defaults read $TMPFILE TotalSize`

# Get size of destination
/usr/sbin/diskutil info -plist $TARGET > $TMPFILE
TARGET_SIZE=`defaults read $TMPFILE TotalSize`
rm $TMPFILE

if [[ $TARGET_SIZE == $SOURCE_SIZE ]]; then
  echo "Sizes are identical, cloning with dd..."
  /usr/sbin/diskutil quiet unmountDisk $SOURCE
  /usr/sbin/diskutil quiet unmountDisk $TARGET
  /bin/dd bs=16m if="/dev/r${SOURCE}" of="/dev/r${TARGET}" conv=noerror,sync &
  DD_PID=$!
  # while dd is running...
  while [[ ps -ax | egrep -q -m 1 " ${DD_PID} "  ]]; do
    sleep 1
    /bin/kill -SIGINFO $DD_PID
  done
  /usr/sbin/diskutil quiet mountDisk $SOURCE
  /usr/sbin/diskutil quiet mountDisk $TARGET
  exit 0
fi

if [[ $TARGET_SIZE < $SOURCE_SIZE ]]; then
  echo "Warning: target drive is smaller than source!" 2>&1
fi

