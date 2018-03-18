#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Cleaning workspace"
[[ -d apis/ ]] && rm -rf apis/
mkdir apis/

echo "Fetching API"
endpoints=$(curl -s "https://api.mendeley.com/apidocs/apis" | python -c 'import sys, json; print "\n".join(list(map(lambda ep: ep["path"], json.load(sys.stdin)["apis"])));' | sort)

for endpoint in $endpoints;
  do
    echo "Endpoint: $endpoint"
    endpoint="$(echo $endpoint | sed 's|^/||')"
    file="$(echo $endpoint | sed 's|/|_|g').json"
    curl -s "https://api.mendeley.com/apidocs/apis/$endpoint" | python -m json.tool > "apis/$file"
done

echo "Recording changes"

git add apis/
git commit -m "API changes for: $(date)"

echo "Pushing changes"
git push

echo "Done."

