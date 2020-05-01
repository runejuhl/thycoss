#!/usr/bin/env bash
#
# Create a new secret

set -euo pipefail

# shellcheck source=../thycoss.sh
. "$(dirname "$(realpath -e "${BASH_SOURCE[0]}")")/../thycoss.sh"

folder_id=71
user=root
hostname=someserver.contoso.com
_curl_form post '/api/v1/secrets' <<EOF
{
  "name": "${user}@${hostname}",
  "secretTemplateId": 6007,
  "folderId": ${folder_id},
  "siteId": 1,
  "checkOutEnabled": false,
  "autoChangeEnabled": false,
  "enableInheritPermissions": true,
  "enableInheritSecretPolicy": true,
  "items": [
   {
      "itemValue": "${hostname}",
      "fieldId": 108,
      "fieldName": "Machine",
      "slug": "machine",
      "fieldDescription": "The Server or Location of the Unix Machine.",
      "isFile": false,
      "isNotes": false,
      "isPassword": false
    },
    {
      "itemValue": "${user}",
      "fieldId": 111,
      "fieldName": "Username",
      "slug": "username",
      "fieldDescription": "The Unix Machine Username.",
      "isFile": false,
      "isNotes": false,
      "isPassword": false
    },
    {
      "itemValue": "this here be real secret",
      "fieldId": 110,
      "fieldName": "Password",
      "slug": "password",
      "fieldDescription": "The password of the Unix Machine.",
      "isFile": false,
      "isNotes": false,
      "isPassword": true
    }
  ]
}
EOF
