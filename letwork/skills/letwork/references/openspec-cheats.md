# OpenSpec v1.16 速查（执行 openspec 命令前对照本文件）

来源：对 npm `@fission-ai/openspec@1.16.0` 包与 Fission-AI/OpenSpec 仓库的核实。升级大版本后请重新核实。

> 原理与多人协同（change 隔离、归档冲突、分支工作流）见 [../../../docs/openspec-collaboration.md](../../../docs/openspec-collaboration.md)。

## 常用 CLI（真实存在）

| 命令 | 用途 |
|---|---|
| `openspec init [path] --tools claude [--language ... --profile core\|expanded --force]` | 初始化项目 |
| `openspec update` | 重新生成 AI 指令文件 |
| `openspec new change <kebab-name> [--description "..." --goal "..."]` | 创建 change 脚手架。**长 flag 与值之间必须有空格**（`--goal"x"` 会被 shell 拼成 `--goalx`，CLI 会建出没有 `.openspec.yaml` 的半成品目录，且重试报 already exists）；创建后立即 `ls openspec/changes/<name>/.openspec.yaml` 校验，缺失则删除空目录重建 |
| `openspec list [--changes --archived --json]` | 列 change |
| `openspec status --change <name> [--json]` | 产物完成度（done/ready/blocked） |
| `openspec validate [name] [--strict --json]` | 校验（`--strict` 把 warning 也当失败） |
| `openspec show <name> [--deltas-only]` | 查看 change 内容 |
| `openspec archive <name> [-y] [--skip-specs]` | 校验 → delta 合入 specs/ → 移入 archive/日期前缀目录 |
| `openspec instructions apply --change <name> --json` | 取 apply 阶段的机器指令（**没有 `openspec apply` 命令**，apply 是 AI 工作流） |
| `openspec config profile` | 切换 core / expanded profile |

注意：`openspec change show/list/validate` 已废弃；`openspec spec create`、`openspec diff` 不存在。

## 目录与文件

```
openspec/
├── config.yaml
├── specs/<capability-path>/spec.md          # capability 路径可嵌套，kebab-case
└── changes/<change>/
    ├── .openspec.yaml
    ├── proposal.md
    ├── design.md
    ├── tasks.md
    ├── specs/<capability-path>/spec.md      # delta 文件；specs/<x>.md 这种平铺文件会被忽略
    └── letwork/                             # 本 skill 私有目录（journal/review/commits）
```

`.openspec.yaml` 已识别键（strict schema）：`schema`（必填）、`created: YYYY-MM-DD`、`goal`、`affected_areas`、`skip_specs: true`（纯重构/文档类；此时 specs/ 下不得有文件）、`retire_capabilities: true`、`initiative`，以及任意 `x-*` 扩展键。

**skip_specs 端到端做法（实测 v1.16）**：内部重构/依赖升级/文档类无行为变化的 change，在 `.openspec.yaml` 写 `skip_specs: true`，change 目录只保留 proposal.md/design.md/tasks.md（不建 specs/），`validate --strict` 会输出 INFO「zero deltas accepted」而非报错；archive 后只移动目录，**不修改主 specs**。验收靠既有测试全绿，不靠 spec。

## 模板格式

**proposal.md**：`# Proposal`；`## Why`（50–1000 字符，写动机/问题/为何现在）；`## What Changes`；`## Capabilities` 下分 `### New Capabilities`（每项 `- \`path\`: 描述`，path 决定 specs 目录名）与 `### Modified Capabilities`（仅 spec 级行为变化才列，必须用 specs/ 下已有的精确路径，纯实现改动不列）；`## Impact`。

**tasks.md**：

```markdown
# Tasks

## 1. <任务组名>
- [ ] 1.1 <可在半天内完成、可独立测试的事项>
- [ ] 1.2 ...
```

**design.md**：`## Context` / `## Goals / Non-Goals`（**Goals:** 与 **Non-Goals:** 两段）/ `## Decisions`（决策 + 理由 + 备选）/ `## Risks / Trade-offs`。

**spec delta（specs/<capability>/spec.md）**：

```markdown
## ADDED Requirements

### Requirement: <名称>
<规范语句，必须含 SHALL 或 MUST，≤500 字符>

#### Scenario: <场景名>
- **WHEN** <触发条件>
- **THEN** <可观察结果>
- **AND** <补充（可选）>
```

- delta 头只允许：`## ADDED Requirements`、`## MODIFIED Requirements`（必须写修改后的完整 requirement）、`## REMOVED Requirements`（每个含 `**Reason**` 与 `**Migration**`）、`## RENAMED Requirements`（`FROM: 旧名` 紧接 `TO: 新名`）、`## Purpose`（仅新 capability，**analyze 门禁：必写**，≥50 字符；不写则 archive 后主 spec 留 TBD 占位）。
- `openspec status --json`（v1.16 实测）：`artifacts[]` 每项含 `id`(proposal/specs/design/tasks) 与 `status`(ready/blocked/done)，另有 `isPlanningComplete`、`isComplete`、`applyRequires`、`nextSteps`；tasks 依赖 specs 与 design 都完成。`openspec list --json` 的 `changes[]` 含 `name/completedTasks/totalTasks/lastModified/status`。
- requirement 头精确写作 `### Requirement: <名>`；场景精确写作 `#### Scenario:`（三级标题或裸列表会被静默忽略）。
- 每个 requirement 至少 1 个 scenario；每个 scenario 必须有 WHEN/GIVEN 与 THEN。
- 主规格 `openspec/specs/<cap>/spec.md` 结构是 `## Purpose` + `## Requirements`，由 archive 自动合并生成，不要手写。

## 校验红线（error，直接失败）

- proposal 缺 `## Why`/`## What Changes` 或 Why <50 字符。
- 一个 delta 都没有（除非 `skip_specs: true`；设了它 specs/ 下又有文件 = 冲突 error）。
- delta 文件名不是 `specs/<capability>/spec.md`；delta 文件没有合法 H2 头；H2 头下没有 `### Requirement:`。
- requirement 缺 SHALL/MUST；ADDED/MODIFIED 的 requirement 没有 scenario；scenario 缺 WHEN/THEN；空文本。
- 同一 delta 内 requirement 重复、ADDED+REMOVED 等冲突头并存；RENAMED 的 FROM/TO 不配对。
- `.openspec.yaml` 含未知键（`x-*` 除外）、created 格式错、schema 名不认识、id 非 kebab-case。
- 每个 change 最多 10 个 delta 文件（超出应拆分）。

## 常见 warning（--strict 下失败）

requirement 正文 >500 字符；Purpose <50 字符或仍是 `TBD ...`；Why >1000 字符；scenario 只有 AND 没有 WHEN/THEN；任务编号/勾选异常。`validate --archived` 还要求 tasks 全部勾选。

## CLI 不可用时的人工自检清单

1. proposal 的 Why 是一段完整动机（肉眼 ≥50 字符），Capabilities 路径与 delta 目录一一对应。
2. 每个 delta 文件路径合法、H2 合法、每条 requirement 有 SHALL/MUST 与至少一个 WHEN+THEN 场景。
3. tasks.md 编号连续、组号与条目号格式正确。
4. `.openspec.yaml` 只含已识别键。
