FROM alpine:3.7
LABEL maintainer="Liam Martens <hi@liammartens.com>"

# @arg USER This will contain the name of the non-root user that will be added
ONBUILD ARG USER
# @arg ID This will contain the deafult user and group id
ONBUILD ARG ID
# @arg SHELL The default shell to be used
ONBUILD ARG SHELL
# @arg TIMEZONE The timezone to use in the container
ONBUILD ARG TIMEZONE
# @arg LOCALE The locale to use
ONBUILD ARG LOCALE
# @arg ENCODING The encoding to use
ONBUILD ARG ENCODING

# @env USER This will contain the name of the non-root user that will be added
ONBUILD ENV USER=${USER:-user}
# @env ID This will contain the id to use for the non-root user and group
ONBUILD ENV ID=${ID:-1000}
# @env SHELL The default shell to use
ONBUILD ENV SHELL=${SHELL:-/bin/bash}
# @env TIMEZONE The timezone to use
ONBUILD ENV TIMEZONE=${TIMEZONE:-UTC}
# @env LOCALE The locale
ONBUILD ENV LOCALE=${LOCALE:-en_US.UTF-8}
# @env ENCODING The encoding
ONBUILD ENV ENCODING=${ENCODING:-UTF-8}
# @env LC_ALL
ONBUILD ENV LC_ALL=${LOCALE}

# @run Update the alpine image
ONBUILD RUN apk update && apk upgrade

# @run Add default packages
ONBUILD RUN apk add tzdata perl curl bash nano git supervisor

# @run Add group
ONBUILD RUN addgroup -g ${ID} ${USER}

# @run Add the non-root user
ONBUILD RUN adduser -D -G ${USER} -u ${ID} ${USER}

# @run Create the timezone files
ONBUILD RUN touch /etc/timezone /etc/localtime

# @run Chown the timezone files
ONBUILD RUN chown ${USER}:${USER} /etc/timezone /etc/localtime

# @run Save timezone data
ONBUILD RUN cat /usr/share/zoneinfo/${TIMEZONE} > /etc/localtime
ONBUILD RUN echo ${TIMEZONE} > /etc/timezone

# @run Set locale
ONBUILD RUN echo "${LOCALE} ${ENCODING}" > /etc/locale.gen && \
    locale-gen ${LOCALE} && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=${LOCALE}

# @arg DOCKER_DIR The docker scripts directory
ARG DOCKER_DIR

# @env DOCKER_DIR The docker scripts directory
ENV DOCKER_DIR=${DOCKER_DIR:-/opt/docker}
ENV DOCKER_PROVISION_DIR=${DOCKER_DIR}/provision
ENV DOCKER_ETC_DIR=${DOCKER_DIR}/etc
ENV DOCKER_BIN_DIR=${DOCKER_DIR}/bin
ENV DOCKER_TMP_DIR=${DOCKER_DIR}/tmp
ENV PATH=${PATH}:${DOCKER_BIN_DIR}

# @run Create docker directory
RUN mkdir -p ${DOCKER_DIR} ${DOCKER_PROVISION_DIR} ${DOCKER_ETC_DIR} ${DOCKER_BIN_DIR} ${DOCKER_TMP_DIR}

# @copy Copy .docker file(s)
COPY .docker/ ${DOCKER_DIR}

# @run chown and chmod .docker directory
ONBUILD RUN chown -R ${USER}:${USER} ${DOCKER_DIR}
ONBUILD RUN chmod -R 750 ${DOCKER_DIR}

# @run Make docker script(s) executable
ONBUILD RUN chmod -R +x ${DOCKER_PROVISION_DIR} ${DOCKER_DIR}

# @user Set user
ONBUILD USER ${USER}

# @entrypoint
ONBUILD ENTRYPOINT [ "container-init" ]

# @cmd
ONBUILD CMD [ "-i", "-c", "supervisord -c ${DOCKER_ETC_DIR}/supervisord.conf" ]