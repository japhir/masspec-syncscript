#!/bin/sh
echo "start syncing at '$(date +%F\ %T)'"

if grep -qs '/mnt/rawdata' /proc/mounts; then
    echo "samba drive is already mounted"
else
    echo "mounting samba drive as cifs"
    sudo mount -t cifs //geodc01.geo.uu.nl/gml/rawdata /mnt/rawdata -o credentials=/etc/samba/credentials/share,uid=japhir,gid=wheel ||
	echo "start cisco anyconnect first"
fi

echo "* syncing pacman"
echo "** cafs"
rsync -r -t --progress --delete  --ignore-existing --numeric-ids -s \
      /mnt/rawdata/Kiel\ 253/clumped/Results/ \
      /home/japhir/Downloads/archive/pacman/cafs
echo "** dids"
rsync -r -t --progress --delete --ignore-existing --numeric-ids -s \
	/mnt/rawdata/Kiel\ IV\ data/ \
	/home/japhir/Downloads/archive/pacman/dids
echo "** scn"
echo "*** 2018"
rsync -r -t --progress --delete --ignore-existing --numeric-ids -s \
	/mnt/rawdata/Kiel\ 253/clumped/Scans/ \
	/home/japhir/Downloads/archive/pacman/scn_2018
echo "*** 2019"
rsync -r -t --progress --delete --ignore-existing --numeric-ids -s \
	/mnt/rawdata/Kiel\ 253/Background\ Scans/ \
	/home/japhir/Downloads/archive/pacman/scn_2019
echo "* synching motu"
echo "** dids"
rsync -r -t --progress --delete --ignore-existing --numeric-ids -s \
	/mnt/rawdata/253pluskiel/Raw\ Data/Kiel\ Raw\ Data/ \
	/home/japhir/Downloads/archive/motu/dids
echo "** scn"
rsync -r -t --progress --delete --ignore-existing --numeric-ids -s \
	/mnt/rawdata/253pluskiel/BG\ 2019/ \
	/home/japhir/Downloads/archive/motu/scn
echo "finished syncing at '$(date +%F\ %T)'"
