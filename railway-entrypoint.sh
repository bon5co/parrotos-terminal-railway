#!/bin/sh
# Railway entrypoint for the ParrotOS browser terminal.
#
# Two jobs:
#   1. Refuse to boot without a login credential, so the deploy can never serve
#      an unauthenticated root shell.
#   2. Restore the home skeleton the volume mount hides, so /root is usable on
#      the first boot and persistent on every later one.
set -eu

: "${PORT:=7681}"
: "${USERNAME:=admin}"

if [ -z "${PASSWORD:-}" ]; then
    echo "[railway] FATAL: PASSWORD is empty. Set PASSWORD (the template defaults it to a generated secret)." >&2
    exit 1
fi

if [ -d /opt/root-skel ]; then
    for f in /opt/root-skel/.[!.]* /opt/root-skel/*; do
        [ -e "$f" ] || continue
        base=$(basename "$f")
        [ -e "/root/$base" ] || cp -a "$f" "/root/$base"
    done
fi

cd /root

echo "[railway] starting ttyd on :$PORT as user '$USERNAME' (home /root persisted)" >&2
exec /usr/local/bin/ttyd -p "$PORT" -i 0.0.0.0 -c "$USERNAME:$PASSWORD" -W /bin/bash
