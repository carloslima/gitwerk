#!/bin/bash

sudo /usr/sbin/sshd -D &
iex --sname gitwerk_srv -S mix phx.server
