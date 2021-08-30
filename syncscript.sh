#!/bin/sh
# help?
if [ "$1" = "-h" -o "$1" = "help" -o "$1" = "--help" ]; then
    echo "Usage: ./syncscript.sh [force] [MASSPEC] [FILETYPE]"
    echo "synchronise masspec files to local"
    echo "Example: ./syncscript.sh motu did scn"
    echo "FILETYPE can contain multiple filetypes"
    echo ""
    echo "run without arguments to try to mount '/mnt/rawdata/'"
    echo "it will try to rsync all the files over if they haven't been synced yet today."
    echo "if you want to force synchronisation, pass the 'force' argument."
    echo ""
    echo "then set [MASSPEC] to 'motu' or 'pacman'"
    echo ""
    echo "then set [FILETYPE] to
    - 'did' (newer dual inlet),
    - 'caf' (older dual inlet), and/or
    - 'scn' (scan files)
    as the remaining arguments to specify which files to sync"
    exit 0
fi # help?

echo "$(date +%F\ %T) start syncing"

# TODO: parse other paramters first, then have simpler, non-repeating conditionals below

# forced?
if [  "$1" = "-f" -o "$1" = "force" -o "$1" = "--force" ]; then
   echo "forced syncing initiated"
   f="force"
fi # forced?

# is cisco/eduroam connected?
if [ -n "$(ip link | grep '^[^123]: cscotun0')" -o "$(nmcli -t -f active,ssid dev wifi | egrep '^yes')" = "yes:Utrecht University" ]; then
    # is /mnt/rawdata not mounted?
    if [ -n "$(grep '/mnt/rawdata ' /proc/mounts)" ]; then
	echo "cisco/eduroam is connected and samba drive is already mounted"
    else
	echo "mounting samba drive as cifs" &&
	    sudo mount -t cifs //geodc01.geo.uu.nl/gml/rawdata /mnt/rawdata -o credentials=/etc/samba/credentials/share,uid=japhir,gid=wheel ||
		echo "failed to mount samba drive" && exit 1
    fi # /mnt/rawdata mounted

    echo "* syncing pacman"
    echo "** cafs"

    # pacman_caf sync today?
    if [ "$(grep "sent .* bytes" logs/pacman_caf.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" -a "$f" != "force" ]; then
	echo "** pacman_caf has already been synced today"
    else
	rsync -r -t --progress --numeric-ids --log-file=logs/pacman_caf.log\
	      /mnt/rawdata/Kiel\ 253/clumped/Results/ \
	      /home/japhir/Documents/archive/pacman/cafs
	echo "** logbook"
	cp /mnt/rawdata/Kiel\ 253/clumped/Logbook/logbook253_new.xls /home/japhir/Documents/archive/pacman/log_caf.xls
    fi # pacman_caf sync today?
    echo "** dids"

    # pacman_did sync today?
    if [ "$(grep "sent .* bytes" logs/pacman_did.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" -a "$f" != "force" ]; then
	echo "** pacman_did has already been synced today"
    else
	rsync -r -t --progress --numeric-ids --log-file=logs/pacman_did.log \
	      /mnt/rawdata/Kiel\ 253/Kiel\ IV\ data/ \
	      /home/japhir/Documents/archive/pacman/dids
	echo "** logbook"
	cp /mnt/rawdata/Kiel\ 253/Kiel\ IV\ data/logbook_MAT253.xls /home/japhir/Documents/archive/pacman/log_did.xlsx
    fi # pacman_did sync today?

    echo "** scn"
    echo "*** 2018"

    # pacman_scn sync today?
    if [ "$(grep "sent .* bytes" logs/pacman_scn_2018.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" -a "$f" != "force" ]; then
	echo "** pacman_scn_2018 has already been synced today"
    else
	rsync -r -t --progress --numeric-ids --log-file=logs/pacman_scn_2018.log \
	      /mnt/rawdata/Kiel\ 253/clumped/Scans/ \
	      /home/japhir/Documents/archive/pacman/scn/scn_2018
    fi # pacman_scn sync today?

    echo "*** 2019 and newer"
    # pacman_scn 2019 sync today?
    if [ "$(grep "sent .* bytes" logs/pacman_scn_2019.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" -a "$f" != "force" ]; then
	echo "** pacman_scn_2019 has already been synced today"
    else
	rsync -r -t --progress --numeric-ids --log-file=logs/pacman_scn_2019.log \
	      /mnt/rawdata/Kiel\ 253/Background\ Scans/ \
	      /home/japhir/Documents/archive/pacman/scn/scn_2019
    fi # pacman_scn 2019 sync today?

    echo "* synching motu"
    echo "** dids"

    # motu_did sync today?
    if [ "$(grep "sent .* bytes" logs/motu_did.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" -a "$f" != "force" ]; then
	echo "** motu_did has already been synced today"
    else
	rsync -r -t --progress --numeric-ids --log-file=logs/motu_did.log \
	      /mnt/rawdata/253pluskiel/Raw\ Data/Kiel\ Raw\ Data/ \
	      /home/japhir/Documents/archive/motu/dids
	echo "** logbook"
	cp /mnt/rawdata/253pluskiel/logbook_253plus.xlsx /home/japhir/Documents/archive/motu/log.xlsx
    fi # motu_did sync today?

    echo "** scn"
    # motu_scn sync today?
    if [ "$(grep "sent .* bytes" logs/motu_scn.log | tail -1 | awk '{ print $1 }')" = "$(date +'%Y/%m/%d')" -a "$f" != "force" ]; then
	echo "** motu_scn has already been synced today"
    else
	rsync -r -t --progress --numeric-ids --log-file=logs/motu_scn.log \
	      /mnt/rawdata/253pluskiel/BG\ Folder/ \
	      /home/japhir/Documents/archive/motu/scn
	rsync -r -t --progress --numeric-ids --log-file=logs/motu_scn.log \
	      /mnt/rawdata/253pluskiel/BG\ 2019/ \
	      /home/japhir/Documents/archive/motu/scn
	rsync -r -t --progress --numeric-ids --log-file=logs/motu_scn.log \
	      /mnt/rawdata/253pluskiel/BG\ 2020/ \
	      /home/japhir/Documents/archive/motu/scn
	rsync -r -t --progress --numeric-ids --log-file=logs/motu_scn.log \
	      /mnt/rawdata/253pluskiel/Background\ scans\ 2020/ \
	      /home/japhir/Documents/archive/motu/scn
	rsync -r -t --progress --numeric-ids --log-file=logs/motu_scn.log \
	      /mnt/rawdata/253pluskiel/BG\ 2021/ \
	      /home/japhir/Documents/archive/motu/scn
    fi # motu_scn sync today?
    echo "finished syncing at '$(date +%F\ %T)'"
else # cisco/eduroam connected
    grep -qs '/mnt/rawdata' /proc/mounts &&
	echo "/mnt/rawdata is mounted but there is no connection to cisco or eduroam!" && exit 1
    echo "there is no connection to cisco or eduroam and /mnt/rawdata is not mounted"
fi # cisco/eduroam connected

notify-send "finished running $0"
