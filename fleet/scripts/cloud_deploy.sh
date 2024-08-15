#! /bin/sh

cd /Users/ksatter/fleet/confidential/infrastructure/cloud

changes=$(git status --porcelain | sed -e '/shared/D' | xargs dirname | xargs basename |  sed -e '/\./D' -e '/cloud/D' | uniq | jq -R -s -c 'split("\n")[:-1]' )


echo "Generated array: $changes"

echo $changes  > cloud-deploy.json

# git add . 
# git commit -m "generate cloud.json"


