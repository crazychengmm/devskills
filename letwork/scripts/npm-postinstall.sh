#!/usr/bin/env bash
# npm 安装/升级后执行：把 skills/* 软链到 ~/.claude/skills（幂等）。
# 与 ports/claude/install.sh 逻辑一致，适配 npm 全局安装后的包目录。
set -euo pipefail

# npm 运行时 PWD 可能不在包根，用脚本自身位置定位
PKG_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CORE="$PKG_ROOT/skills/letwork/SKILL.md"
TARGET="$HOME/.claude/skills"

if [ ! -f "$CORE" ]; then
  echo "[letwork] warn: 找不到 $CORE，跳过软链（包内容不完整？）" >&2
  exit 0
fi

VERSION="$(grep -m1 '^version:' "$CORE" | awk '{print $2}')"

mkdir -p "$TARGET"
count=0
for d in "$PKG_ROOT"/skills/*/; do
  name="$(basename "$d")"
  ln -sfn "$d" "$TARGET/$name"
  count=$((count + 1))
done

echo "[letwork] v${VERSION:-unknown} 已通过 npm 安装：${count} 个 skill 软链到 ${TARGET}"
echo "[letwork] 新开会话后输入 /let 验证；版本: grep '^version:' ${TARGET}/letwork/SKILL.md"
