# githubbackup

A Docker image for backing up Github repositories.

## Usage

```yaml
name: Backup

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * *'

permissions:
  id-token: write
  contents: read

      # Needs secrets:
      # BACKUP_GITHUB_PAT
      # BACKUP_GITHUB_OWNER
      # BACKUP_AWS_ROLE
      # BACKUP_AWS_REGION
      # BACKUP_BUCKET_NAME

jobs:
  Backup:
    runs-on: ubuntu-latest
    container: ghcr.io/dms-jovan-stanoevski/githubbackup:main
    name: Backup

    steps:
      - name: Assume role
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: ${{ secrets.BACKUP_AWS_ROLE }}
          aws-region: ${{ secrets.BACKUP_AWS_REGION }}

      - name: Display assumed role
        run: aws sts get-caller-identity

      - name: Backup
        shell: bash
        env:
          BACKUP_GITHUB_PAT: ${{ secrets.BACKUP_GITHUB_PAT }}
          BACKUP_GITHUB_OWNER: ${{ secrets.BACKUP_GITHUB_OWNER }}
          BACKUP_AWS_REGION: ${{ secrets.BACKUP_AWS_REGION }}
          BACKUP_BUCKET_NAME: ${{ secrets.BACKUP_BUCKET_NAME }}
        run: backup-organisation-code
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

### run-locally

```sh
docker run -e BACKUP_GITHUB_PAT -e BACKUP_AWS_ROLE -e BACKUP_AWS_REGION -e BACKUP_BUCKET_NAME githubbackup:latest backup-organisation-code
```
