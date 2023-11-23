ARG ALPINE_IMAGE
#hadolint ignore=DL3006
FROM $ALPINE_IMAGE

ARG ALPINE_MIRROR_PATH
ARG SQUID_VERSION
#hadolint ignore=DL3018
RUN set -ex && \
    sed -i -e 's/https:/http:/g' /etc/apk/repositories && \
    if [ -n "$ALPINE_MIRROR_PATH" ] ; then sed -i -e "s%http://dl-cdn.alpinelinux.org%${ALPINE_MIRROR_PATH}%" -e "s%https://dl-cdn.alpinelinux.org%${ALPINE_MIRROR_PATH}%" /etc/apk/repositories; fi && \
    apk update -q --no-progress && \
    apk add -q --no-cache --no-progress bash curl squid="${SQUID_VERSION}" && \
    rm -rf /var/lib/apk/lists/* && \
    rm /var/cache/apk/*

COPY entrypoint.sh /usr/local/bin/

EXPOSE 3128
VOLUME /var/cache/squid

CMD ["/usr/local/bin/entrypoint.sh"]
