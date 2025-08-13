FROM    archlinux:latest
ARG     USERNAME=dev
ARG     USER_UID=1000
ARG     USER_GID=$USER_UID

ENV     RUSTUP_HOME=/usr/local/rustup \
        CARGO_HOME=/usr/local/cargo \
        PATH=/usr/local/cargo/bin:$PATH

RUN     pacman-key --init \
        && pacman-key --populate archlinux \
        && pacman -Syu --noconfirm \
        && pacman -S --noconfirm         emacs \
        base-devel git sudo curl wget unzip ripgrep fd \
        zathura poppler libnotify fontconfig \
        go jdk-openjdk python python-pip php lua \
        nodejs npm \
        tectonic \
        bash fish \
        && pacman -Scc --noconfirm \
        && rm -rf /var/cache/pacman/pkg/*

RUN     curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
        && . "/usr/local/cargo/env" \
        && cargo install emacs-lsp-booster \
        && curl -LsSf https://astral.sh/uv/install.sh | sh \
        && mv /root/.local/bin/uv /usr/local/bin/uv \
        && mv /root/.local/bin/uvx /usr/local/bin/uvx

RUN     mkdir -p /tmp/fonts \
        && cd /tmp/fonts \
        && curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip \
        && unzip Terminus.zip -d /usr/share/fonts/terminess-nerd-font \
        && fc-cache -fv \
        && rm -rf /tmp/fonts

RUN     groupadd --gid $USER_GID $USERNAME \
        && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME --shell /bin/bash \
        && usermod -aG wheel $USERNAME \
        && echo "%wheel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER    $USERNAME
WORKDIR /home/$USERNAME

ENV     PATH="/home/$USERNAME/.config/emacs/bin:$PATH"

RUN     git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

COPY    doom    /home/$USERNAME/.config/doom

RUN     /home/$USERNAME/.config/emacs/bin/doom install --env \
        && /home/$USERNAME/.config/emacs/bin/doom sync

CMD     ["emacs"]
