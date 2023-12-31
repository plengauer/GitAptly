#!/bin/bash
set -e

owner=$1
repo=$2

curl --no-progress-meter https://api.github.com/repos/$owner/$repo/releases | jq '.[] | .assets[] | .browser_download_url' -r | (grep '.deb$' || true)
