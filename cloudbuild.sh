#!/bin/bash

# TARBALLURL='https://nas-public-zt.neruthes.xyz/homepage-gen3-f2fe33d6fd3620c108a3db17/pkgdist/wwwdist.tar'
# TARBALLURL='https://nas-public.neruthes.xyz:2096/homepage-gen3-f2fe33d6fd3620c108a3db17/pkgdist/wwwdist.tar'
TARBALLURL='http://naslan.neruthes.xyz/_public/homepage-gen3-f2fe33d6fd3620c108a3db17/pkgdist/wwwdist.tar'

mkdir -p .cloudbuildroot
cd .cloudbuildroot
rm -rf ./*
wget "$TARBALLURL" -O wwwdist.tar && tar -pxvf wwwdist.tar
