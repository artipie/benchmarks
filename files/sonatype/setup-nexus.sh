#!/bin/bash
read -r admin_password < /home/ubuntu/nexus-data/admin.password
curl -u admin:"${admin_password}" -X POST \
  -d @upload/sonatype/create-repo.json \
  -H 'Content-Type: application/json' \
  http://localhost/service/rest/v1/script
curl -u admin:"${admin_password}" -X POST \
  -H 'Content-Type: text/plain' \
  http://localhost/service/rest/v1/script/create-repo/run
curl -u admin:"${admin_password}" -X DELETE http://localhost/service/rest/v1/script/create-repo

. upload/sonatype/credentials
if [ "${username}" = 'admin' ]
then
  curl -u admin:"${admin_password}" -X POST \
    -d "{\"name\": \"set-admin-password\", \"type\": \"groovy\", \"content\": \"security.securitySystem.changePassword('admin', '${password}')\"}" \
    -H 'Content-Type: application/json' \
    http://localhost/service/rest/v1/script
  curl -u admin:"${admin_password}" -X POST \
    -H 'Content-Type: text/plain' \
    http://localhost/service/rest/v1/script/set-admin-password/run
  curl -u admin:"${password}" -X DELETE http://localhost/service/rest/v1/script/set-admin-password
else
  curl -u admin:"${admin_password}" -X POST \
    -d "{\"name\": \"add-user\", \"type\": \"groovy\", \"content\": \"security.addUser('${username}', '', '', '', true, '${password}', ['nx-admin'])\"}" \
    -H 'Content-Type: application/json' \
    http://localhost/service/rest/v1/script
  curl -u admin:"${admin_password}" -X POST \
    -H 'Content-Type: text/plain' \
    http://localhost/service/rest/v1/script/add-user/run
  curl -u admin:"${admin_password}" -X DELETE http://localhost/service/rest/v1/script/add-user
fi

