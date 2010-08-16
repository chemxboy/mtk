#!/usr/bin/env bash
# @author Filipp Lepalaan <filipp@mac.com>
# @copyright No (c), Public Domain software

ON_DELAY=20
OFF_DELAY=120 # this should always be > 60
LOGFILE=~/Desktop/poweron.command.log

if [[ $USER != "root" ]]; then
  echo "This must be run as root" 2>&1
  exit 1
fi

sleep ${ON_DELAY}

TIMESTAMP=$(php -r "echo @date('H:i:s', time() + $OFF_DELAY);")
pmset repeat poweron MTWRFSU ${TIMESTAMP}
echo -n $(date "+%d.%m.%y @ %H:%I:%S") >> ${LOGFILE}
echo "      " $(wc -l $LOGFILE) >> ${LOGFILE}
shutdown -h now
