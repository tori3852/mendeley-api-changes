#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Adding key"
echo "$PRIVATE_KEY" > .private
export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .private"

echo "Cleaning workspace"
[[ -d mendeley-api-changes/ ]] && rm -rf mendeley-api-changes/
git clone git@github.com:tori3852/mendeley-api-changes.git
[[ -d mendeley-api-changes/apis/ ]] && rm -rf mendeley-api-changes/apis/
mkdir mendeley-api-changes/apis/

echo "Fetching API"
endpoints=$(curl -s "https://api.mendeley.com/apidocs/apis" | python -c 'import sys, json; print "\n".join(list(map(lambda ep: ep["path"], json.load(sys.stdin)["apis"])));' | sort)

for endpoint in $endpoints;
  do
    echo "Endpoint: $endpoint"
    endpoint="$(echo $endpoint | sed 's|^/||')"
    file="$(echo $endpoint | sed 's|/|_|g').json"
    curl -s "https://api.mendeley.com/apidocs/apis/$endpoint" | python -m json.tool > "mendeley-api-changes/apis/$file"
done

echo "Recording changes"

git -C mendeley-api-changes/ add apis/
git -C mendeley-api-changes/ commit -m "API changes for: $(date)"

echo "Pushing changes"
git -C mendeley-api-changes/ push

echo "Done."

