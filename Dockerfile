# ParrotOS Security Edition browser terminal for Railway, wrapped so the deploy
# form carries no blank required fields and the home directory survives a
# redeploy.
FROM parrotsec/security@sha256:2fe6606fed814618a6bc91a07f193a5b6aa9660b774fc319e6c8fd4b569e2f06

ENV DEBIAN_FRONTEND=noninteractive

# Small additions on top of the Parrot security toolset: the utilities a browser
# shell is unusable without, and tini so ttyd's children are reaped.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget git vim nano less tmux jq unzip zip \
        procps htop tini && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ttyd pinned. The incumbent downloads .../releases/latest/... at build time, so
# two deploys of the same template can ship different terminals.
RUN mkdir -p /usr/local/bin && \
    wget -qO /usr/local/bin/ttyd \
        https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# USERNAME baked so it is not a blank required template variable. A user-set
# value still wins (the entrypoint reads $USERNAME).
ENV USERNAME=admin

# A pristine copy of the home skeleton. A Railway volume mounted at /root hides
# whatever the image wrote there, so the entrypoint restores anything missing.
RUN printf '%s\n' \
        "cd /root" \
    >> /root/.bashrc && \
    cp -a /root /opt/root-skel

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

EXPOSE 7681
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/railway-entrypoint.sh"]
