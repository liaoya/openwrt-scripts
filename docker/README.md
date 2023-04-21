# README

Clean the images

```bash
docker image ls --format "{{.ID}} {{.Repository}}:{{.Tag}}" | grep openwrtorg | grep 22.03.4 | cut -d" " -f1 | xargs docker image rm
```
