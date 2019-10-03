#!/bin/bash

echo -n "Setting up ${ENONIC_SANDBOX_NAME} sandbox ... "

# Link sandbox into home if not present
if [ ! -d $HOME/.enonic ]; then
    if [ "$HOME" != "/"  ]; then
        ln -s /.enonic $HOME/.enonic
    fi
fi

# Try to set project sandbox
if [ "$(enonic project sandbox ${ENONIC_SANDBOX_NAME} 2>&1)" == "Not a valid project folder" ]; then
    echo "failed! Is working directory an XP app?"
else
    echo "success!"
fi