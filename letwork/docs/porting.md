# 跨 agent 移植指南

letwork 分层设计：**规程与规范是纯 Markdown（与 agent 无关），斜杠命令只是外壳**。本文说明如何在非 Claude 的任意 agent 中使用。

## 可移植性分层

| 组成 | 是否依赖 Claude | 移植方式 |
|---|---|---|
| 阶段规程（analyze/plan/code/test/review/commit/retro） | 否，纯 Markdown | 让 agent Read 对应 references/*.md，或写入项目规则文件 |
| 代码规范库（common/Java/Go/Python checklist） | 否 | 复制到项目 `openspec/standards/`，任何 agent 都能按 ID 检查 |
| 模板（journal/review/commits） | 否 | 直接复制 |
| OpenSpec 生命周期 | 否，官方支持 40+ 工具 | `openspec init --tools <工具>` 生成该工具原生命令 |
| SKILL.md 自动发现 + `/let-*` 注册 | 是 Claude 机制 | 换成目标工具的 skill/command/prompt 目录，或 AGENTS.md |
| AskUserQuestion 弹窗 | 是 Claude UI | 降级为一条消息内的编号问题（grilling 微格式本身是纯文本） |
| Skill 工具互调 | 是 Claude 机制 | 命令文件改为指示 agent Read 核心 SKILL.md |

## 已提供的适配

| 工具 | 方式 | 文件 |
|---|---|---|
| Claude Code | 软链 9 个 skill 到 ~/.claude/skills/ | 见 [README 安装章节](../README.md#安装) |
| 任何读 AGENTS.md 的工具（Codex、Cursor、Zed 等） | 复制 `ports/AGENTS.md` 到项目根 | [ports/AGENTS.md](../ports/AGENTS.md) |
| Cursor | 软链 skills + 生成 ~/.cursor/commands | [ports/cursor/](../ports/cursor/README.md) |
| Codex CLI | 生成 ~/.codex/prompts + AGENTS.md | [ports/codex/](../ports/codex/README.md) |

## 移植到任意新 agent 的通用步骤

1. **查清该工具的规则/命令载体**：项目规则文件（AGENTS.md / .cursor/rules / GEMINI.md / .windsurf/rules / .github/instructions）、命令目录（~/.xxx/commands、~/.codex/prompts、.gemini/commands）。
2. **规则层**：把 `ports/AGENTS.md` 的内容合并进该工具的项目规则文件（大多数工具直接读 AGENTS.md，零改动）。
3. **命令层（可选）**：为 8 个阶段各建一个命令/提示，内容固定为：
   > Read `<仓库路径>/skills/letwork/SKILL.md` 与 `references/<stage>.md`，按其中启动检查、门禁与铁律执行。用户参数：<该工具的参数占位符>
4. **OpenSpec 层**：在项目里 `openspec init . --tools <工具>`，获得该工具原生的 /opsx 命令。
5. **交互降级**：在 agent 配置或 AGENTS.md 中写明「需要决策时，一条消息列出 Q1..Qn 及推荐答案，等用户按编号回答」。
6. 验证：让它执行 `/<命令>` 或自然语言「继续当前需求」，应能看到启动检查与路由输出。

## 自然语言触发表（无斜杠命令时直接对 agent 说）

| 说法 | 阶段 |
|---|---|
| 开始这个需求 / 先帮我把需求问清楚 | analyze |
| 把需求拆成任务 | plan |
| 按规范做任务 2.1 / 开始编码 | code |
| 跑测试并记录 | test |
| 按规范评审这次改动 | review |
| 按任务提交 / 把这个修复单独提交 | commit |
| 记一个问题 / 做阶段复盘 | retro |
| 继续上次的 / 现在该做什么 | route |

## 编写适配脚本的注意事项

- shell 脚本里变量后**紧跟中文字符（全角括号等）时必须写 `${var}`**：`set -u` 下 `$TARGET（` 会被解析成名为 `TARGET（` 的未绑定变量而报错。规则：heredoc 中凡是变量后接非 ASCII 字符，一律 `${}` 包裹（本仓库 codex/claude 安装脚本各踩过一次）。
- 安装脚本必须幂等（重复执行结果相同），并在结束时输出版本号；版本号统一从核心 SKILL.md frontmatter 的 `version` 字段读取，不另设事实源。

## 已知注意事项

- 路径：非软链安装时，AGENTS.md/命令里引用的仓库路径要改成你的实际克隆位置。
- OpenSpec 的命令拼写随工具变化：Claude 是 `/opsx:propose`，Cursor 是 `/opsx-propose`，Codex 是 `$openspec-propose`；以 `openspec init` 实际生成的为准。
- 工具对 Agent Skills（SKILL.md）格式的支持在快速演进，发布前以目标工具当期官方文档核对目录约定。
