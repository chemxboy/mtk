#!/usr/bin/env bash
# up2date.sh
# Run software update until there are no more updates available.
# @author Filipp Lepalaan
# @package mtk

if [[ $(id -u) != 0 ]]; then
  echo "$(basename $0) must be run as root" 2>&1
  exit 1
fi

ME=$0
MAILTO="filipp@mcare.macpalvelin.com"
LOGFILE=/Library/Logs/up2date.log
PLIST=/Library/LaunchDaemons/com.unflyingobject.mtk.up2date.plist

echo "up2date launched..." >> "${LOGFILE}"

# disable automatic checking to avoid possible race condition
/usr/sbin/softwareupdate --schedule off
echo "scheduling disabled, checking for updates..." >> "${LOGFILE}"

# updates available...
if /usr/sbin/softwareupdate -l 2>&1 | grep -q 'found the following new'
then
  if [[ ! -e "${PLIST}" ]]; then
    echo "installing launchd item..." >> "${LOGFILE}"
    cat > "${PLIST}" <<EOT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
  	<key>RunAtLoad</key>
    <true/>
  	<key>Label</key>
  	<string>com.unflyingobject.mtk.up2date</string>
  	<key>ProgramArguments</key>
  	<array>
  		<string>${ME}</string>
  	</array>
  </dict>
</plist>
EOT
  /bin/launchctl load -w "${PLIST}"
  echo "up2date loaded..." >> "${LOGFILE}"
  sleep 10
  exit 0
fi
  echo "more updates available, installing..." >> "${LOGFILE}"
  # this is the part that should be looped until there are no more updates
  /usr/sbin/softwareupdate -ia >> "${LOGFILE}" 2>&1
  echo "updates installed, rebooting..." >> "${LOGFILE}"
  /sbin/shutdown -r now
  exit 0
fi

# no more updates available
echo "all updates installed, cleaning up..." >> "${LOGFILE}"
/usr/sbin/softwareupdate --schedule on

if [[ ! -z "${MAILTO}" ]]; then
  cat "${LOGFILE} | /usr/bin/mail -s up2date ${MAILTO}"
fi

echo "up2date finished, script unloaded. Have a nice day." >> "${LOGFILE}"
/usr/bin/say "$(/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial Number/ {print $4}') up to date!"

rm "${PLIST}"

exit 0
