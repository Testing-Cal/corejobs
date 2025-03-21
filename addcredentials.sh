#!/bin/bash

credentialsfile=.credentials

if [ -z "$1" ]; then
    echo "No argument supplied"
    exit
fi
if [[ "$1" == "/"* ]] || [[ "$1" == "./"* ]]; then
    credentials_to_add=`cat "$1"`
    isfilecred=true
    echo "Reading new credentials from file : $1"
else
    credentials_to_add="$1"
    echo "Reading new credentials form argument"
fi

key=`sudo cat /etc/shadow | grep -e "^${USER}"`
echo "Key for encryption: $key"

export key=$key
if [[ -f "$credentialsfile" ]]; then
    credentials=$(openssl enc -aes-256-cbc -a -d -in "$credentialsfile" -pbkdf2 -iter 1000000 -md sha512 -pass env:key)
fi

echo "New credentials environment keys : "
while read entry; do
    okey=$(jq -r '.key' <<< $entry)
    echo "- $okey"
    ovalue=$(jq -r '.value' <<< $entry)
    ovalue="${ovalue//\$/\\\$}"
    credentials=$(echo "$credentials"; echo "export \"$okey=$ovalue\"")
done < <(jq -c 'to_entries []' <<< $credentials_to_add);

echo "$credentials" | openssl enc -aes-256-cbc -a -e -out "$credentialsfile" -pbkdf2 -iter 1000000 -md sha512 -pass env:key

if [[ $isfilecred == "true" ]]; then
    rm "$1"
fi;

export key=

