#!/bin/bash

echo "Logging in with personal access token."
export GH_TOKEN=$BACKUP_GITHUB_PAT
gh auth setup-git

echo "Downloading repositories."
gh repo list $BACKUP_GITHUB_OWNER --json "name" --template '{{range .}}{{ .name }}{{"\n"}}{{end}}' | xargs -L1 -I {} gh repo clone $BACKUP_GITHUB_OWNER/{}

echo "Downloaded repositories..."
find  . -maxdepth 1 -type d

echo "Uploading to S3..."
aws s3 sync --region=$BACKUP_AWS_REGION . s3://$BACKUP_BUCKET_NAME/github.com/$BACKUP_GITHUB_OWNER/`date "+%Y-%m-%d"`/

echo "Complete."
