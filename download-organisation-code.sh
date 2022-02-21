#!/bin/bash
echo "Logging in"
# Log in with the provided Github personal access token.
gh auth login --with-token <<< "$GITHUB_PAT"
# Use this token to download all the files.
gh repo list $GITHUB_REPOSITORY_OWNER --json "name" --template '{{range .}}{{ .name }}{{"\n"}}{{end}}' | xargs -L1 -I {} gh repo clone "${GITHUB_REPOSITORY_OWNER}/{}"
echo "Downloaded repositories..."
find  . -maxdepth 1 -type d
#TODO: Upload to S3.
