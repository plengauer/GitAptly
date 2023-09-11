#!/bin/bash
set -e

destination=$1
owner=$2
repo=$3

wget -q -nc -P $destination $(bash /usr/bin/gitaptly_scan.sh $owner $repo) || true
