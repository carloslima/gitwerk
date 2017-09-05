#!/bin/bash

mkdir -p priv/dev/.ssh
mkdir -p ~/.ssh
touch priv/dev/.ssh/authorized_keys2
ln -s /home/git/gitwerk/priv/dev/.ssh/authorized_keys2 /home/git/.ssh/authorized_keys2
sudo /usr/sbin/sshd -D &
iex --sname gitwerk_srv -S mix phx.server
