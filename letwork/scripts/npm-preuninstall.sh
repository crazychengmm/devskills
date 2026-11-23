#!/usr/bin/env bash
# npm 卸载前清理：仅删除指向本包 skills 目录的软链，不动用户的其他 skill。
set -euo pipefail

PKG_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.claude/skills"

[ -d "$TARGET" ] || exit 0

removed=0
for link in "$TARGET"/*; do
  [ -L "$link" ] || continue
  target_path="$(readlink "$link")"
  case "$target_path" in
    "$PKG_ROOT"/*)
      rm -f "$link"
      removed=$((removed + 1))
      ;;
  esac
done

echo "[letwork] 卸载清理：移除 ${removed} 个指向本包的软链"
