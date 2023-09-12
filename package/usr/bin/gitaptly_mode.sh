#!/bin/bash
set -e
. /usr/share/debconf/confmodule
db_get gitaptly/MODE
echo "$RET"
