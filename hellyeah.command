#!/usr/bin/env bash
# hellyeah.command
# Do some stress testings
# @author Filipp Lepalaan <filipp@mcare.fi>

MYDIR=/private/tmp/_hellyeah
CORES=$(sysctl hw.logicalcpu_max | cut -d : -f 2 | sed 's/ //')

for (( i = 0; i < ${CORES}; i++ )); do
  yes > /dev/null 2>&1 &
done

if [[ ! -d "${MYDIR}" ]]; then
  mkdir "${MYDIR}"
fi

trap "killall yes; rm ${MYDIR}; echo Killed; exit 255" SIGINT SIGTERM

while true; do
  for k in 10 100 1000 10000; do
    BLOCKS=$(($k*1024/512))
    OF="${MYDIR}/$(uuidgen)"
    dd if=/dev/random of=${OF} count=${BLOCKS} > /dev/null 2>&1
    sleep 2
    echo "Wrote ${BLOCKS} blocks"
    rm -rf "${OF}"
  done
done

exit 0
