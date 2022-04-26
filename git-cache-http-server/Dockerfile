FROM node:alpine3.12

# hadolint ignore=DL3016
RUN apk update -q --no-progress && \
    apk add --no-cache --no-progress bash git

RUN npm install -g npm && \
    npm install -g git+https://git@github.com/jonasmalacofilho/git-cache-http-server.git

ARG PORT=8080
EXPOSE $PORT
VOLUME /var/cache/git

CMD ["node", "/usr/local/bin/git-cache-http-server"]
