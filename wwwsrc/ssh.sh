#!/bin/bash


### How to use:
###   $  curl https://neruthes.xyz/ssh.sh | bash

### Make sure dir exists
[[ -d ~/.ssh ]] || (
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
)

cd ~/.ssh
curl https://neruthes.xyz/authorized_keys >> authorized_keys





