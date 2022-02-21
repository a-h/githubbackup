# githubbackup

A Docker image for backing up Github repositories.

## Usage

```
name: Backup

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * *'

jobs:
  Backup:
    runs-on: ubuntu-latest
    container: ghcr.io/a-h/githubbackup:main
    name: Backup

    steps:
      - uses: actions/checkout@v2

      - name: Download
        shell: bash
        run: download-organisation-code
      
      - name: Assume role
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-backup-role
          aws-region: eu-west-1

      - name: Display assumed role
        run: aws sts get-caller-identity

      #TODO: Upload the code to S3.
```

## Tasks

### build

```sh
docker build --progress=plain -t githubbackup:latest .
```

### shell

```sh
docker run -it --rm --entrypoint "/bin/bash" githubbackup:latest
```
