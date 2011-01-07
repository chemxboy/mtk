#! /usr/bin/env bash
# pull software update server content
# @author Filipp Lepalaan <filipp@mcare.fi>
# @package mtk

if [[ $# -lt 4 ]]
then
  echo "usage: $(basename $0) server repo port destination" 2>&1
  exit 1
fi

MAC_SERVER=$1
REMOTE_REPO=$2
REMOTE_PORT=$3
LOCAL_DOCROOT=$4
HOSTNAME=$(hostname)

if [[ ! -d "${LOCAL_DOCROOT}" ]];
then
	echo "Invalid local document root: ${LOCAL_DOCROOT}" 2>&1
	exit 1
fi

# download latest update packages, removing deprecated
rsync -av --delete rsync://${MAC_SERVER}:${REMOTE_PORT}/${REMOTE_REPO} ${LOCAL_DOCROOT}

if [[ ! $? ]]
then
  echo "Failed to fetch software update content" 2>&1
  exit 1
fi

# update hostnames in catalog files
find ${LOCAL_DOCROOT} -name *.sucatalog -type f -exec sed -i '' "s/${MAC_SERVER}:8088/${HOSTNAME}/g" {} \;

# rebuild symlinks
cd ${LOCAL_DOCROOT}
rm ./index*
ln -s ./content/catalogs/others/index-leopard-snowleopard.merged-1.sucatalog ./index-leopard-snowleopard.merged-1.sucatalog
ln -s ./content/catalogs/others/index-leopard.merged-1.sucatalog ./index-leopard.merged-1.sucatalog
ln -s ./content/catalogs/index.sucatalog ./index.sucatalog

# 10.4 seems to need this
ln -s ./content/catalogs/index.sucatalog ./content/catalogs/index-1.sucatalog

# One more hack for 10.4
mkdir ${LOCAL_DOCROOT}/scanningpoints
curl -o ${LOCAL_DOCROOT}/scanningpoints/scanningpointX.xml http://17.250.248.95/scanningpoints/scanningpointX.xml

exit 0
