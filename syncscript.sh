#!/bin/sh
echo "$(date +%F\ %T) start syncing"

# is cisco connected? this code can be left uncommented!
if ip link | grep -qs "^[^123]: cscotun0"; then
    # is /mnt/rawdata not mounted?
    if grep -qs '/mnt/rawdata' /proc/mounts; then
	echo "cisco is connected and samba drive is already mounted"
    else
	echo "mounting samba drive as cifs" &&
	    sudo mount -t cifs //geodc01.geo.uu.nl/gml/rawdata /mnt/rawdata -o credentials=/etc/samba/credentials/share,uid=japhir,gid=wheel ||
		echo "failed to mount samba drive" && exit 1
    fi
else
    grep -qs '/mnt/rawdata' /proc/mounts &&
	echo "/mnt/rawdata is mounted but there is no connection to cisco!" && exit 1
    echo "there is no connection to cisco and /mnt/rawdata is not mounted"
fi


# if we want to do any syning, these should both be true
grep -qs '/mnt/rawdata' /proc/mounts & ip link | grep -qs "^[^123]: cscotun0" ||
    echo "to sync files from remote, first start cisco and mount rawdata" && exit 1
echo "* syncing pacman"
echo "** cafs"
if [ "$(grep "sent .* bytes" logs/pacman_caf.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" ]; then
    echo "** pacman_caf has already been synced today"
else
    rsync -r -t --progress --numeric-ids --log-file=logs/pacman_caf.log\
	  /mnt/rawdata/Kiel\ 253/clumped/Results/ \
	  /home/japhir/Documents/archive/pacman/cafs
fi
echo "** dids"
if [ "$(grep "sent .* bytes" logs/pacman_did.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" ]; then
    echo "** pacman_did has already been synced today"
else
    rsync -r -t --progress --numeric-ids --log-file=logs/pacman_did.log \
	  /mnt/rawdata/Kiel\ 253/Kiel\ IV\ data/ \
	  /home/japhir/Documents/archive/pacman/dids
fi
echo "** scn"
echo "*** 2018"
if [ "$(grep "sent .* bytes" logs/pacman_scn_2018.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" ]; then
    echo "** pacman_scn_2018 has already been synced today"
else
    rsync -r -t --progress --numeric-ids --log-file=logs/pacman_scn_2018.log \
	  /mnt/rawdata/Kiel\ 253/clumped/Scans/ \
	  /home/japhir/Documents/archive/pacman/scn_2018
fi
echo "*** 2019"
if [ "$(grep "sent .* bytes" logs/pacman_scn_2019.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" ]; then
    echo "** pacman_scn_2019 has already been synced today"
else
    rsync -r -t --progress --numeric-ids --log-file=logs/pacman_scn_2019.log \
	  /mnt/rawdata/Kiel\ 253/Background\ Scans/ \
	  /home/japhir/Documents/archive/pacman/scn_2019
fi
echo "* synching motu"
echo "** dids"
if [ "$(grep "sent .* bytes" logs/motu_did.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" ]; then
    echo "** motu_did has already been synced today"
else
    rsync -r -t --progress --numeric-ids --log-file=logs/motu_did.log \
	  /mnt/rawdata/253pluskiel/Raw\ Data/Kiel\ Raw\ Data/ \
	  /home/japhir/Documents/archive/motu/dids
fi
echo "** scn"
if [ "$(grep "sent .* bytes" logs/motu_scn.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" ]; then
    echo "** motu_scn has already been synced today"
else
    rsync -r -t --progress --numeric-ids --log-file=logs/motu_scn.log \
	  /mnt/rawdata/253pluskiel/BG\ 2019/ \
	  /home/japhir/Documents/archive/motu/scn
    rsync -r -t --progress --numeric-ids --log-file=logs/motu_scn.log \
	  /mnt/rawdata/253pluskiel/BG\ Folder/ \
	  /home/japhir/Documents/archive/motu/scn
fi
echo "finished syncing at '$(date +%F\ %T)'"

# echo "start updating raw data caches at '$(date +%F\ %T)'"
# # todo: write a log file and don't redo this when nothing changed
# echo "* caching pacman"
# echo "** cafs"
# Rscript R/pacman_cafs.R
# echo "** dids"
# Rscript R/pacman_dids.R
# echo "** scn 2018"
# Rscript R/pacman_scn_2018.R
# echo "** scn 2019"
# Rscript R/pacman_scn_2019.R

# echo "* caching motu dids"
# Rscript R/motu_dids.R
# echo "* caching motu scn"
# Rscript R/motu_scn.R

echo "$(date +%F\ %T) finished updating raw scan caches"
notify-send "finished running shell script"
