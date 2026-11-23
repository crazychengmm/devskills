#!/usr/bin/env bash
# 手动重建软链的命令行入口（npm bin 暴露为 letwork-link）。
# 兼容 npm 全局 bin 中的符号链接调用（macOS readlink 无 -f，用循环解析）。
set -euo pipefail

SELF="$0"
while [ -L "$SELF" ]; do
  DIR="$(cd -P "$(dirname "$SELF")" >/dev/null 2>&1 && pwd)"
  TARGET="$(readlink "$SELF")"
  case "$TARGET" in
    /*) SELF="$TARGET" ;;
    *)  SELF="$DIR/$TARGET" ;;
  esac
done
SCRIPT_DIR="$(cd -P "$(dirname "$SELF")" >/dev/null 2>&1 && pwd)"

exec "$SCRIPT_DIR/npm-postinstall.sh"
