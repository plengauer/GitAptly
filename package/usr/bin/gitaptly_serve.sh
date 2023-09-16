#!/bin/bash
set -e
source /opt/gitaptly/env
export OTEL_SERVICE_NAME=GitAptly
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="$OTLP_TRACES_ENDPOINT"
export OTEL_EXPORTER_OTLP_TRACES_HEADERS="$OTLP_TRACES_HEADERS"
source /usr/bin/opentelemetry_bash.sh

path="$SCRIPT_NAME"
file=$(echo "$path" | rev | cut -d/ -f1 | rev)
repo=$(echo "$path" | rev | cut -d/ -f2 | rev)
owner=$(echo "$path" | rev | cut -d/ -f3 | rev)

echo "Content-Type: application/vnd.debian.binary-package"
echo ""
wget -O - $(bash /usr/bin/gitaptly_scan.sh $owner $repo | (grep "$file"'$' || true) | head --lines=1)
