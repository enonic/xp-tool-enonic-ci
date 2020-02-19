#!/bin/bash

echo "Setting up ${ENONIC_SANDBOX_NAME} sandbox ... "

# Create sandbox if not present
if [ ! -d $HOME/.enonic ]; then
    echo "Warning, home dir '$HOME/.enonic' not found ... configure your build to use HOME='/home/builder' to speed up future builds"
    enonic sandbox create ${ENONIC_SANDBOX_NAME} --version=${ENONIC_DISTRO_VERSION}
fi

# Try to set project sandbox
if [ "$(enonic project sandbox ${ENONIC_SANDBOX_NAME} 2>&1)" == "Not a valid project folder" ]; then
    echo "Setup failed! Is working directory an XP app?"
else
    echo "Setup success!"
fi