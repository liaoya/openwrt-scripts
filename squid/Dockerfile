FROM docker.io/library/alpine:3.15.0

ARG SQUID_VERSION=5.2-r0
#hadolint ignore=DL3018
RUN set -ex && \
    apk update && \
    apk add --no-cache bash curl squid="${SQUID_VERSION}" && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

COPY entrypoint.sh /usr/local/bin/

EXPOSE 3128
VOLUME /var/cache/squid

CMD ["/usr/local/bin/entrypoint.sh"]
