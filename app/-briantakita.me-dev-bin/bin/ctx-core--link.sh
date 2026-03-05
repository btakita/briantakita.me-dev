#!/bin/sh
# Symlink @ctx-core/* packages from local ctx-core-dev for development.
# Also cleans broken symlinks in workspace node_modules (Bun leaves stale ones).
# Re-run after `bun install` (which overwrites symlinks).
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_ROOT="$(readlink -f "$SCRIPT_DIR/../../..")"

# Find ctx-core-dev: env var > local symlink in repo > sibling directory
if [ -z "$CTX_CORE_DEV" ]; then
  if [ -d "$REPO_ROOT/ctx-core-dev" ]; then
    CTX_CORE_DEV="$(readlink -f "$REPO_ROOT/ctx-core-dev")"
  elif [ -d "$REPO_ROOT/../ctx-core-dev" ]; then
    CTX_CORE_DEV="$(readlink -f "$REPO_ROOT/../ctx-core-dev")"
  fi
fi

if [ ! -d "$CTX_CORE_DEV" ]; then
  echo "ERROR: ctx-core-dev not found."
  echo "Either:"
  echo "  1. Set CTX_CORE_DEV=/path/to/ctx-core-dev"
  echo "  2. Symlink ctx-core-dev into the repo root: ln -s /path/to/ctx-core-dev $REPO_ROOT/ctx-core-dev"
  exit 1
fi

# Clean broken symlinks in workspace node_modules (Bun leaves stale ones after rm -rf + reinstall)
find "$REPO_ROOT" -path "$REPO_ROOT/node_modules" -prune -o -name node_modules -type d -print 2>/dev/null | while read nm; do
  find "$nm" -maxdepth 3 -type l ! -exec test -e {} \; -delete 2>/dev/null
done

link_pkg() {
  local scope="$1" name="$2" src_base="$3"
  local src="$CTX_CORE_DEV/$src_base/$name"
  local dest="$REPO_ROOT/node_modules/$scope/$name"
  if [ -d "$src" ]; then
    rm -rf "$dest"
    ln -s "$src" "$dest"
    echo "linked $scope/$name -> $src"
  else
    echo "SKIP  $scope/$name (not found at $src)"
  fi
}

echo "ctx-core-dev: $CTX_CORE_DEV"
echo ""

# Direct dependencies
link_pkg @ctx-core dev-tools lib
link_pkg @ctx-core monorepo lib
link_pkg @ctx-core preprocess lib
link_pkg @ctx-core source-map lib

# Transitive dependencies
link_pkg @ctx-core child_process lib
link_pkg @ctx-core ctx-core-package-tools tools
link_pkg @ctx-core dir lib
link_pkg @ctx-core fs lib
link_pkg @ctx-core package lib

# @rebuildjs packages (npm name differs from directory name)
src="$CTX_CORE_DEV/lib/rebuildjs-tailwindcss"
dest="$REPO_ROOT/node_modules/@rebuildjs/tailwindcss"
if [ -d "$src" ]; then
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "linked @rebuildjs/tailwindcss -> $src"
else
  echo "SKIP  @rebuildjs/tailwindcss (not found at $src)"
fi

# esbuild plugins
for pkg in esbuild-plugin-esmfile esbuild-plugin-esmcss; do
  src="$CTX_CORE_DEV/lib/$pkg"
  dest="$REPO_ROOT/node_modules/$pkg"
  if [ -d "$src" ]; then
    rm -rf "$dest"
    ln -s "$src" "$dest"
    echo "linked $pkg -> $src"
  else
    echo "SKIP  $pkg (not found at $src)"
  fi
done

# Standalone packages (no scope — top-level in node_modules)
for pkg in ctx-core relysjs rebuildjs relementjs rmemo; do
  src="$CTX_CORE_DEV/lib/$pkg"
  dest="$REPO_ROOT/node_modules/$pkg"
  if [ -d "$src" ]; then
    rm -rf "$dest"
    ln -s "$src" "$dest"
    echo "linked $pkg -> $src"
  else
    echo "SKIP  $pkg (not found at $src)"
  fi
done

# Ensure shared dependencies are resolvable from ctx-core-dev's physical path.
# Symlinked packages resolve modules walking up from ctx-core-dev, not briantakita.me-dev.
echo ""
echo "Bridging shared dependencies into ctx-core-dev..."
for bridge_pkg in esbuild postcss; do
  root_pkg="$REPO_ROOT/node_modules/$bridge_pkg"
  ctx_pkg="$CTX_CORE_DEV/node_modules/$bridge_pkg"
  if [ -d "$root_pkg" ] && [ ! -e "$ctx_pkg" ]; then
    mkdir -p "$CTX_CORE_DEV/node_modules"
    ln -s "$root_pkg" "$ctx_pkg"
    echo "  bridged $bridge_pkg -> $root_pkg"
  elif [ -d "$root_pkg" ] && [ -L "$ctx_pkg" ]; then
    # Update existing symlink
    rm -f "$ctx_pkg"
    ln -s "$root_pkg" "$ctx_pkg"
    echo "  updated bridge $bridge_pkg -> $root_pkg"
  fi
done

# Replace nested esbuild/postcss in symlinked packages with symlinks to root copies.
# Symlinked packages resolve from ctx-core-dev's physical path, so they can't find
# briantakita.me-dev's root node_modules. Replacing nested copies with symlinks to root
# ensures a single version is used (preventing TS2322 type mismatches).
echo ""
echo "Deduplicating nested dependencies..."
dedup_to_root() {
  local nested_dir="$1" pkg_name="$2"
  local root_pkg="$REPO_ROOT/node_modules/$pkg_name"
  if [ -e "$nested_dir" ] || [ -L "$nested_dir" ]; then
    rm -rf "$nested_dir"
    if [ -d "$root_pkg" ]; then
      ln -s "$root_pkg" "$nested_dir"
      echo "  deduped $(echo "$nested_dir" | sed "s|$REPO_ROOT/node_modules/||") -> root"
    else
      echo "  removed $(echo "$nested_dir" | sed "s|$REPO_ROOT/node_modules/||") (no root copy)"
    fi
  fi
}
dedup_to_root "$REPO_ROOT/node_modules/@rebuildjs/tailwindcss/node_modules/esbuild" esbuild
dedup_to_root "$REPO_ROOT/node_modules/@rebuildjs/tailwindcss/node_modules/postcss" postcss
dedup_to_root "$REPO_ROOT/node_modules/rebuildjs/node_modules/esbuild" esbuild
dedup_to_root "$REPO_ROOT/node_modules/esbuild-plugin-esmfile/node_modules/esbuild" esbuild
dedup_to_root "$REPO_ROOT/node_modules/esbuild-plugin-esmcss/node_modules/esbuild" esbuild

echo ""
echo "Done. Run ctx-core--unlink to restore npm versions."
