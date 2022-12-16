#!/bin/bash

TARBALLURL='https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/files/neruthes-homepage-gen3/pkgdist/wwwdist.tar'
if [[ $USER == neruthes ]]; then
    TARBALLURL='http://naslan.neruthes.xyz/_public/homepage-gen3-f2fe33d6fd3620c108a3db17/pkgdist/wwwdist.tar'
fi

if [[ ! -z "$1" ]]; then
    TARBALLURL="$1"
fi

mkdir -p .cloudbuildroot
cd .cloudbuildroot
rm -rf ./*
curl "$TARBALLURL" -o wwwdist.tar && tar -pxvf wwwdist.tar
