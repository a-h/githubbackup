#!/bin/bash
echo "Logging in"
# Log in with the provided Github personal access token.
gh auth login --with-token <<< "$BACKUP_GITHUB_PAT"
# Use this token to download all the files.
gh repo list $GITHUB_REPOSITORY_OWNER --json "name" --template '{{range .}}{{ .name }}{{"\n"}}{{end}}' | xargs -L1 -I {} gh repo clone "${GITHUB_REPOSITORY_OWNER}/{}"
echo "Downloaded repositories..."
find  . -maxdepth 1 -type d
# Upload to S3.
aws s3 sync --region=$BACKUP_AWS_REGION --size-only . s3://$BACKUP_BUCKET_NAME
