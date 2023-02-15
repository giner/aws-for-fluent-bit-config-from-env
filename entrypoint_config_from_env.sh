#!/bin/bash

set -euo pipefail

base64 -d <<< "$FLUENT_BIT_CONFIG_BASE64" > /fluent-bit/configs/config-from-env.conf

exec /entrypoint.sh "$@"
