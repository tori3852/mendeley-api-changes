#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

main_dir="$(dirname "$(realpath "$0")")"

echo "Adding key"
export KEY_FILE="$main_dir/.private"
echo "$PRIVATE_KEY" > $KEY_FILE
export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $KEY_FILE"
ls -la $KEY_FILE

echo "Cleaning workspace"
[[ -d mendeley-api-changes/ ]] && rm -rf mendeley-api-changes/
git clone git@github.com:tori3852/mendeley-api-changes.git
[[ -d mendeley-api-changes/apis/ ]] && rm -rf mendeley-api-changes/apis/
mkdir mendeley-api-changes/apis/

echo "Fetching API"
endpoints=$(curl -s "https://api.mendeley.com/apidocs/apis" | $main_dir/bin/jq -rS '.apis[].path')

for endpoint in $endpoints;
  do
    echo "Endpoint: $endpoint"
    endpoint="$(echo $endpoint | sed 's|^/||')"
    file="$(echo $endpoint | sed 's|/|_|g').json"
    curl -s "https://api.mendeley.com/apidocs/apis/$endpoint" | $main_dir/bin/jq -S '.' > "mendeley-api-changes/apis/$file"
done

echo "Recording changes"

git -C mendeley-api-changes/ add apis/
git -C mendeley-api-changes/ -c user.name=heroku -c user.email=heroku commit -m "API changes for: $(date)"

echo "Pushing changes"
git -C mendeley-api-changes/ push

echo "Done."

