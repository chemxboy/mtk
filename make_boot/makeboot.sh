#!/usr/bin/env bash
# makeboot.sh
# Create NetBoot Image from any OS X volume
# usage makeboot..sh source destination

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
  echo "Sorry but your rsync is too old" 2>&1
  exit 1
fi

SOURCE=$1
VOL_NAME=NetBoot
TMP_MOUNT_POINT_PATH=/tmp/MakeBoot
mkdir $TMP_MOUNT_POINT_PATH
DMG_FILE=./boot.sparseimage

hdiutil create "${DMG_FILE}" -volname "${VOL_NAME}"\
	-size 5G -type SPARSE -fs HFS+ -stretch 10G\
	-uid 0 -gid 80 -mode 775 -layout NONE 2>&1

chmod 777 "${DMG_FILE}"

hdiutil attach "${DMG_FILE}" -mountpoint "${TMP_MOUNT_POINT_PATH}"

mdutil -i off "${TMP_MOUNT_POINT_PATH}"
mdutil -E "${TMP_MOUNT_POINT_PATH}"
defaults write "${TMP_MOUNT_POINT_PATH}"/.Spotlight-V100/_IndexPolicy Policy -int 3

mkdir "${TMP_MOUNT_POINT_PATH}/Library/Caches"

echo "Cloning system..."
/Volumes/KINGSTON/rsync\
  --progress\
  --protect-args --fileflags --force-change -aNHAXxr\
  --files-from=include.txt --exclude-from=exclude.txt
  "${SOURCE}" /tmp/MakeBoot

echo "Doing boot things..."
ditto /mach_kernel "${TMP_MOUNT_POINT_PATH}/mach_kernel"
ln -s "${TMP_MOUNT_POINT_PATH}/mach_kernel" "${TMP_MOUNT_POINT_PATH}/mach"

#kextcache -a i386 -s -l -n -z -m /tmp/macnbi-i386/mach.macosx.mkext /System/Library/Extensions

rm -r "${TMP_MOUNT_POINT_PATH}"
diskutil eject "${TMP_MOUNT_POINT_PATH}"
