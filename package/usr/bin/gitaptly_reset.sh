#!/bin/bash
set -e
source /opt/gitaptly/env
if [ -f /usr/bin/opentelemetry_shell.sh ]; then
  export OTEL_SERVICE_NAME=GitAptly
  export OTEL_SHELL_TRACES_ENABLE=TRUE
  export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="$OTLP_TRACES_ENDPOINT"
  export OTEL_EXPORTER_OTLP_TRACES_HEADERS=authorization=$(echo "$OTLP_TRACES_HEADER" | jq -Rr @uri)
  export OTEL_SHELL_METRICS_ENABLE=TRUE
  export OTEL_EXPORTER_OTLP_METRICS_ENDPOINT="$OTLP_METRICS_ENDPOINT"
  export OTEL_EXPORTER_OTLP_METRICS_HEADERS=authorization=$(echo "$OTLP_METRICS_HEADER" | jq -Rr @uri)
  export OTEL_SHELL_LOGS_ENABLE=TRUE
  export OTEL_EXPORTER_OTLP_LOGS_ENDPOINT="$OTLP_LOGS_ENDPOINT"
  export OTEL_EXPORTER_OTLP_LOGS_HEADERS=authorization=$(echo "$OTLP_LOGS_HEADER" | jq -Rr @uri)
  source /usr/bin/opentelemetry_shell.sh
fi

rm /var/lib/gitaptly/dists/stable/main/binary-all/Packages
rm -rf /var/lib/gitaptly/pool/main/*
rm -rf /var/lib/gitaptly/cgi-bin/main/*
bash /usr/bin/gitaptly_update.sh
