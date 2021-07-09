# Environment

```bash
sudo mkdir -p /work/openwrt
sudo chown "$(id -un):$(id -gn)" /work/openwrt

mkdir ~/.cache/openwrt
scp -pqr root@10.113.69.101:/var/mirror/openwrt/*.xz ~/.cache/openwrt/
scp -pqr root@10.113.69.101:/var/mirror/openwrt/dl /work/openwrt/
scp -pqr root@10.113.69.101:/var/mirror/openwrt/package /work/openwrt/

git config --global url."http://10.113.69.101:5903/".insteadOf https://
```

```bash
rsync ~/.cache/openwrt/*.xz root@10.113.69.101:/var/mirror/openwrt/
rsync -r --exclude go-mod-cache /work/openwrt/dl root@10.113.69.101:/var/mirror/openwrt/
rsync -r /work/openwrt/package root@10.113.69.101:/var/mirror/openwrt/

# In the parent folder of openwrt
rsync -r root@10.113.69.101:/var/mirror/openwrt/ .

for _item in $(ls -t1 "$HOME/.vscode-server/bin" | sed 1d); do
    rm -fr "$HOME/.vscode-server/bin/${_item}"
done for _item in $(ls -t1 "$HOME/.vscode-server/bin" | sed 1d); do
    rm -fr "$HOME/.vscode-server/bin/${_item}"
done

rsync --no-acls --no-perms --no-xattrs -r --exclude go-mod-cache /work/openwrt/dl /media/huifshen/WD/openwrt/
rsync --no-acls --no-perms --no-xattrs -r /work/openwrt/package /media/huifshen/WD/openwrt/
```
