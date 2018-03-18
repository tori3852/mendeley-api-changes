#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Cleaning workspace"
[[ -d apis/ ]] && rm -rf apis/
mkdir apis/

echo "Fetching API"
endpoints=$(curl -s "https://api.mendeley.com/apidocs/apis" | jq -r '.apis[].path' | sort)

for endpoint in $endpoints;
  do
    echo "Endpoint: $endpoint"
    endpoint="$(echo $endpoint | sed 's|^/||')"
    file="$(echo $endpoint | sed 's|/|_|g').json"
    curl -s "https://api.mendeley.com/apidocs/apis/$endpoint" | jq -S . > "apis/$file"
done

echo "Recording changes"

git add apis/
git commit -m "API changes for: $(date)"

echo "Pushing changes"
git push

echo "Done."

