#!/bin/bash -e
cd /home/git/gitwerk
RESULT=$(mix git_shell --key=$1 --command="$SSH_ORIGINAL_COMMAND")
echo $RESULT;
if [ $? == "0" ]
then
    exit 0;
else
    exit 1;
fi
