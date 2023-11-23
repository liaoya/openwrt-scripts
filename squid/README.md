# REAMDE

```bash
export SQUID_VERSION=5.9-r0
env ALPINE_IMAGE=docker.io/library/alpine:3.18.4@sha256:48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86 ../build-docker.sh -w .
docker image save -o squid-${SQUID_VERSION}.tar yaekee/squid:${SQUID_VERSION}
docker image load -i squid-${SQUID_VERSION}.tar

export SQUID_VERSION=5.2-r0
env ALPINE_IMAGE=docker.io/library/alpine:3.15.10@sha256:36ca6d117c068378d5461b959d019eabe8877770f13e11e54a5ce9f3827a7e72 ../build-docker.sh -w .
docker image save -o squid-${SQUID_VERSION}.tar yaekee/squid:${SQUID_VERSION}
docker image load -i squid-${SQUID_VERSION}.tar

export SQUID_VERSION=5.0.6-r2
env ALPINE_IMAGE=docker.io/library/alpine:3.14.10@sha256:71859b0c62df47efaeae4f93698b56a8dddafbf041778fd668bbd1ab45a864f8 ../build-docker.sh -w .
docker image save -o squid-${SQUID_VERSION}.tar yaekee/squid:${SQUID_VERSION}
docker image load -i squid-${SQUID_VERSION}.tar

export SQUID_VERSION=4.17-r0
env ALPINE_IMAGE=docker.io/library/alpine:3.12.12@sha256:cb64bbe7fa613666c234e1090e91427314ee18ec6420e9426cf4e7f314056813 ../build-docker.sh -w .
docker image save -o squid-${SQUID_VERSION}.tar yaekee/squid:${SQUID_VERSION}
docker image load -i squid-${SQUID_VERSION}.tar

export SQUID_VERSION=3.5.27-r4
env ALPINE_IMAGE=docker.io/library/alpine:3.8.5@sha256:954b378c375d852eb3c63ab88978f640b4348b01c1b3456a024a81536dafbbf4 ../build-docker.sh -w .
docker image save -o squid-${SQUID_VERSION}.tar yaekee/squid:${SQUID_VERSION}
docker image load -i squid-${SQUID_VERSION}.tar
```

- Verify squid: run `curl -Lv --proxy http://localhost:3128 http://httpbin.org/get`
- Verify cache
  - Run `curl -Lv --proxy http://localhost:3128 http://mirrors.ustc.edu.cn/alpine/v3.15/main/x86_64/aaudit-server-0.7.2-r2.apk -o /dev/null` twice
  - Run `docker exec -it squid_squid_1 cat /var/log/squid/access.log` to verify that there is `TCP_MEM_HIT/200` in it
