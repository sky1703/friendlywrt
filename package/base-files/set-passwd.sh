#!/bin/sh

if [ $# -ne 1 ]
then
  echo "Usage: $0 <password>"
  exit 1
fi
ps1="${1}"
passwd=$(openssl passwd -1 ${ps1})
awk 'BEGIN {FS=":"; OFS=":";}  {if ($0 ~ /^root/) {print $1,"'$passwd'",$3,$4,$5,$6,"::";} else {print $0;}}' < files/etc/shadow > myshadow
mv myshadow files/etc/shadow
