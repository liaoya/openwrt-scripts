# Environment

```bash
sudo mkdir -p /work
sudo chown "$(id -un):$(id -gn)" /work

mkdir ~/.cache/openwrt
scp -pqr root@10.113.69.101:/var/mirror/openwrt/*.xz ~/.cache/openwrt/
scp -pqr root@10.113.69.101:/var/mirror/openwrt/dl ~/Downloads/

git config --global url."http://10.113.69.101:5903/".insteadOf https://
```
