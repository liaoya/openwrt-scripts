FROM docker.io/library/node:16-alpine3.15

# hadolint ignore=DL3018
RUN apk update -q --no-progress && \
    apk add --no-cache --no-progress bash git

# hadolint ignore=DL3016
RUN npm install --location=global npm && \
    npm install --location=global git+https://git@github.com/jonasmalacofilho/git-cache-http-server.git#13c811264f87b00d089c0267d7f69ebc7268f170

ARG PORT=8080
EXPOSE $PORT
VOLUME /var/cache/git

CMD ["node", "/usr/local/bin/git-cache-http-server"]
