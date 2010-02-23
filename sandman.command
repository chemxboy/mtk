#! /usr/bin/env bash
if [[ $USER != "root" ]]; then
    echo "This must be run as root"
    exit 1
fi

ROOTPW="1234"
DELAY=120
LOGFILE=~/Desktop/sandman.command.log

osascript -e "delay $DELAY"
TIMESTAMP=$(php -r "echo date ('H:i:s"', time() + $DELAY);")
echo $ROOTPW | sudo -S pmset repeat poweron MTWRFSU $TIMESTAMP
echo -n $(date "+%d.%m.%y @ %H:%I:%S") >> $LOGFILE
echo "      " $(wc -l $LOGFILE) >> $LOGFILE
osascript -e "tell application "Finder" to shut down"
exit 0
