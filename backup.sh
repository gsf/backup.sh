#!/bin/sh
# See http://www.mikerubel.org/computers/rsync_snapshots/

verbose=false
dry=false
max=10

# get options
while getopts ":nvm:" opt; do
  case $opt in
    n) dry=true ;;
    v) verbose=true ;;
    m) max=$OPTARG ;;
  esac
done

# shift positional parameter past options
shift $((OPTIND-1))

# src is the source, e.g. example.com:/mnt/mirror/
case $1 in
  '') 
    cat <<EOF
usage: backup.sh [options] source [dest]
  -n      dry run (don't actually rsync anything)
  -v      verbose
  -m max  set max number of backups to something other than 10
EOF
    exit ;;
  */) src="$1" ;; # assign if ends in a slash
  *) src="$1/" ;; # add slash if it doesn't
esac

if $dry && $verbose; then
  echo "this is a dry run"
fi

# don't do anything if no ssh connection
src_host=`echo $src | sed 's/:.*$//'`
if $verbose; then
  echo "checking ssh connection"
fi
if ! ssh $src_host :; then 
  exit 
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
# replace colons to avoid path name issues
name=`echo $name | sed 'y/:/./'`

# make parent directories if needed
if $verbose; then
  mkdir -pv "$dest"
else
  mkdir -p "$dest"
fi

# loop through backups from oldest to most recent
baks=`ls "$dest"`
i=`echo $baks | wc -w`
for b in $baks; do
  # remove old backups
  if [ $i -gt $max ]; then
    rm -rf "$dest$b"
  fi
  if [ $i -eq 1 ]; then
    linkdest="$dest$b"
  fi
  i=$((i-1))
done

# set up rsync options
opts='-az'
if $dry; then
  opts="${opts}n"
fi
if $verbose; then
  opts="${opts}v"
fi

# if the linkdest variable isn't empty use it
if [ -n $linkdest ]; then
  rsync $opts --del --link-dest=$linkdest "$src" "$dest$name"
else
  rsync $opts --del "$src" "$dest$name"
fi
