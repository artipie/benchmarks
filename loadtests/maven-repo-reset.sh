#!/bin/bash
if [ $# -lt 1 ]; then 
    echo "Usage: $0 artipie_host [api_port] [repo]" && exit 1
fi
host="$1"
apiPort="${2:-8086}"
repo="${3:-maventest}"

login=chgen
pass=chgen

token=$(curl -X 'POST' "http://$host:$apiPort/api/v1/oauth/token" -H 'accept: application/json' -H 'Content-Type: application/json' \
-d "{ \"name\": \"$login\", \"pass\": \"$pass\" }" 2>/dev/null|jq -r .token)

curl -X 'DELETE' "http://$host:$apiPort/api/v1/repository/$repo" -H 'accept: application/json' -H "Authorization: Bearer $token" 2>/dev/null

sleep 1 #Error: Repository chgen/maventest does not exist.

curl -X 'PUT' \
  "http://$host:$apiPort/api/v1/repository/$repo" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $token" \
  -H 'Content-Type: application/json' \
  -d '{
    "repo": {
    "type": "maven",
    "storage": "default",
    "permissions": {
      "*": [
        "download",
        "upload"
      ]
    }
  }
}'

curl -X 'GET' "http://$host:$apiPort/api/v1/repository/$repo" -H 'accept: application/json' -H "Authorization: Bearer $token"

echo -e '\n'
