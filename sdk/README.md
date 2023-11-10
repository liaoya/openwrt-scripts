# README

- `"src-git helloworld https://github.com/fw876/helloworld.git;main"`
- `"src-git small https://github.com/kenzok8/small"`
- `"src-git jell https://github.com/kenzok8/openwrt-packages"`
- `"src-git kenzo https://github.com/kenzok8/jell;main"`
- `"src-git smpackage https://github.com/kenzok8/small-package;main"`
- `"src-git passwall https://github.com/xiaorouji/openwrt-passwall`
- `"src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2`
- `"src-git Lienol https://github.com/Lienol/openwrt-package"`
- `"src-git ophub https://github.com/ophub/luci-app-amlogic"`

```bash
# The following is time consuming
function remove_duplicate() {
    while IFS= read -r feedname; do
        while IFS= read -r packagename; do
            if [[ $(./scripts/feeds search "${packagename}" | grep -c "Search results in feed") -gt 1 ]]; then
                find feeds/base feeds/packages feeds/luci feeds/routing feeds/telephony -type d -iname "${packagename}" -exec rm -fr {} \;
            fi
        done < <(./scripts/feeds list -r "${feedname}" | cut -d " " -f1)
    done < <(./scripts/feeds list -n | grep -v -e 'base\|packages\|luci\|routing\|telephony')
}

function _add_feed() {
    while (($#)); do
        if ! grep -s -q "src-git $1" feeds.conf.default; then
            echo "src-git $1 $2" >>feeds.conf.default
        fi
        shift 2
    done
}
```
