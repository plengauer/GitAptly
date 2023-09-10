#!/bin/bash
set -e

destination=$1
owner=$2
repo=$3

echo "searching "$owner"/"$repo

urls=$(curl https://api.github.com/repos/$owner/$repo/releases | jq '.[] | .assets[] | .browser_download_url' -r | (grep '.deb$' || true))
echo "found "$urls

wget -q -nc -P $destination $urls || true
