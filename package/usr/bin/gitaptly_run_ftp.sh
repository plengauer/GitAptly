#!/bin/bash
set -e
source /opt/gitaptly/env
source /opt/gitaptly/bin/activate
exec python3 -m http.server --cgi --directory /var/lib/gitaptly $PORT
