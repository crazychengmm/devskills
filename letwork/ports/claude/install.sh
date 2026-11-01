#!/usr/bin/env bash
# 安装/升级 letwork 到 Claude Code 个人 skills 目录（幂等软链）。
# 用法：bash ports/claude/install.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
CORE="$REPO/skills/letwork/SKILL.md"
TARGET="$HOME/.claude/skills"

if [ ! -f "$CORE" ]; then
  echo "error: 找不到 $CORE" >&2
  exit 2
fi

# 版本号唯一事实源：核心 SKILL.md 的 frontmatter version 字段
VERSION="$(grep -m1 '^version:' "$CORE" | awk '{print $2}')"
[ -n "$VERSION" ] || { echo "error: SKILL.md 缺少 version 字段" >&2; exit 2; }

mkdir -p "$TARGET"
count=0
for d in "$REPO"/skills/*/; do
  name="$(basename "$d")"
  ln -sfn "$d" "$TARGET/$name"
  count=$((count + 1))
done

cat <<EOF
✓ letwork v${VERSION} 已安装
  源目录:   ${REPO}
  安装位置: ${TARGET}（${count} 个命令，软链模式）
  生效方式: 新开 Claude Code 会话后输入 /let 验证补全
  查看版本: grep '^version:' ${TARGET}/letwork/SKILL.md
  升级:     git -C "${REPO}" pull 后重跑本脚本（软链不变时无需重跑），并新开会话
EOF
