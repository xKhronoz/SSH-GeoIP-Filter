#!/bin/bash
# License: GNU GPLv3

# UPPERCASE space-separated ISO country codes to ACCEPT
ALLOW_COUNTRIES="SG"
LOGDENY_FACILITY="authpriv.notice"
MMDB_FILE="/var/lib/GeoIP/GeoLite2-Country.mmdb"

if [ $# -ne 1 ]; then
  echo "Usage:  `basename $0` " 1>&2
  exit 0 # exit normally in case of config issue
fi

COUNTRY=$(/usr/bin/mmdblookup --file "$MMDB_FILE" --ip "$1" country iso_code | grep -o '[^"]*' | grep -v '^[[:space:]]*$' | head -n 1)

[[ $COUNTRY = "IP Address not found" || $ALLOW_COUNTRIES =~ $COUNTRY ]] && RESPONSE="ALLOW" || RESPONSE="DENY"

if [[ "$RESPONSE" == "ALLOW" ]] ; then
  logger -p $LOGDENY_FACILITY "$RESPONSE sshd connection from $1 ($COUNTRY)"
  exit 0 # exit normally
else
  logger -p $LOGDENY_FACILITY "$RESPONSE sshd connection from $1 ($COUNTRY)"
  exit 1 # exit with error
fi
