#!/bin/sh
# See http://www.mikerubel.org/computers/rsync_snapshots/

MAX_BAKS=10

usage="usage: backup.sh <source> [dest]"

# src is the source, e.g. example.com:/mnt/mirror/
case $1 in
  '') echo $usage; exit 0 ;;
  */) src="$1" ;; # assign if ends in a slash
  *) src="$1/" ;; # add slash if it doesn't
esac

# don't do anything if no ssh connection
src_host=${src%%:*}
if ! ssh $src_host :; then exit 
fi

# dest is the path to the destination directory, e.g. backups/example/
case $2 in 
  '') dest="$PWD/" ;; # if empty assign PWD
  /*/) dest="$2" ;; # if starts and ends in a slash assign
  /*) dest="$2/" ;; # if no end slash add one
  */) dest="$PWD/$2" ;; # if no start slash add PWD
  *) dest="$PWD/$2/" ;; # if no start or end slash add all
esac

name=`date --iso-8601=seconds`

echo "Backing up to $dest$name..."

mkdir -p "$dest"

baks=`ls "$dest"`
i=`echo $baks | wc -w`
for b in $baks; do
  if [ $i -gt $MAX_BAKS ]; then
    rm -rf "$dest$b"
  fi
  if [ $i -eq 1 ]; then
    linkdest="$dest$b"
  fi
  i=$((i-1))
done

if [ -n $linkdest ]; then
  rsync -az --del "$src" "$dest$name"
else
  rsync -az --del --link-dest=$linkdest "$src" "$dest$name"
fi
