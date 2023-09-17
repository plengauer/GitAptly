#!/bin/bash
set -e
source /opt/gitaptly/env
source /opt/gitaptly/bin/activate
cmd=(python3 -m http.server --cgi --directory /var/lib/gitaptly $PORT)
if [ -n "$OTLP_TRACES_ENDPOINT" ] || [ -n "$OTLP_METRICS_ENDPOINT" ]; then
  export OTEL_SERVICE_NAME="GitAptly"
  export OTEL_TRACES_EXPORTER=otlp_proto_http
  export OTEL_METRICS_EXPORTER=otlp_proto_http
  export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="$OTLP_TRACES_ENDPOINT"
  export OTEL_EXPORTER_OTLP_METRICS_ENDPOINT="$OTLP_METRICS_ENDPOINT"
  export OTEL_EXPORTER_OTLP_TRACES_HEADERS=authorization=$(echo "$OTLP_TRACES_HEADER" | jq -Rr @uri)
  export OTEL_EXPORTER_OTLP_METRICS_HEADERS=authorization=$(echo "$OTLP_METRICS_HEADER" | jq -Rr @uri)
  cmd=(opentelemetry-instrument "${cmd[@]}")
fi
exec "${cmd[@]}"
