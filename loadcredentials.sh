#!/bin/bash

credentialsfile=$HOME/.credentials

if [[ -f "$credentialsfile" ]]; then
    key=`sudo cat /etc/shadow | grep -e "^${USER}"`
    export key=$key
    credentials=$(openssl enc -aes-256-cbc -a -d -in "$credentialsfile" -pbkdf2 -iter 1000000 -md sha512 -pass env:key)
    source <(echo "$credentials")
fi

export key=
