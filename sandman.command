#!/usr/bin/env bash

if [[ $USER != "root" ]]; then
    echo "This must be run as root"
    exit 1
fi

osascript -e "delay $DELAY"
TIMESTAMP=$(php -r "echo date ('H:i:s"', time() + $DELAY);")
pmset repeat poweron MTWRFSU $TIMESTAMP
echo -n $(date "+%d.%m.%y @ %H:%I:%S") >> $LOGFILE
echo "      " $(wc -l $LOGFILE) >> $LOGFILE
osascript -e "tell application "Finder" to shut down"
exit 0
