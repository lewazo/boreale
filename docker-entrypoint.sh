#!/bin/bash
set -e

USER_ID=${UID:-9001}
GROUP_ID=${GID:-9001}

groupmod -o -g "$GROUP_ID" boreale
usermod -o -u "$USER_ID" boreale

echo "
User uid:    $(id -u boreale)
User gid:    $(id -g boreale)
-------------------------------------
"

exec /sbin/su-exec $USER_ID "/opt/$APP_NAME/bin/$APP_NAME" "$@"
