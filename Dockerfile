FROM mcr.microsoft.com/devcontainers/base:2.1.7-ubuntu24.04

USER root

# 1. Install Ubuntu's native namespace translation & networking dependencies
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y uidmap fuse3 iptables
RUN apt-get install -y conmon
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/cache/apt/archives/*

# 2. Download the latest Podman 5 static bundle
RUN curl -fsSL -o podman-linux-amd64.tar.gz https://github.com/mgoltzsche/podman-static/releases/latest/download/podman-linux-amd64.tar.gz

# 3. Extract and distribute binaries into the system root path, then clean up tarball
RUN tar -xzf podman-linux-amd64.tar.gz \
    && cp -r podman-linux-amd64/usr podman-linux-amd64/etc / \
    && rm -rf podman-linux-amd64 podman-linux-amd64.tar.gz

RUN rm -f /usr/local/bin/crun
RUN curl -fsSL -o /usr/local/bin/crun https://github.com/containers/crun/releases/download/1.28/crun-1.28-linux-amd64
RUN chmod +x /usr/local/bin/crun

RUN chmod 0755 /usr/bin/newuidmap /usr/bin/newgidmap
RUN setcap cap_setuid=ep /usr/bin/newuidmap
RUN setcap cap_setgid=ep /usr/bin/newgidmap

# 4. Create the config directory
RUN mkdir -p /home/vscode/.config/containers

# 5. Populate storage configuration
RUN echo '[storage]' > /home/vscode/.config/containers/storage.conf
RUN echo 'driver = "overlay"' >> /home/vscode/.config/containers/storage.conf

# 6. Populate container network configuration
RUN echo '[containers]' > /home/vscode/.config/containers/containers.conf
RUN echo 'netns = "host"' >> /home/vscode/.config/containers/containers.conf
RUN echo 'userns = "host"' >> /home/vscode/.config/containers/containers.conf
RUN echo 'ipcns = "host"' >> /home/vscode/.config/containers/containers.conf
RUN echo 'utsns = "host"' >> /home/vscode/.config/containers/containers.conf
RUN echo 'cgroupns = "host"' >> /home/vscode/.config/containers/containers.conf
RUN echo 'cgroups = "disabled"' >> /home/vscode/.config/containers/containers.conf
RUN echo 'volumes = ["/proc:/proc"]' >> /home/vscode/.config/containers/containers.conf
RUN echo '[engine]' >> /home/vscode/.config/containers/containers.conf
RUN echo 'runtime = "/usr/local/bin/crun"' >> /home/vscode/.config/containers/containers.conf

# 7. Apply proper file ownership to the 'vscode' user
RUN chown -R vscode:vscode /home/vscode/.config/containers

USER vscode

VOLUME /home/vscode/.local/share/containers/storage
VOLUME /var/lib/containers
