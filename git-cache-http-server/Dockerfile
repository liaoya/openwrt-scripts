FROM node:lts-alpine

ARG PORT=8080
RUN apk update \
    && apk add bash git \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/* \
    && npm install -g git+https://git@github.com/jonasmalacofilho/git-cache-http-server.git

EXPOSE $PORT
VOLUME /var/cache/git

CMD ["node", "/usr/local/bin/git-cache-http-server"]
