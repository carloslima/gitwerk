#!/bin/bash
cd /home/git/gitwerk
RESULT=$(iex --hidden -S mix git_shell --key=$1 --command="$SSH_ORIGINAL_COMMAND" 2>/dev/null)
RESULT=$(echo $RESULT | cut -d " " -f1-2)
if [ $? == "0" ]
then
    if [ "$RESULT" == "" ]
    then
        echo "Welcome to GitWerk!"
        exit 1;
    else
        exec $RESULT
    fi
else
    echo "Welcome to GitWerk!"
    exit 1;
fi
