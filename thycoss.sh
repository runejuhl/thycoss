#!/usr/bin/env bash
#
# See
# https://secretserver.contoso.com/SecretServer/Documents/restapi/TokenAuth/
# for API documentation.

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
THYCOSS_PROFILE="${THYCOSS_PROFILE:-default}"

declare -x BASEURL USERNAME PASS_PATH DOMAIN TOKEN
declare -ax CURL_DEFAULT_ARGS=( '--silent' )

function _curl_form() {
  declare method="${1^^}" \
          endpoint="${2}"
  shift 2

  declare -a curl_args=( "${CURL_DEFAULT_ARGS[@]}" )

  case "${method}" in
    GET)
      if (( "${#}" )); then
        curl_args+=( '--get' )
      fi
      ;;
    POST)
      if ! (( "${#}" )); then
        curl_args+=(
          '--data' '@-'
          '--header' 'Content-type: application/json'
        )
      fi
      ;;
    *)
      curl_args+=( "-X${method}" )
      ;;
  esac

  while (( "${#}" )); do
    curl_args+=(
      '--data-urlencode' "${1}"
    )
    shift
  done

  out=$(curl \
          --no-keepalive    \
          "${curl_args[@]}" \
          "${BASEURL}${endpoint}")

  if [[ -n "${out}" ]]; then
    jq . <<< "${out}"
  fi
}

function _exit() {
  if [[ -v TOKEN && "${TOKEN}" && "${TOKEN}" != 'null' ]]; then
    >&2 echo 'Logging out...'
    _curl_form post '/api/v1/oauth-expiration' <<< '' >/dev/null
  fi
}

trap _exit EXIT

profile_config="${XDG_CONFIG_HOME}/thycoss/${THYCOSS_PROFILE}"
if [[ -f "${profile_config}" ]]; then
  # shellcheck disable=SC1090
  . "${profile_config}"
fi

until [[ "${BASEURL}" ]]; do
  read -r -p 'API base URL: ' BASEURL
done

until [[ "${USERNAME}" ]]; do
  read -r -p 'Username: ' USERNAME
done

until [[ "${PASS_PATH}" ]]; do
  read -r -p 'Username: ' PASS_PATH
done

ORGANIZATION="${ORGANIZATION:-}"
DOMAIN="${DOMAIN:-}"
PASSWORD="$(pass show "${PASS_PATH}" | head -n1)"

TOKEN=$(_curl_form post '/oauth2/token'             \
                   "username=${USERNAME}"         \
                   "password=${PASSWORD}"         \
                   "organization=${ORGANIZATION}" \
                   "domain=${DOMAIN}"             \
                   'grant_type=password'  |
          jq -r .access_token)

CURL_DEFAULT_ARGS+=( '--header' "Authorization: Bearer ${TOKEN}" )

# Example:
#   _curl_form get '/api/v1/version'
