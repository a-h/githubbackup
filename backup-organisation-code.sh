#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
#set -euxo pipefail

echo "Logging in with personal access token."
export GH_TOKEN=$BACKUP_GITHUB_PAT
gh auth setup-git

echo "Downloading repositories for" $BACKUP_GITHUB_OWNER
#gh repo list $BACKUP_GITHUB_OWNER --json "name" --limit 1000 --template '{{range .}}{{ .name }}{{"\n"}}{{end}}' | xargs -L1 -I {} gh repo clone --mirror $BACKUP_GITHUB_OWNER/{} .git | git config --bool core.bare false | git reset -hard
gh repo list $BACKUP_GITHUB_OWNER --json "name" --limit 1000 --template '{{range .}}{{ .name }}{{"\n"}}{{end}}' | xargs -L1 -I {} git clone --mirror https://${BACKUP_GITHUB_OWNER}:{BACKUP_GITHUB_PAT}@github.com/$BACKUP_GITHUB_OWNER/{} 
for f in *; do mkdir -p $f/.git ; done

echo "Downloaded repositories..."
find  . -maxdepth 1 -type d

echo "Uploading to S3 bucket" $BACKUP_BUCKET_NAME "in region" $BACKUP_AWS_REGION
aws s3 sync --region=$BACKUP_AWS_REGION . s3://$BACKUP_BUCKET_NAME/github.com/$BACKUP_GITHUB_OWNER/`date "+%Y-%m-%d"`/

echo $?

echo "Complete."

#aws s3 cp s3://$BACKUP_BUCKET_NAME/github.com/$BACKUP_GITHUB_OWNER/`date "+%Y-%m-%d"`/ . --recursive

repository_name_list="$(gh repo list $BACKUP_GITHUB_OWNER --json "name" --limit 1000 --template '{{range .}}{{ .name }}{{"\n"}}{{end}}')"
echo $repository_name_list
for output_repo_list in $repository_name_list
 do
    git config --global --add safe.directory /github/workspace
    git config --global credential.'https://git-codecommit.*.amazonaws.com'.helper '!aws codecommit credential-helper $@'
    git config --global credential.helper '!aws codecommit credential-helper $@'
    git config --global credential.UseHttpPath true
    output_json="$(aws codecommit get-repository --repository-name "$BACKUP_GITHUB_OWNER"-"$output_repo_list")"
    echo $output_json | grep "RepositoryDoesNotExistException"
      if [ $? -ne '0' ];
         then
          output_json="$(aws codecommit create-repository --repository-name "$BACKUP_GITHUB_OWNER"-"$output_repo_list" --repository-description "$output_repo_list")"
         fi;
     echo $output_json
       if [ $? -ne '0' ];
         then
          echo "Could not create repository $repository_name"
          exit 1
         fi;
        output_json="$(aws codecommit get-repository --repository-name "$BACKUP_GITHUB_OWNER"-"$output_repo_list")"
        clone_url="$(echo "$output_json" | python3 -c "import sys, json; print(json.load(sys.stdin)['repositoryMetadata']['cloneUrlHttp'])")"
	echo $clone_url
        clone_repository_name="$(echo "$output_json" | python3 -c "import sys, json; print(json.load(sys.stdin)['repositoryMetadata']['repositoryDescription'])")"
        echo $clone_repository_name
        cd $clone_repository_name
	    git remote add sync $clone_url
        git push sync --mirror
	cd ..
done
