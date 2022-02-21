gh repo list $GITHUB_REPOSITORY_OWNER --json "name" --template '{{range .}}{{ .name }}{{"\n"}}{{end}}' | xargs -L1 -I {} bash -c 'if [ -d "{}" ]; then echo "{} already exists"; else gh repo clone "${GITHUB_REPOSITORY_OWNER}/{}"; fi'
find . -type d -depth 1 -exec git --git-dir={}/.git --work-tree=$PWD/{} pull origin main \;
