FROM mcr.microsoft.com/devcontainers/universal:5.1.5-noble

USER root

# 1. Install Ubuntu's native namespace translation & networking dependencies
RUN apt-get update && apt-get install -y \
    uidmap \
    fuse3 \
    iptables \
    && rm -rf /var/lib/apt/lists/*

# 2. Download the latest Podman 5 static bundle
RUN curl -fsSL -o podman-linux-amd64.tar.gz https://github.com/mgoltzsche/podman-static/releases/latest/download/podman-linux-amd64.tar.gz

# 3. Extract and distribute binaries into the system root path, then clean up tarball
RUN tar -xzf podman-linux-amd64.tar.gz \
    && cp -r podman-linux-amd64/usr podman-linux-amd64/etc / \
    && rm -rf podman-linux-amd64 podman-linux-amd64.tar.gz

# 4. Create the config directory
RUN mkdir -p /home/vscode/.config/containers

# 5. Populate storage configuration
RUN echo '[storage]' > /home/vscode/.config/containers/storage.conf
RUN echo 'driver = "vfs"' >> /home/vscode/.config/containers/storage.conf

# 6. Populate container network configuration
RUN echo '[containers]' > /home/vscode/.config/containers/containers.conf
RUN echo 'netns = "pasta"' >> /home/vscode/.config/containers/containers.conf

# 7. Apply proper file ownership to the 'vscode' user
RUN chown -R vscode:vscode /home/vscode/.config/containers

USER vscode
