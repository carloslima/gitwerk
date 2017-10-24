#!/bin/sh

mkdir -p priv/test/ssh_keys
cd priv/test/ssh_keys
ssh-keygen -N '' -b 256 -t ecdsa -f ssh_host_ecdsa_key
ssh-keygen -N '' -b 1024 -t dsa -f ssh_host_dsa_key
ssh-keygen -N '' -b 2048 -t rsa -f ssh_host_rsa_key

cd ~

git config --global user.email "travis@ci.com"
git config --global user.name "Travis"

git clone --depth=1 -b maint/v0.26 https://github.com/libgit2/libgit2.git
cd libgit2/

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=../_install -DBUILD_CLAR=OFF
cmake --build . --target install

ls -la ..
