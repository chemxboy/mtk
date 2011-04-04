#! /usr/bin/env bash
# whatbuild.sh
# @description determine build number of OS on target volume
# @package mtk
# @author Filipp Lepalaan <filipp@mcare.fi>

USAGE="$(basename $0) [volume=/]"
VOLUME=${1:-"/"}
PLIST="${VOLUME}/System/Library/CoreServices/SystemVersion.plist"

if [[ $1 == "-h" ]]; then
  echo $USAGE
  exit 0
fi

if [[ ! -e "${PLIST}" ]]; then
  echo "invalid volume: ${VOLUME}" 2>&1
  exit 1
fi

/usr/libexec/PlistBuddy -c 'Print ProductBuildVersion' "${PLIST}"
exit 0