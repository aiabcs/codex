FROM node:22-slim

ARG TZ
ENV TZ="$TZ"

# Install basic development tools, ca-certificates, and iptables/ipset, then clean up apt cache to reduce image size
# also install Python 3 and pip for potential Python-based tasks
RUN apt-get update && apt-get install -y --no-install-recommends \
  aggregate \
  ca-certificates \
  curl \
  dnsutils \
  fzf \
  gh \
  git \
  gnupg2 \
  iproute2 \
  ipset \
  iptables \
  jq \
  less \
  man-db \
  procps \
  unzip \
  ripgrep \
  zsh \
  python3 \
  python3-pip \
  python3-venv \
  python3-setuptools \
  python3-wheel \
  iputils-ping \
  && rm -rf /var/lib/apt/lists/*

# Install .NET SDK 8
RUN curl -sSL https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm packages-microsoft-prod.deb && \
  apt-get update && \
  apt-get install -y --no-install-recommends dotnet-sdk-8.0 && \
  rm -rf /var/lib/apt/lists/*

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Install codex
COPY dist/codex.tgz codex.tgz
RUN npm install -g codex.tgz \
  && npm cache clean --force \
  && rm -rf /usr/local/share/npm-global/lib/node_modules/codex-cli/node_modules/.cache \
  && rm -rf /usr/local/share/npm-global/lib/node_modules/codex-cli/tests \
  && rm -rf /usr/local/share/npm-global/lib/node_modules/codex-cli/docs

# Copy config file
COPY config/.codex/config.json /home/node/.codex/config.json

# Inside the container we consider the environment already sufficiently locked
# down, therefore instruct Codex CLI to allow running without sandboxing.
ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1

# Copy and set up firewall script as root.
USER root
COPY scripts/init_firewall.sh /usr/local/bin/
RUN chmod 500 /usr/local/bin/init_firewall.sh

# set permissions
RUN chown -R node:node /usr/local/share/npm-global

# Drop back to non-root.
USER node

# set permissions for the Codex binary
#RUN ls -la /usr/local/share/npm-global/lib/node_modules/@openai/codex/bin
RUN chmod +x /usr/local/share/npm-global/lib/node_modules/@openai/codex/bin/codex-linux-sandbox-x64
