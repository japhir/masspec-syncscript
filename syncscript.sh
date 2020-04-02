#!/bin/sh
echo "start syncing at '$(date +%F\ %T)'"

if grep -qs '/mnt/rawdata' /proc/mounts; then
    echo "samba drive is already mounted"
else
    echo "mounting samba drive as cifs"
    sudo mount -t cifs //geodc01.geo.uu.nl/gml/rawdata /mnt/rawdata -o credentials=/etc/samba/credentials/share,uid=japhir,gid=wheel ||
	echo "start cisco anyconnect first"
fi

# echo "* syncing pacman"
# echo "** cafs"
# rsync -r -t --progress --delete  --ignore-existing --numeric-ids \
#       /mnt/rawdata/Kiel\ 253/clumped/Results/ \
#       /home/japhir/Downloads/archive/pacman/cafs
# echo "** dids"
# rsync -r -t --progress --delete --ignore-existing --numeric-ids \
# 	/mnt/rawdata/Kiel\ IV\ data/ \
# 	/home/japhir/Downloads/archive/pacman/dids
# echo "** scn"
# echo "*** 2018"
# rsync -r -t --progress --delete --ignore-existing --numeric-ids \
# 	/mnt/rawdata/Kiel\ 253/clumped/Scans/ \
# 	/home/japhir/Downloads/archive/pacman/scn_2018
# echo "*** 2019"
# rsync -r -t --progress --delete --ignore-existing --numeric-ids \
# 	/mnt/rawdata/Kiel\ 253/Background\ Scans/ \
# 	/home/japhir/Downloads/archive/pacman/scn_2019
echo "* synching motu"
echo "** dids"
rsync -r -t --progress --numeric-ids --log-file=motu_did.log \
	/mnt/rawdata/253pluskiel/Raw\ Data/Kiel\ Raw\ Data/ \
	/home/japhir/Downloads/archive/motu/dids
echo "** scn"
rsync -r -t --progress --numeric-ids --log-file=motu_scn.log \
	/mnt/rawdata/253pluskiel/BG\ 2019/ \
	/home/japhir/Downloads/archive/motu/scn
echo "finished syncing at '$(date +%F\ %T)'"

# echo "start updating raw data caches at '$(date +%F\ %T)'"
# echo "* caching pacman"
# echo "** cafs"
# Rscript R/pacman_cafs.R
# echo "** dids"
# Rscript R/pacman_dids.R
# echo "* caching motu"
# Rscript R/motu_dids.R

# # TODO: add scn files here
# echo "start updating raw scan caches at '$(date +%F\ %T)'"
# echo "* caching pacman"
# echo "** scn 2018"
# Rscript R/pacman_cafs.R
# echo "** scn 2019"
# Rscript R/pacman_dids.R
# echo "* caching motu scn"
# Rscript R/motu_scn.R
# echo "finished updating raw scan caches at '$(date +%F\ %T)'"
