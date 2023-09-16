#!/bin/bash
set -e
source /opt/gitaptly/env
export OTEL_SERVICE_NAME=GitAptly
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="$OTLP_TRACES_ENDPOINT"
export OTEL_EXPORTER_OTLP_TRACES_HEADERS="$OTLP_TRACES_HEADERS"
source /usr/bin/opentelemetry_bash.sh
cd /var/lib/gitaptly

source /opt/gitaptly/env

# TODO handle if one mode is switched to the other (packages and evrything needs to be cleared and fully re-initialized)
# TODO clean if deb packages are remove
# TODO better recovery in proxy mode, check if Packages is there, and if not, redo a full scan

if [ "$MODE" = 'cache' ]; then
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
  while read line; do
    line=$(echo "$line" | xargs)
    if [ -z "$line" ]; then
      continue
    fi
    owner=$(echo $line | cut -d "/" -f 1)
    repo=$(echo $line | cut -d "/" -f 2)
    mkdir -p pool/main/$owner/$repo
    for url in $(bash /usr/bin/gitaptly_scan.sh $owner $repo)
    do
      file=$(echo $url | rev | cut -d "/" -f 1 | rev)
      if [ -f pool/main/$owner/$repo/$file ]; then
        continue
      fi
      wget -q -nc -O pool/main/$owner/$repo/$file $url
      dpkg-scanpackages --multiversion pool/main/$owner/$repo/$file | sed "s/Filename: .*/Filename: cgi-bin\/main\/$owner\/$repo\/$file/" >> dists/stable/main/binary-all/Packages
      rm pool/main/$owner/$repo/$file
      ln --symbolic /usr/bin/gitaptly_serve.sh pool/main/$owner/$repo/$file
    done
  done < /etc/gitaptly.conf

else
  exit 1
fi

gzip -9 < dists/stable/main/binary-all/Packages > dists/stable/main/binary-all/Packages.gz
bash /usr/bin/gitaptly_create_release.sh dists/stable > dists/stable/Release
