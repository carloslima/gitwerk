#!/bin/bash

mkdir -p priv/dev/.ssh
mkdir -p ~/.ssh
touch priv/dev/.ssh/authorized_keys2
rm -rf /home/git/.ssh/authorized_keys2
ln -s /home/git/gitwerk/priv/dev/.ssh/authorized_keys2 /home/git/.ssh/authorized_keys2
rm -rf /home/git/repositories
ln -s /home/git/gitwerk/priv/dev/repositories /home/git/repositories
sudo /usr/sbin/sshd -D &
cd assets/elm-app
elm-app start &
cd ../../
iex --sname gitwerk_srv -S mix phx.server
