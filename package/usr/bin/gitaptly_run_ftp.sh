#!/bin/bash
set -e
port=$(bash /usr/bin/gitaptly_port.sh)
source /opt/gitaptly/bin/activate
exec python3 -m http.server --cgi --directory /var/lib/gitaptly $port
