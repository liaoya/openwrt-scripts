# Ubuntu for VPS

```bash
hostnamectl set-hostname <>
timedatectl set-timezone UTC
# Make sudo work without warning
echo $(hostname -I) $(hostname)  | tee -a /etc/hosts

apt update -qq -y
# apt upgrade -qq -y -o "Dpkg::Use-Pty=0"
apt install -qq -y -o "Dpkg::Use-Pty=0" software-properties-common # for ppa

export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=yes
export DEBIAN_FRONTEND=noninteractive
VERSION=$(echo "$(lsb_release -r | cut -d':' -f2 | tr -d '[:space:]') * 100 / 1" | bc)

UBUNTU_MIRROR_SERVER=http://ftp.ucsb.edu
UBUNTU_MIRROR_PATH=/pub/mirrors/linux/ubuntu
[[ -f /etc/apt/sources.list.save ]] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.save
[[ -f /etc/apt/sources.list.save ]] && cp -pr /etc/apt/sources.list.save /etc/apt/sources.list
sed -i -e "s%http://.*archive.ubuntu.com%$UBUNTU_MIRROR_SERVER$UBUNTU_MIRROR_PATH%" \
    -e "s%http://security.ubuntu.com%$UBUNTU_MIRROR_SERVER$UBUNTU_MIRROR_PATH%" /etc/apt/sources.list
sed -i -e 's/^deb-src/#deb-src/' /etc/apt/sources.list

declare -a ppa_repos
if [[ ${VERSION} -eq 1804 ]]; then
    # ppa:deadsnakes/ppa for various python
    # ppa:git-core/ppa, now ppa:savoury1/backports has latest git
    ppa_repos+=(ppa:savoury1/backports)
    ppa_repos+=(ppa:apt-fast/stable ppa:codeblocks-devs/release ppa:deadsnakes/ppa ppa:kelleyk/emacs ppa:fish-shell/release-3
        ppa:lazygit-team/release
        ppa:kimura-o/ppa-tig ppa:pypy/ppa ppa:unilogicbv/shellcheck
        ppa:jonathonf/vim ppa:rmescandon/yq)
    for ppa in "${ppa_repos[@]}"; do add-apt-repository -y "$ppa"; done
elif [[ ${VERSION} -eq 2004 ]]; then
    # ppa:deadsnakes/ppa for various python
    # ppa:git-core/ppa, now ppa:savoury1/backports has latest git
    # ppa:mtvoid/ppa for emacs27
    # ppa:mjuhasz/backports for tmux 3.1b
    ppa_repos+=(ppa:savoury1/backports)
    ppa_repos+=(ppa:fish-shell/release-3 ppa:jonathonf/vim ppa:kelebek333/xfce-4.16 ppa:mjuhasz/backports)
    for ppa in "${ppa_repos[@]}"; do add-apt-repository -y "$ppa"; done
fi
apt update -qq -y
apt upgrade -q -y

apt install -qq -y -o "Dpkg::Use-Pty=0" certbot curl docker.io dos2unix fish git gnupg jq moreutils nmon nano sshpass tig tmux vim
apt install -qq -y python3-distutils

mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# https://unix.stackexchange.com/questions/130786/can-i-remove-files-in-var-log-journal-and-var-cache-abrt-di-usr
echo "SystemMaxUse=100M" | sudo tee -a /etc/systemd/journald.conf
sudo systemctl daemon-reload
sudo systemctl restart systemd-journald.service
sudo journalctl --disk-usage

ufw default deny incoming
ufw default allow outgoing

ufw allow ssh
ufw status
# Make sure ssh is allowed
ufw enable
ufw status

# create normal user
SUDO_USER=
useradd -g users -s /bin/bash -m "$SUDO_USER"
echo "$(id -un $SUDO_USER) ALL=(ALL) NOPASSWD: ALL" | tee "/etc/sudoers.d/$(id -un $SUDO_USER)"
SUDO_USER_DIR=$(getent passwd "$SUDO_USER" | cut -d: -f6)
mkdir "$SUDO_USER_DIR/.ssh"
touch "$SUDO_USER_DIR/.ssh/authorized_keys"
chown -R "$(id -u $SUDO_USER):$(id -g $SUDO_USER)" "$SUDO_USER_DIR/.ssh"
chmod 700 "$SUDO_USER_DIR/.ssh"
chmod 600 "$SUDO_USER_DIR/.ssh/authorized_keys"
getent group docker && usermod -aG docker "${SUDO_USER}"
```

## Enable BBR in 18.04

```bash
if grep -q "tcp_bbr" "/etc/modules-load.d/modules.conf"; then
    echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
fi
modprobe tcp_bbr

SYSCTL_FILE=/etc/sysctl.d/90-tcp-bbr.conf
echo "Current configuration: "
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control

# apply new config
if ! grep -q "net.core.default_qdisc = fq" "$SYSCTL_FILE"; then
    echo "net.core.default_qdisc = fq" >> $SYSCTL_FILE
fi
if ! grep -q "net.ipv4.tcp_congestion_control = bbr" "$SYSCTL_FILE"; then
    echo "net.ipv4.tcp_congestion_control = bbr" >> $SYSCTL_FILE
fi

# check if we can apply the config now
if lsmod | grep -q "tcp_bbr"; then
    sysctl -p $SYSCTL_FILE
    echo "BBR is available now."
elif modprobe tcp_bbr; then
    sysctl -p $SYSCTL_FILE
    echo "BBR is available now."
else
    echo "Please reboot to enable BBR."
fi
```

## Enable fastopen in 18.04

