#!/bin/bash

mkdir -p priv/dev/.ssh
mkdir -p ~/.ssh
touch priv/dev/.ssh/authorized_keys2
rm -rf /home/git/.ssh/authorized_keys2
ln -s /home/git/gitwerk/priv/dev/.ssh/authorized_keys2 /home/git/.ssh/authorized_keys2
rm -rf /home/git/repositories
ln -s /home/git/gitwerk/priv/dev/repositories /home/git/repositories
cd web
npm install
cd ..
mix deps.get
iex -S mix phx.server
