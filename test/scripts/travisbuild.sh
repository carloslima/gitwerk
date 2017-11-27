#!/bin/sh

mkdir -p priv/test/ssh_keys
cd priv/test/ssh_keys
ssh-keygen -N '' -b 256 -t ecdsa -f ssh_host_ecdsa_key
ssh-keygen -N '' -b 1024 -t dsa -f ssh_host_dsa_key
ssh-keygen -N '' -b 2048 -t rsa -f ssh_host_rsa_key

cd ~

git config --global user.email "travis@ci.com"
git config --global user.name "Travis"
