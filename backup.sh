#!/bin/sh
# See http://www.mikerubel.org/computers/rsync_snapshots/

# SRC is the source, e.g. example:/mnt/mirror/
SRC="$1:$2"

# BAK is the path to the backup dir, e.g. backups/example/backup
BAK="backups/$1/backup"

# don't do anything if no ssh connection
if ! ssh $1 :; then exit 
fi

rm -rf $BAK.9
mv $BAK.8 $BAK.9
mv $BAK.7 $BAK.8
mv $BAK.6 $BAK.7
mv $BAK.5 $BAK.6
mv $BAK.4 $BAK.5
mv $BAK.3 $BAK.4
mv $BAK.2 $BAK.3
mv $BAK.1 $BAK.2
mv $BAK.0 $BAK.1
rsync -az --del --link-dest=../backup.1 $SRC $BAK.0
