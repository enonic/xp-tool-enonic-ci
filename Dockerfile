ARG BASE_DOCKER_IMAGE
FROM alpine as dl

# Download the CLI
ARG ENONIC_CLI_VERSION
RUN wget https://repo.enonic.com/public/com/enonic/cli/enonic/${ENONIC_CLI_VERSION}/enonic_${ENONIC_CLI_VERSION}_Linux_64-bit.tar.gz -qO- | tar xvz

FROM $BASE_DOCKER_IMAGE

# Copy CLI over
COPY --from=dl --chown=0:0 /enonic /usr/local/bin/enonic

# Set environment
ARG ENONIC_DISTRO_VERSION
ENV ENONIC_DISTRO_VERSION=${ENONIC_DISTRO_VERSION} \
    ENONIC_SANDBOX_NAME=builder \
    ENONIC_UID=1000 \
    ENONIC_UNAME=builder \
    ENONIC_HOME=/home/builder

# Has to be root to work on Github Actions
USER root

# Setup scripts
COPY bin/setup_sandbox.sh /setup_sandbox.sh

RUN \
    # Allow entrypoint to create associated entry in /etc/passwd
    chmod g=u /etc/passwd && \
    # Change root home
    sed -i s%:/root%:$ENONIC_HOME%g /etc/passwd && \
    # Delete unwanted users
    cat /etc/passwd | grep -E '1000|3434' | cut -d: -f1 | xargs -I {} deluser --remove-home {} && \
    # Add user
    adduser --home $ENONIC_HOME --gecos "" --UID $ENONIC_UID --gid 0 --disabled-password $ENONIC_UNAME && \
    # Setup sandbox
    HOME=$ENONIC_HOME chroot --userspec=$ENONIC_UID / /setup_sandbox.sh && \
    # Allow all users to use builder home dir
    chmod -R a+rwX $ENONIC_HOME

ENV HOME=$ENONIC_HOME

# Setup entrypoint
COPY bin/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "bash" ]