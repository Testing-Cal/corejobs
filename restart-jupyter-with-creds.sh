#!/bin/bash

kill `lsof -nP -iTCP -sTCP:LISTEN | grep -e "jupyter.*:8888" | head -n1  | sed -nE "s/(jupyter[-a-z]*\s*)([0-9]*)(.*)/\2/p"`

source /opt/loadcredentials.sh

if ! cat .bash_profile | grep -q '## LOADCREDENTIALS'; then
cat << EOF >> .bash_profile

## LOADCREDENTIALS
source /opt/loadcredentials.sh
EOF
fi;

nohup jupyter lab --ip=* --NotebookApp.token="" >/dev/null 2>&1 &
