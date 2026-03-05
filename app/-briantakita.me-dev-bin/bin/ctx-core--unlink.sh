#!/bin/sh
# Restore @ctx-core/* packages from npm (removes local symlinks).
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_ROOT="$(readlink -f "$SCRIPT_DIR/../../..")"

echo "Restoring @ctx-core packages from npm..."
cd "$REPO_ROOT"
bun install --force
echo "Done. All @ctx-core packages restored from registry."
