#! /usr/bin/env bash
# blooper.command
# Launch applications and reboot the machine
# @author Filipp Lepalaan <filipp@mcare.fi>
# @author Vesa Viskari <vesa@mcare.fi>
# @copyright (c) 2010 Filipp Lepalaan

MYDIR="~/Desktop/BlooperApps"

# Check if Login Item is set
defaults read com.apple.loginitems | grep -c "Path: $($0)"

if [[ ! -d "$MYDIR" ]]; then
  mkdir "$MYDIR"
  ln -s /Applications/Utilities/Grapher.app "$MYDIR/Grapher.app"
  ln -s /Applications/Utilities/Activity\ Monitor.app "$MYDIR/Activity Monitor.app"
  ln -s /Applications/Utilities/Console.app "$MYDIR/Console.app"
  ln -s /Applications/iTunes.app "$MYDIR/iTunes.app"
fi

find "$MYDIR/" -exec open {} \;
trap "killall yes; rm ${MYDIR}; echo 'Cleaning up...'; exit 255" SIGINT
sleep 10

echo $(date) >> ~/Desktop/blooper.log

#reboot
osascript -e 'tell application "Finder" to restart'
