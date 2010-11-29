#!/usr/bin/env bash
# netbless.sh
# Select NetBoot set from server
# @author Filipp Lepalaan <filipp@mcare.fi>
# @package mtk

SERVER=sw.mcare.fi
SERVER_PATH="/data/nb"

if [[ ${USER} != "root" ]]; then
  echo "This must be run as root" 2>&1
  exit 1
fi

SERVER_IP=$(dig +short ${SERVER})

ME=$(/usr/sbin/sysctl -n hw.model)
MACHINE=$(sysctl -n hw.machine)

if [[ $MACHINE == "x86_64" ]]; then
  MACHINE="i386/${MACHINE}"
fi

if [[ -z $ME ]]; then
  echo "Error: could not determine hardware model" 2>&1
  exit 1
fi

IMAGES=$(/usr/bin/curl -s http://${SERVER}/mh/)

if [[ $1 == "help" ]]; then
  echo -e "Usage: $(basename $0) [${IMAGES}]" 2>&1
  exit 0
fi

for IMG in ${IMAGES}
do
  if [[ "${IMG}" == "${ME}.nbi" || "${IMG}" == "$1" ]]
  then
    /usr/sbin/bless --netboot \
    --booter tftp://${SERVER_IP}/${IMG}/${MACHINE}/booter \
    --kernel tftp://${SERVER_IP}/${IMG}/${MACHINE}/mach.macosx \
    --options "rp=nfs:${SERVER_IP}:${SERVER_PATH}:/${IMG}/NetInstall.dmg" \
    --nextonly
    echo "NetBoot set to ${ME}.nbi"
    exit 0
  fi
done

echo "Error: model ${ME} not found on the NetBoot server" 2>&1
exit 1
