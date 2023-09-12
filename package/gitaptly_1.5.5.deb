#!/bin/bash
set -e

path="$SCRIPT_NAME"
file=$(echo "$path" | rev | cut -d/ -f1 | rev)
repo=$(echo "$path" | rev | cut -d/ -f2 | rev)
owner=$(echo "$path" | rev | cut -d/ -f3 | rev)

echo "Content-Type: application/vnd.debian.binary-package"
echo ""
wget -O - $(bash /usr/bin/gitaptly_scan.sh $repo $owner | (grep "$file"'$' || true) | head --lines=1)
