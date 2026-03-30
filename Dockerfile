FROM node:22.11-bookworm

# git, gh CLI のインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      curl \
      ca-certificates \
      jq && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# pnpm のインストール
RUN npm install -g pnpm

# Claude Code のインストール（公式ネイティブインストーラー）
# node ユーザーで実行するため先にユーザー切り替え
USER node
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/node/.local/bin:${PATH}"

WORKDIR /workspace

COPY --chown=node:node docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["claude"]
