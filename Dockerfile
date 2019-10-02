ARG BASE_DOCKER_IMAGE
FROM alpine as dl
ARG ENONIC_CLI_VERSION
RUN wget https://repo.enonic.com/public/com/enonic/cli/enonic/${ENONIC_CLI_VERSION}/enonic_${ENONIC_CLI_VERSION}_Linux_64-bit.tar.gz -qO- | tar xvz

FROM $BASE_DOCKER_IMAGE
COPY --from=dl --chown=0:0 /enonic /usr/local/bin/enonic

# Set environment
ARG ENONIC_DISTRO_VERSION
ENV ENONIC_DISTRO_VERSION=${ENONIC_DISTRO_VERSION} \
    ENONIC_SANDBOX_NAME=builder

USER root

# Create enonic sandbox and move $HOME/.enonic to /.enonic and allow all users to access it
RUN enonic sandbox create ${ENONIC_SANDBOX_NAME} --version=${ENONIC_DISTRO_VERSION} \
    && mv /root/.enonic /.enonic \
    && chmod -R 0775 /.enonic

RUN ln -s /.enonic /root/.enonic

# Setup entrypoint
COPY bin/docker-entrypoint.sh /docker-entrypoint.sh
COPY bin/setup_sandbox.sh /setup_sandbox.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "bash" ]