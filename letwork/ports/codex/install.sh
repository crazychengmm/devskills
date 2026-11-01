#!/usr/bin/env bash
# 将 letwork 安装为 Codex CLI 的自定义 prompts（斜杠命令）。
# Codex 约定：~/.codex/prompts/<name>.md 即 /<name> 命令，$ARGUMENTS 为用户参数。
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
PROMPTS="$HOME/.codex/prompts"
mkdir -p "$PROMPTS"

gen() {
  local cmd="$1" mode="$2" ref="$3"
  cat > "$PROMPTS/$cmd.md" <<EOF
---
description: letwork ${mode}（OpenSpec 需求驱动研发流）
---

按 letwork 规程执行 **${mode}**：

1. Read 核心引擎：$REPO/skills/letwork/SKILL.md
2. Read 本阶段细则：$REPO/skills/letwork/references/$ref
3. 严格执行其中的启动检查、阶段门禁与铁律；需要提问时在一条消息中编号列出问题并给推荐答案。
4. OpenSpec 命令对照：$REPO/skills/letwork/references/openspec-cheats.md。

用户参数：\$ARGUMENTS
EOF
  echo "created: /$cmd"
}

gen "letworkstart" "route 模式" "routing.md"
for stage in analyze plan code test review commit retro; do
  gen "let-$stage" "stage:$stage" "$stage.md"
done

echo ""
echo "完成。Codex 会自动读取项目根 AGENTS.md——建议每个项目执行一次："
echo "  cp $REPO/ports/AGENTS.md <项目根>/AGENTS.md"
echo "或设为全局：cp $REPO/ports/AGENTS.md ~/.codex/AGENTS.md"
