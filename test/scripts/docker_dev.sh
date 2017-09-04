#!/bin/bash

sudo /usr/sbin/sshd -D &
mix phx.server