```bash
SYSCTL_FILE=/etc/sysctl.d/90-tcp-fastopen.conf
touch "${SYSCTL_FILE}"
sed -i '/net\.ipv4\.tcp_fastopen/d' /etc/sysctl.conf
sed -i '/net\.ipv4\.tcp_fastopen/d' "${SYSCTL_FILE}"
echo "net.ipv4.tcp_fastopen = 3" > "${SYSCTL_FILE}"
```

## Run with normal user

```bash
sed -i -e "/# set PATH so it includes user's private bin if it exists/,+4d" ~/.profile
cat <<'EOF' | tee -a ~/.profile
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] && ! test "${PATH#*$HOME/bin}" != "$PATH"; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] && ! test "${PATH#*"$HOME"/.local/bin}" != "$PATH"; then
    PATH="$HOME/.local/bin:$PATH"
fi
EOF

mkdir -p ~/.bashrc.d ~/.bash_completion.d ~/.local/bin ~/Downloads ~/Documents
cat <<'EOF' | tee -a ~/.bashrc
[ -d ~/.bashrc.d ] && for _script in ~/.bashrc.d/*.sh; do [ -f "${_script}" ] && source "${_script}"; done
[ -d ~/.bash_completion.d ] && for _script in ~/.bash_completion.d/*.sh; do [ -f "${_script}" ] && source "${_script}"; done
EOF

if ! grep -s -q "^pathmunge () {" "${HOME}/.bashrc"; then
    cat <<'EOF' >> ~/.bashrc
pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
        ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}
#[[ -d "${HOME}/.local/bin" ]] &&  pathmunge "${HOME}/.local/bin"
pathmunge /sbin
EOF
    [[ -d "${HOME}/.local/bin" ]] || mkdir -p "${HOME}/.local/bin"
    source ~/.bashrc
fi

cat <<'EOF' > "${HOME}/.tmux.conf"
set -g buffer-limit 10000
set -g default-shell /usr/bin/fish
set -g history-limit 5000
set -g renumber-windows on
EOF
```

### Setup ntp

```bash
sudo apt install -q -y chrony ntpdate
sudo sed -i 's/^pool /# pool/g' /etc/chrony/chrony.conf
echo 'server 0.us.pool.ntp.org iburst maxsources 4' | sudo tee -a /etc/chrony/chrony.conf
echo 'server 1.us.pool.ntp.org iburst maxsources 4' | sudo tee -a /etc/chrony/chrony.conf
echo 'server 2.us.pool.ntp.org iburst maxsources 4' | sudo tee -a /etc/chrony/chrony.conf
echo 'server 3.us.pool.ntp.org iburst maxsources 4' | sudo tee -a /etc/chrony/chrony.conf
sudo ntpdate -u 0.us.pool.ntp.org
sudo systemctl enable chrony
sudo systemctl start chrony
```

### Install powerline

```bash
curl -sL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
PYTHON_EXEC=$(find /usr/bin -type f -iname "python*" | grep -v "m$" | grep -v '-' | sort | tail -1)
eval "${PYTHON_EXEC}" /tmp/get-pip.py --user
pip install --user --upgrade powerline-status powerline-shell

mkdir -p ~/.config/powerline-shell && powerline-shell --generate-config > ~/.config/powerline-shell/config.json
if [[ $(command -v jq) && $(command -v sponge) ]]; then
    jq 'del(.segments[1]) | del(.segments[2])' ~/.config/powerline-shell/config.json | sponge ~/.config/powerline-shell/config.json
    jq '.=.+{"vcs":{"show_symbol": true}}' ~/.config/powerline-shell/config.json | sponge ~/.config/powerline-shell/config.json
    jq '.=.+{"cwd":{"max_depth":1,"max_dir_size":2,"full_cwd":true}}' ~/.config/powerline-shell/config.json | sponge ~/.config/powerline-shell/config.json
#    jq '.=.+{"hostname":{"colorize":true}}' ~/.config/powerline-shell/config.json | sponge ~/.config/powerline-shell/config.json
fi
cat <<'EOF' >>~/.bashrc
function _update_ps1() {
    [[ $(command -v powerline-shell) ]] && PS1=$(powerline-shell $?)
}
if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
EOF
[[ -d ~/.config/fish ]] || mkdir -p ~/.config/fish
cat <<'EOF' >>~/.config/fish/config.fish
function fish_prompt
    powerline-shell --shell bare $status
end
EOF

tmuxfile=$(find ~/.local/lib -iname powerline.conf)
touch ~/.tmux.conf
sed -i "/tmux\\/powerline\\.conf/d" ~/.tmux.conf
if [[ -z $(tail -1 ~/.tmux.conf | tr -s "[:blank:]") ]]; then
    echo "source $tmuxfile" >> ~/.tmux.conf
else
    echo -e "\\nsource $tmuxfile" >> ~/.tmux.conf
fi

vimfolder=$(find ~/.local/lib -iname vim | grep powerline | grep bindings)
cat <<EOF >> ~/.vimrc
set rtp+=$vimfolder
set laststatus=2
set paste
set t_Co=256
EOF

if [[ $(command -v git) ]]; then
    [[ -d ~/.emacs.d/vendor ]] || mkdir -p ~/.emacs.d/vendor
    (cd ~/.emacs.d/vendor; git clone https://github.com/milkypostman/powerline.git)
    cat <<EOF >> ~/.emacs
(add-to-list 'load-path "~/.emacs.d/vendor/powerline")
(require 'powerline)
(powerline-default-theme)
EOF
fi
```

### Install some tools with pip

```bash
pip install --user --upgrade docker-compose httpie ipython yq
```

## Reference

- <https://gist.github.com/Jamesits/3d6da2d711bd95c53ccd953f99aee748>
