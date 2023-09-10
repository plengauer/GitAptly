#!/bin/bash
set -e
. /usr/share/debconf/confmodule

db_get gitaptly/PORT
port="$RET"

source /opt/gitaptly/bin/activate
exec python3 -m http.server --directory /var/lib/gitaptly $port
