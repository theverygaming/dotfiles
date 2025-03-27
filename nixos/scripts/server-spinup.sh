#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

HOST=$1
TARGET=$2

nix run github:nix-community/nixos-anywhere \
    -- \
    --flake "${SCRIPT_DIR}/..#${HOST}" \
    --generate-hardware-config nixos-generate-config "./hosts/${HOST}/hardware-configuration.nix" \
    --target-host "${TARGET}"

# --disk-encryption-keys <remote_path> <local_path>
#  copy the contents of the file or pipe in local_path to remote_path in the installer environment,
#  after kexec but before installation. Can be repeated.
