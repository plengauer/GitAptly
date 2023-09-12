#!/bin/bash
set -e
cd /var/lib/gitaptly/apt-repo

source /opt/gitaptly/env

if [ "$MODE" = 'cache' ]; then
  rm -rf cgi-bin/pool/main/*
  while read line; do
    line=$(echo "$line" | xargs)
    if [ -z "$line" ]; then
      continue
    fi
    owner=$(echo $line | cut -d "/" -f 1)
    repo=$(echo $line | cut -d "/" -f 2)
    mkdir -p pool/main/$owner/$repo
    wget -q -nc -P pool/main/$owner/$repo $(bash /usr/bin/gitaptly_scan.sh $owner $repo) || true
  done < /etc/gitaptly.conf
  dpkg-scanpackages --multiversion pool/ > dists/stable/main/binary-all/Packages

elif [ "$MODE" = 'proxy' ]; then
  rm -rf pool/main/*
  rm -f dists/stable/main/binary-all/Packages
  while read line; do
    line=$(echo "$line" | xargs)
    if [ -z "$line" ]; then
      continue
    fi
    owner=$(echo $line | cut -d "/" -f 1)
    repo=$(echo $line | cut -d "/" -f 2)
    mkdir -p pool/main/$owner/$repo cgi-bin/pool/main/$owner/$repo
    for url in $(bash /usr/bin/gitaptly_scan.sh $owner $repo)
    do
      file=$(echo $url | rev | cut -d "/" -f 1 | rev)
      if [ -f cgi-bin/pool/main/$owner/$repo/$file ]; then
        continue
      fi
      wget -q -nc -O pool/main/$owner/$repo/$file $url
      ln --symbolic /usr/bin/gitaptly_serve.sh cgi-bin/pool/main/$owner/$repo/$file
      dpkg-scanpackages --multiversion pool/ | sed -e "s/Filename: pool/Filename: cgi-bin\/pool/" >> dists/stable/main/binary-all/Packages
      rm pool/main/$owner/$repo/$file
    done
  done < /etc/gitaptly.conf

else
  exit 1
fi

gzip -9 < dists/stable/main/binary-all/Packages > dists/stable/main/binary-all/Packages.gz
bash /usr/bin/gitaptly_create_release.sh dists/stable > dists/stable/Release
