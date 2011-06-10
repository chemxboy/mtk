#!/bin/bash
# asdbless.sh
# Pick correct ASD image for this machine
# @author Filipp Lepalaan <filipp@mcare.fi>
# @package mtk

SERVER_IP=192.168.1.10                                    # The IP of the NetBoot server
SERVER_URL="http://example.com/mtk/asd2nb/server.php"     # URL of the server-side script
NBI_PATH="/data/nb"                                       # Path to the ASD image repository
ASD_ROOT="/asd"                                           # 

MODEL=$(/usr/sbin/sysctl -n hw.model)
MACHINE=$(/usr/sbin/sysctl -n hw.machine)
RESULT=$(/usr/bin/curl -s ${SERVER_URL} -d m=${MODEL})

if [[ -z ${RESULT} ]]; then
  echo "${MODEL} not found on server, exiting" 2>&1
  exit 1;
fi

ASD=$(echo $RESULT | awk 'BEGIN { FS = "/" } ; { print $1 }')
DMG=$(echo $RESULT | awk 'BEGIN { FS = "/" } ; { print $2 }')

if [[ $1 != "efi" ]]; then
  /usr/sbin/bless --netboot \
      --booter tftp://${SERVER_IP}${ASD_ROOT}/${ASD}/${MACHINE}/booter \
      --kernel tftp://${SERVER_IP}${ASD_ROOT}/${ASD}/${MACHINE}/mach.macosx \
      --options "rp=nfs:${SERVER_IP}:${NBI_PATH}:${ASD_ROOT}/${RESULT}" \
      --nextonly
else
  /usr/sbin/bless --netboot \
      --booter tftp://${SERVER_IP}${ASD_ROOT}/${ASD}/efi/boot.efi \
      --nextonly
fi

echo "Boot volume set to ${ASD}"
exit 0
