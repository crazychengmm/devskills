#!/usr/bin/env bash
# 将 letwork 安装到 Cursor 的个人 skills 与 commands 目录（软链，git pull 即时生效）。
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_SRC="$REPO/skills"
CURSOR_SKILLS="$HOME/.cursor/skills"
CURSOR_COMMANDS="$HOME/.cursor/commands"

mkdir -p "$CURSOR_SKILLS" "$CURSOR_COMMANDS"

# 1) 9 个 skill（核心 letwork + 8 个阶段包装）软链到 Cursor skills
for d in "$SKILLS_SRC"/*/; do
  name="$(basename "$d")"
  ln -sfn "$d" "$CURSOR_SKILLS/$name"
  echo "linked skill: $name"
done

# 2) 生成 8 个斜杠命令（Cursor commands/*.md，$ARGUMENTS 透传用户输入）
for stage in start analyze plan code test review commit retro; do
  if [ "$stage" = "start" ]; then
    mode="route（检查仓库现状并自动路由）"
    cmd="letworkstart"
  else
    mode="stage:$stage"
    cmd="let-$stage"
  fi
  cat > "$CURSOR_COMMANDS/$cmd.md" <<EOF
---
description: letwork $mode
---

使用 letwork skill 执行 **$mode** 模式。先 Read 核心规程 $REPO/skills/letwork/SKILL.md 与 references/${stage/start/routing}.md（route 模式读 routing.md），严格按其中的启动检查、门禁与铁律执行。用户参数：\$ARGUMENTS
EOF
  echo "created command: /$cmd"
done

echo ""
echo "完成。重启或新开会话后："
echo "  - 输入 /letworkstart 等命令，或直接用自然语言（分析需求/拆任务/按规范评审/按任务提交）"
echo "  - 若当前 Cursor 版本不支持 skills 自动发现，把 $REPO/ports/AGENTS.md 复制到项目根目录"
