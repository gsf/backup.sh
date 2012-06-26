#!/bin/sh
# See http://www.mikerubel.org/computers/rsync_snapshots/

MAX_BAKS=10

# src is the source, e.g. example.com:/mnt/mirror/
src="$1"

# don't do anything if no ssh connection
src_host=${src%%:*}
if ! ssh $src_host :; then exit 
fi

# bakdir is the path to the backup dir, e.g. backups/example/
case $2 in 
  '') bakdir="$PWD/" ;; # if empty assign PWD
  /*/) bakdir="$2" ;; # if starts and ends in a slash assign
  /*) bakdir="$2/" ;; # if no end slash add one
  */) bakdir="$PWD/$2" ;; # if no start slash add PWD
  *) bakdir="$PWD/$2/" ;; # if no start or end slash add all
esac

echo "Backing up to $bakdir...",

mkdir -p "$bakdir"

baks=`ls "$bakdir"`

i=`echo $baks | wc -w`

for b in $baks; do
  #echo $b
  if [ $i -gt $MAX_BAKS ]; then
    rm -rf "$bakdir$b"
  fi
  if [ $i -eq 1 ]; then
    linkdest="$bakdir$b"
  fi
  i=$((i-1))
done

name=`date --iso-8601=seconds`

if [ -n $linkdest ]; then
  rsync -az --del "$src" "$bakdir$name"
else
  rsync -az --del --link-dest=$linkdest "$src" "$bakdir$name"
fi
