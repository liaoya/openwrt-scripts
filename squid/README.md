# REAMDE

- Verify squid: run `curl -Lv --proxy http://localhost:3128 http://httpbin.org/get`
- Verify cache
  - Run `curl -Lv --proxy http://localhost:3128 http://mirrors.ustc.edu.cn/alpine/v3.15/main/x86_64/aaudit-server-0.7.2-r2.apk -o /dev/null` twice
  - Run `docker exec -it squid_squid_1 cat /var/log/squid/access.log` to verify that there is `TCP_MEM_HIT/200` in it
