#!/bin/bash
set -e
source /opt/gitaptly/env
if [ -f /usr/bin/opentelemetry_shell.sh ]; then
  export OTEL_SERVICE_NAME=GitAptly
  export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="$OTLP_TRACES_ENDPOINT"
  export OTEL_EXPORTER_OTLP_TRACES_HEADERS=authorization=$(echo "$OTLP_TRACES_HEADER" | jq -Rr @uri)
  source /usr/bin/opentelemetry_shell.sh
fi

path="$SCRIPT_NAME"
file=$(echo "$path" | rev | cut -d/ -f1 | rev)
repo=$(echo "$path" | rev | cut -d/ -f2 | rev)
owner=$(echo "$path" | rev | cut -d/ -f3 | rev)

echo "Content-Type: application/vnd.debian.binary-package"
echo ""
wget -O - $(bash /usr/bin/gitaptly_scan.sh $owner $repo | (grep "$file"'$' || true) | head --lines=1)
