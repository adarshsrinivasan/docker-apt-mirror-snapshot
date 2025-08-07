#! /usr/bin/env bash

: ${USER:=${1}}
: ${PASS:=${2}}

[[ -z ${USER} ]] && { echo "User wasn't specified"; exit 1; }
[[ -z ${PASS} ]] && { echo "Pass wasn't specified"; exit 1; }

RECORD=$(echo -n "${USER}:" && echo "${PASS}" | openssl passwd -apr1 -stdin)

echo ${RECORD} | tee -a /apt-mirror/api.htpasswd \
    && echo "User & pass has added to /apt-mirror/api.htpasswd" \
    || echo "Something has gone wrong"