#!/bin/sh
set -e

# Launch the OTP release and replace the caller as Process #1 in the container
exec /opt/$APP_NAME/bin/$APP_NAME "$@"
