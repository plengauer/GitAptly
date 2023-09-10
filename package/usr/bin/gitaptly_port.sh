#!/bin/bash
set -e
. /usr/share/debconf/confmodule
db_get gitaptly/PORT
echo "$RET"
