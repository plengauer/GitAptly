#!/bin/bash
set -e
source /opt/gitaptly/env
if [ -f /usr/bin/opentelemetry_shell.sh ]; then
  export OTEL_SERVICE_NAME=GitAptly
  export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="$OTLP_TRACES_ENDPOINT"
  export OTEL_EXPORTER_OTLP_TRACES_HEADERS=authorization=$(echo "$OTLP_TRACES_HEADER" | jq -Rr @uri)
  export OTEL_EXPORTER_OTLP_METRICS_ENDPOINT="$OTLP_METRICS_ENDPOINT"
  export OTEL_EXPORTER_OTLP_METRICS_HEADERS=authorization=$(echo "$OTLP_METRICS_HEADER" | jq -Rr @uri)
  export OTEL_EXPORTER_OTLP_LOGS_ENDPOINT="$OTLP_LOGS_ENDPOINT"
  export OTEL_EXPORTER_OTLP_LOGS_HEADERS=authorization=$(echo "$OTLP_LOGS_HEADER" | jq -Rr @uri)
  source /usr/bin/opentelemetry_shell.sh
fi

path="$SCRIPT_NAME"
file=$(echo "$path" | rev | cut -d/ -f1 | rev)
repo=$(echo "$path" | rev | cut -d/ -f2 | rev)
owner=$(echo "$path" | rev | cut -d/ -f3 | rev)

if [ -n "$root_span_id" ]; then
  otel_span_attribute $root_span_id "http.route="/$owner/$repo
fi

echo "Content-Type: application/vnd.debian.binary-package"
echo ""
wget -O - $(bash /usr/bin/gitaptly_scan.sh $owner $repo | (grep "$file"'$' || true) | head --lines=1)
