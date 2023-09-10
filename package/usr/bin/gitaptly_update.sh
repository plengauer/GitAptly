#!/bin/bash
set -e

repo_location=/var/lib/gitaptly/apt-repo

# the following line is just for compatibility in case old versions have been installed
rm $repo_location/pool/main/*.deb

while read line; do
  line=$(echo "$line" | xargs)
  if [ -z "$line" ]; then
    continue
  fi
  owner=$(echo $line | cut -d "/" -f 1)
  repo=$(echo $line | cut -d "/" -f 2)
  mkdir -p $repo_location/pool/main/$owner/$repo
  bash /usr/bin/gitaptly_scan_and_download.sh $repo_location/pool/main/$owner/$repo $owner $repo
done < /etc/gitaptly.conf

pushd $repo_location && dpkg-scanpackages --multiversion pool/ > dists/stable/main/binary-all/Packages && popd
gzip -9 < $repo_location/dists/stable/main/binary-all/Packages > $repo_location/dists/stable/main/binary-all/Packages.gz
bash /usr/bin/gitaptly_create_release.sh $repo_location/dists/stable > $repo_location/dists/stable/Release
