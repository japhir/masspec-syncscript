#!/bin/sh
echo "start syncing at '$(date +%F\ %T)'"

if grep -qs '/mnt/rawdata' /proc/mounts; then
    echo "samba drive is already mounted"
else if ip link | grep -qs "^[^123]: cscotun0"; then
    echo "mounting samba drive as cifs"
    sudo mount -t cifs //geodc01.geo.uu.nl/gml/rawdata /mnt/rawdata -o credentials=/etc/samba/credentials/share,uid=japhir,gid=wheel ||
	echo "failed to mount samba drive" && exit 1
     else
	echo "start cisco anyconnect first" && exit 1
     fi
fi

echo "* syncing pacman"
echo "** cafs"
rsync -r -t --progress --numeric-ids --log-file=pacman_caf.log\
      /mnt/rawdata/Kiel\ 253/clumped/Results/ \
      /home/japhir/Documents/archive/pacman/cafs
echo "** dids"
rsync -r -t --progress --numeric-ids --log-file=pacman_did.log \
	/mnt/rawdata/Kiel\ 253/Kiel\ IV\ data/ \
	/home/japhir/Documents/archive/pacman/dids
echo "** scn"
echo "*** 2018"
rsync -r -t --progress --numeric-ids --log-file=pacman_scn_2018.log \
	/mnt/rawdata/Kiel\ 253/clumped/Scans/ \
	/home/japhir/Documents/archive/pacman/scn_2018
echo "*** 2019"
rsync -r -t --progress --numeric-ids --log-file=pacman_scn_2019.log \
	/mnt/rawdata/Kiel\ 253/Background\ Scans/ \
	/home/japhir/Documents/archive/pacman/scn_2019
echo "* synching motu"
echo "** dids"
rsync -r -t --progress --numeric-ids --log-file=motu_did.log \
	/mnt/rawdata/253pluskiel/Raw\ Data/Kiel\ Raw\ Data/ \
	/home/japhir/Documents/archive/motu/dids
echo "** scn"
rsync -r -t --progress --numeric-ids --log-file=motu_scn.log \
	/mnt/rawdata/253pluskiel/BG\ 2019/ \
	/home/japhir/Documents/archive/motu/scn
rsync -r -t --progress --numeric-ids --log-file=motu_scn.log \
	/mnt/rawdata/253pluskiel/BG\ Folder/ \
	/home/japhir/Documents/archive/motu/scn
echo "finished syncing at '$(date +%F\ %T)'"

echo "start updating raw data caches at '$(date +%F\ %T)'"
echo "* caching pacman"
echo "** cafs"
Rscript R/pacman_cafs.R
echo "** dids"
Rscript R/pacman_dids.R
echo "** scn 2018"
Rscript R/pacman_scn_2018.R
echo "** scn 2019"
Rscript R/pacman_scn_2019.R

echo "* caching motu dids"
Rscript R/motu_dids.R
echo "* caching motu scn"
Rscript R/motu_scn.R

echo "finished updating raw scan caches at '$(date +%F\ %T)'"
notify-send "finished running shell script"
