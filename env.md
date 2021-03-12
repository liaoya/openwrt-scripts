# Environment

```bash
sudo mkdir -p /work
sudo chown "$(id -un):$(id -gn)" /work

mkdir ~/.cache/openwrt
scp -pqr root@10.113.69.101:/var/mirror/openwrt/*.xz ~/.cache/openwrt/
scp -pqr root@10.113.69.101:/var/mirror/openwrt/dl ~/Downloads/

git config --global url."http://10.113.69.101:5903/".insteadOf https://
```

```bash
rsync ~/.cache/openwrt/*.xz root@10.113.69.101:/var/mirror/openwrt/
rsync -r --exclude go-mod-cache dl root@10.113.69.101:/var/mirror/openwrt/dl
rsync -r package root@10.113.69.101:/var/mirror/openwrt/package

rsync -r root@10.113.69.101:/var/mirror/openwrt .
```
