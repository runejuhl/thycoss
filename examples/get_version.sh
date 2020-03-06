#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../thycoss.sh
. "$(dirname "$(realpath -e "${BASH_SOURCE[0]}")")/../thycoss.sh"

 _curl_form get '/api/v1/version'
