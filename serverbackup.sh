#!/usr/bin/env bash
# serverbackup.sh

ODPASS=somepass         # Password used to encrypt the OD archive
CALDATA=/Library/CalendarServer/Documents
WEBDATA=/Library/Collaboration
BACKUP_DST=/Volumes/Server\ Backup/backup/server
SERVICES='mail afp calendar dirserv swupdate web dns radius dhcp'

logger -p local0.notice "Starting server backup"

umask 077

if [[ ! -d ${BACKUP_DST}/serveradmin ]]
then
  mkdir -p ${BACKUP_DST}/serveradmin
  mkdir -p ${BACKUP_DST}/wiki
  mkdir -p ${BACKUP_DST}/ical
fi

# Clean OD backups older than 2 weeks
find ${BACKUP_DST} -name odbackup-* -mtime +14 -delete

# Backup OD
echo -n "Creating Open Directory Archive..."

CMD_FILE=/tmp/sacommands.txt
LOCATION=${BACKUP_DST}/odbackup-$(date "+%Y%m%d")
echo "dirserv:backupArchiveParams:archivePassword = ${ODPASS}" > $CMD_FILE
echo "dirserv:backupArchiveParams:archivePath = ${LOCATION}" >> $CMD_FILE
echo "dirserv:command = backupArchive" >> $CMD_FILE
serveradmin command < $CMD_FILE

srm $CMD_FILE
echo "   OK"

echo -n "Backing up active Server Admin settings"

rm ${BACKUP_DST}/serveradmin/*.sabackup

for s in $SERVICES
do
  serveradmin settings $s > ${BACKUP_DST}/serveradmin/${s}.sabackup
done

echo "   OK"

echo -n "Backing up config files"
/usr/bin/rsync -aqu --delete /etc/ ${BACKUP_DST}/etc/
echo "   OK"

echo -n "Backing up wiki pages"
/usr/bin/rsync -aquE --delete ${WEBDATA} ${BACKUP_DST}/wiki/
echo "   OK"

echo -n "Backing up iCal data"
/usr/bin/rsync -aquE --delete ${CALDATA} ${BACKUP_DST}/ical/
echo "   OK"

logger -p local0.notice "Server backup finished"

exit 0