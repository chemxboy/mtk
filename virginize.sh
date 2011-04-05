#!/usr/bin/env bash
# virginize.sh
# Make an OS X appear as if it was started up for the first time
# @author Filipp Lepalaan <filipp@mcare.fi>
# @package mtk

TARGET=$1

if [[ ! -d "${TARGET}/System/Library/CoreServices" ]]; then
  exit "Bad target: ${TARGET}"
fi

rm -rf "${TARGET}/Users/Shared/*"
/usr/bin/find "${TARGET}/Users" -depth 1 -maxdepth 1 \! -name Shared -type d

rm "${TARGET}/var/db/.AppleSetupDone"
touch "${TARGET}/var/db/.RunLanguageChooserToo"
