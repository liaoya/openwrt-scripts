# README

Clean the images

```bash
docker image ls --format "{{.ID}} {{.Repository}}:{{.Tag}}" | grep openwrtorg | grep 22.03.3 | cut -d" " -f1 | xargs docker image rm
```
