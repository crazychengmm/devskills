---
name: letwork
version: 0.7.0
description: 基于 OpenSpec 的需求驱动研发流程引擎。当用户要分析需求（用轮次访谈逼问清楚）、把需求拆成开发任务、按任务逐个编码/测试/评审/提交代码、记录过程中的问题与改进、继续或归档一个 OpenSpec change 时使用；也在被 /letworkstart、/let-analyze、/let-plan、/let-code、/let-test、/let-review、/let-commit、/let-retro 调用时使用。
---

# letwork — OpenSpec 需求驱动研发流

> **版本 v0.7.0**（版本号是唯一事实源，位于本文件 frontmatter；被问「当前版本」时直接读这里，变更历史见仓库 README）。升级后需新开会话才保证加载最新内容。

把「需求分析 → 任务拆分 → 编码 → 测试 → 评审 → 按任务提交 → 归档复盘」串成一条流水线。每个需求是 OpenSpec 的一个 change，全过程产物都记录在该 change 目录下。

## 入口模式

- **route**（来自 `/letworkstart` 或模型自行触发）：先判定现状，推导当前阶段，说明依据并等用户确认后再进入。
- **stage:<name>**（来自 `/let-*` 包装）：analyze / plan / code / test / review / commit / retro 之一，跳过路由直接执行该阶段规程。用户在命令后输入的文字是该阶段的参数，原样使用。

## 每次进入先做启动检查

1. 当前工作目录是否在 git 仓库内（`git rev-parse --show-toplevel`）。不是则告知用户先 `git init`，不替用户决定仓库位置。
2. 仓库内是否有 `openspec/` 目录。没有 → 读 [references/bootstrap.md](references/bootstrap.md) 引导初始化（需要用户确认后再安装/执行）。
3. OpenSpec CLI 是否可用（`openspec --version`；真实包名 `@fission-ai/openspec`，裸 `openspec` npm 包是占位假包）。不可用时按 bootstrap.md 的降级方案手工维护产物。
4. route 模式：读 [references/routing.md](references/routing.md)，用其中命令收集现状并按决策表路由，**把推导依据摆给用户看，等确认**。
5. 涉及编码/评审时：识别项目语言并确认规范冻结态（见 code.md 的规范门禁）。

## 阶段表（细则按需 Read，不要一次全读）

| 阶段 | 做什么 | 完成门禁（不过不推进） | 细则 |
|---|---|---|---|
| analyze | grilling 轮次访谈 → proposal.md + specs delta（新 capability 含 Purpose）+ design.md | `openspec validate <change>` 通过；用户确认需求 | [analyze.md](references/analyze.md) |
| plan | 拆任务到 tasks.md，任务与 requirement 双向可追溯 | 任务粒度 ≤ 半天、可独立测试；validate 通过；用户确认 | [plan.md](references/plan.md) |
| code | 一次一个任务：加载规范 → 实现 → 自检 → 勾选 | 规范已冻结；当前任务自检过；tasks.md 勾选 | [code.md](references/code.md) |
| test | 运行当前任务相关测试，记录证据 | 测试通过；命令与结果记入 journal；失败回 code | [test.md](references/test.md) |
| review | 规范轴 + spec 一致性轴双轴评审 | 无 BLOCKER；`validate --strict` 通过；报告落盘 | [review.md](references/review.md) |
| commit | 分批选择性提交；每批是可编译可测的绿色提交，Conventional Commits，记账 | 编译+测试在暂存快照上为绿；方案与暂存清单经用户确认；SHA 登入 commits.md | [commit.md](references/commit.md) |
| retro | 记录问题/决策/改进；归档前汇总 | journal 已追加；归档前有汇总条目 | [retro.md](references/retro.md) |

全部任务完成、review 与 validate 通过后，提示用户归档（`openspec archive <change>`），归档前未做 retro 则先补一次。

OpenSpec v1.16 的命令、模板格式与校验红线见 [openspec-cheats.md](references/openspec-cheats.md)，执行任何 openspec 命令前先对照它，不要凭记忆编造命令。

## 铁律（所有阶段都生效）

1. **事实自查，决策问人**：能用工具查到的（文件、代码、命令结果、文档）自己查，可派子 agent 并行查；只有取舍与产品决策才问用户。提问沿用 grilling 的 frontier/轮次方式，并给推荐答案。
2. **每步留痕**：每个阶段的关键决策、问题、改进都追加到该 change 的 `letwork/journal.md`（格式见 [templates/journal.md](templates/journal.md)）。
3. **按任务推进与提交**：一次只做一个任务；任务完成且测试为绿后**主动规划分批提交**，不要被动等待。每个 commit 都必须是**绿色提交**——checkout 出来可编译、测试通过（半成品只留工作树）；按任务选择性暂存（禁止 `git add -A`/`git add .`），工作树有半成品时用 `git stash --keep-index` 只验证暂存快照；提交前展示分批方案与暂存清单并经用户确认；不自动 push。每个任务先过机械化自检（格式/编译/lint，见 code.md）再勾选；测试判定只认真实退出码（管道不吞失败，见 test.md）。详见 [commit.md](references/commit.md)。
4. **规范单一事实源**：coding 与 review 使用同一份冻结在项目内的规范（`openspec/standards/`），review 结论必须引用规则 ID。未冻结规范不得进入 code。
5. **门禁不过不推进**：校验失败、测试失败、review 有 BLOCKER 时，停在当前阶段修复，不跳到下一步。
6. **如实报告**：命令失败就贴失败信息，不许把没跑过的测试说成通过；改动外的破坏性/对外动作先征得用户同意。
7. **不与 OpenSpec 抢所有权**：proposal/design/tasks/spec delta 只写 OpenSpec 规定格式；本 skill 自己的记录只放 change 下的 `letwork/` 子目录。
8. **语言**：与用户交流、journal、review 报告用中文；proposal/spec 等 OpenSpec 产物遵循项目 `openspec/config.yaml` 的 product language 约定（无约定则中文）。

## 快速恢复上下文

每次进入一个活动 change，先读：`proposal.md`（一句话目标）、`tasks.md`（进度）、`letwork/journal.md`（最近 3 条）、`letwork/commits.md`（已提交到哪），再决定动作。
