#!/usr/bin/env bash
# makeboot.sh
# Create NetBoot Image from any OS X volume
# Much of this is borrowed from DeployStudio/sys_builder.sh
# usage makeboot..sh source destination
# http://pastebin.com/aJi3AxTe
# https://www.wiki.ed.ac.uk/display/DSwiki/Automating+the+creation+of+NetBoot+images
# http://clc.its.psu.edu/Labs/Mac/Resources/blastimageconfig/default.aspx

if [ $USER != "root" ]; then
  echo "This must be run as root"
  exit 1
fi

USAGE="$(basename $0) source destination"

if [[ -z $1 ]]; then
  echo $USAGE 2>&1
  exit 1
fi

RSYNC_VERSION=$(rsync --version | head -n 1 | cut -d ' ' -f 8)

if [[ $RSYNC_VERSION -lt 30 ]]; then
  echo "Sorry, but your rsync is too old" 2>&1
  exit 1
fi

SOURCE=$1
VOL_NAME=NetBoot
TMP_MOUNT_POINT_PATH=/tmp/NetBoot
mkdir $TMP_MOUNT_POINT_PATH
DMG_FILE=./boot.sparseimage

echo "Creating disk image..."
hdiutil create "${DMG_FILE}" -volname "${VOL_NAME}"\
	-size 5G -type SPARSE -fs HFS+ -stretch 10G\
	-uid 0 -gid 80 -mode 775 -layout NONE -ov > /dev/null 2>&1

chmod 777 "${DMG_FILE}"

echo "Mounting disk image..."
hdiutil attach "${DMG_FILE}" -mountpoint "${TMP_MOUNT_POINT_PATH}" > /dev/null 2>&1

echo "Preparing disk image..."
mdutil -i off "${TMP_MOUNT_POINT_PATH}" > /dev/null 2>&1
mdutil -E "${TMP_MOUNT_POINT_PATH}" > /dev/null 2>&1
mkdir -p "${TMP_MOUNT_POINT_PATH}"/Library/Caches
defaults write "${TMP_MOUNT_POINT_PATH}"/.Spotlight-V100/_IndexPolicy Policy -int 3

echo "Cloning system (this will take a while)..."
/usr/local/bin/rsync\
  --protect-args --fileflags --force-change -ahNHAXxr\
  --files-from=./include.txt --exclude-from=./exclude.txt\
  "${SOURCE}" $TMP_MOUNT_POINT_PATH

echo "Doing boot things..."

kextcache -a i386 -N -L -S -m "${TMP_MOUNT_POINT_PATH}"/System/Library/Extensions.mkext\
  "${SOURCE}"/System/Library/Extensions

bless --folder "${TMP_MOUNT_POINT_PATH}"/System/Library/CoreServices\
  --label "${VOL_NAME}" --bootinfo --bootefi --verbose

echo "Removing non-English localisations..."
find "${TMP_MOUNT_POINT_PATH}"/Applications\
  "${TMP_MOUNT_POINT_PATH}"/System/Library/Frameworks\
  -type d -name '*.lproj' ! -iname 'en*' -delete

diskutil eject "${TMP_MOUNT_POINT_PATH}"
rm -r "${TMP_MOUNT_POINT_PATH}"
open .
