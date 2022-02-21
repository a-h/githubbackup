FROM ubuntu:latest AS downloads

RUN apt-get update && \
    apt-get -y install curl unzip

# https://explainshell.com/explain?cmd=curl+-fsSLO+example.org
WORKDIR /downloads
RUN curl -fsSLO https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.4.14.zip

# Create a sum of all files.
RUN find . -type f -exec sha256sum {} \; >> /downloads/current_hashes.txt
RUN cat /downloads/current_hashes.txt

# Compare to past hashes.
COPY past_hashes.txt /downloads
RUN sha256sum -c past_hashes.txt

# Install AWS CLI.
RUN mkdir -p /tmp && \
    unzip /downloads/awscli-exe-linux-x86_64-2.4.14.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws

# Install Github CLI.
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && \
    apt-get -y install gh

COPY backup-organisation-code.sh /usr/bin/backup-organisation-code
WORKDIR /src
