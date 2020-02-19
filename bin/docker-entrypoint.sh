#!/bin/bash

# Create user entry in /etc/passws
if ! whoami &> /dev/null; then
	if [ -w /etc/passwd ]; then
		echo "Creating user entry ..."
        echo "${ENONIC_UNAME}:x:$(id -u):0:${ENONIC_UNAME} user:${ENONIC_HOME}:/bin/bash" >> /etc/passwd
	fi
fi

/setup_sandbox.sh

exec "$@"