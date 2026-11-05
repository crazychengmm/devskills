---
name: letwork
version: 0.18.0
description: 基于 OpenSpec 的需求驱动研发流程引擎。当用户要分析需求（用轮次访谈逼问清楚）、把需求拆成开发任务、按任务逐个编码/测试/评审/提交代码、记录过程中的问题与改进、继续或归档一个 OpenSpec change 时使用；也在被 /letworkstart、/let-analyze、/let-plan、/let-code、/let-test、/let-review、/let-commit、/let-retro 调用时使用。
---

# letwork — OpenSpec 需求驱动研发流

> **版本 v0.18.0**（版本号是唯一事实源，位于本文件 frontmatter；被问「当前版本」时直接读这里，变更历史见仓库 README）。升级后需新开会话才保证加载最新内容。

把「需求分析 → 任务拆分 → 编码 → 测试 → 评审 → 按任务提交 → 归档复盘」串成一条流水线。每个需求是 OpenSpec 的一个 change，全过程产物都记录在该 change 目录下。

## 入口模式

- **route**（来自 `/letworkstart` 或模型自行触发）：先判定现状，推导当前阶段，说明依据并等用户确认后再进入。
- **stage:<name>**（来自 `/let-*` 包装）：analyze / plan / code / test / review / commit / retro 之一，跳过路由直接执行该阶段规程。用户在命令后输入的文字是该阶段的参数，原样使用。

## 每次进入先做启动检查

1. 当前工作目录是否在 git 仓库内（`git rev-parse --show-toplevel`）。不是则告知用户先 `git init`，不替用户决定仓库位置。
2. 仓库内是否有 `openspec/` 目录。没有 → 读 [references/bootstrap.md](references/bootstrap.md) 引导初始化（需要用户确认后再安装/执行）。
3. OpenSpec CLI 是否可用（`openspec --version`；真实包名 `@fission-ai/openspec`，裸 `openspec` npm 包是占位假包）。不可用时按 bootstrap.md 的降级方案手工维护产物。
4. **既存项目先摸底**：仓库在我们介入前已有业务代码（非全新空仓库）时，首次 coding 前先走 [references/intake.md](references/intake.md)：产出 `openspec/letwork/project-profile.md`（架构/风格/模块职责）与 `debt-backlog.md`（既存问题台账），问题逐条由用户决定现在修还是暂缓；新仓库跳过。
5. route 模式：读 [references/routing.md](references/routing.md)，用其中命令收集现状并按决策表路由，**把推导依据摆给用户看，等确认**。
6. 涉及编码/评审时：识别项目语言并确认规范冻结态（见 code.md 的规范门禁）。
7. MCP 工具（serena / codebase-memory-mcp / memory 类）为可选增强：有则按 [references/mcp-integration.md](references/mcp-integration.md) 分工使用（符号导航/影响面/跨项目记忆），无则降级 grep/原生工具，流程不变；MCP 输出不替代编译、测试与门禁事实。

## 阶段表（细则按需 Read，不要一次全读）

| 阶段 | 做什么 | 完成门禁（不过不推进） | 细则 |
|---|---|---|---|
| intake（仅既存项目） | 进场摸底：架构画像 + 代码风格 + 模块职责 + 既存问题确认 | project-profile.md 落盘；既存问题逐条有用户决定（修/暂缓） | [intake.md](references/intake.md) |
| analyze | grilling 访谈 → **方案预览 preview.md（Markdown+Mermaid，用户确认）** → 关联欠债提示 → proposal + specs delta（含 Purpose）+ design | 预览经用户确认；相关 backlog 条目已提示；`openspec validate <change>` 通过 | [analyze.md](references/analyze.md) |
| plan | 拆任务到 tasks.md，任务与 requirement 双向可追溯 | 任务粒度 ≤ 半天；validate 通过；用户确认 | [plan.md](references/plan.md) |
| code | 按任务实现全部功能；**本阶段只做编译/构建级自检，不写不跑测试** | 规范已冻结；无编译错误；tasks.md 实现类任务勾选 | [code.md](references/code.md) |
| review | 代码全部写完后：三轴评审 + 设计优化；此时基线只需编译通过 | 无 BLOCKER；`validate --strict` 通过；优化项有处置决定 | [review.md](references/review.md) |
| test | **review 后、代码已全部写完才进入**：集中编写并运行测试，失败回 code 修复 | 全量测试通过；证据记入 journal | [test.md](references/test.md) |
| commit | 分批选择性提交：code 阶段提交编译绿，test 阶段起提交测试绿；两级确认 | 见 commit.md 两级门禁；SHA 登入 commits.md | [commit.md](references/commit.md) |
| retro | 记录问题/决策/改进；归档前汇总 | journal 已追加；归档前有汇总条目 | [retro.md](references/retro.md) |

> **阶段顺序纪律（默认流程）**：code → review → test，测试在代码全部写完并评审后集中进行，不在每个任务后即测。偏好 TDD 的项目可在项目 `openspec/config.yaml` 声明 `test_strategy: tdd` 切回「每任务即测」；两种模式下 test 阶段之后的提交都必须测试绿。

全部任务完成、review 与 validate 通过后，提示用户归档（`openspec archive <change>`），归档前未做 retro 则先补一次。

OpenSpec v1.16 的命令、模板格式与校验红线见 [openspec-cheats.md](references/openspec-cheats.md)，执行任何 openspec 命令前先对照它，不要凭记忆编造命令。

## 铁律（所有阶段都生效）

1. **事实自查，决策问人；方案先预览后细化**：能用工具查到的（文件、代码、命令结果、文档）自己查，可派子 agent 并行查；只有取舍与产品决策才问用户。提问沿用 grilling 的 frontier/轮次方式，并给推荐答案。非平凡产物先出一页**方案预览（Markdown+Mermaid，letwork/preview.md）经用户确认，再展开正式文档/代码/长报告**，避免错方向浪费 token；平凡任务（小 bugfix/文案）说明理由后可跳过。用户说「不用问/你决定/继续」视为对**本次任务确认门禁的一次性豁免**（预览等待、方案选择等）：产物仍照常产出（供回看），按推荐方案推进，并在 journal 记一条豁免决定；**但 git 本地提交与远端推送不在豁免范围**（见铁律 3，必须各自明确确认）；豁免只限当前任务，不延续到下一 change。
2. **每步留痕，决策即沉淀**：关键取舍**访谈拍板当场写 ADR**（`letwork/adr/`，不事后回忆）；领域名词当场进**术语表**（`letwork/glossary.md`，spec/代码/表列共用统一语言）；需要外部人拍板的决策生成**异步问卷**（`letwork/questionnaires/`）并挂起相关决策、不阻塞无关任务；过程问题/阶段流转追加到 `letwork/journal.md`。模板见 templates/ 目录。
3. **按任务推进与提交；git 动作强制确认 + 编译门禁**：一次只做一个任务；任务完成且测试为绿后**主动规划分批提交**。每个 commit 都必须是**绿色提交**——checkout 出来可编译、测试通过（半成品只留工作树）；按任务选择性暂存（禁止 `git add -A`/`git add .`），工作树有半成品时用 `git stash --keep-index` 只验证暂存快照。**本地 `git commit` 与远端 `git push` 是两级独立确认**：分别展示「文件/message/验证证据」与「待推提交/最新完整构建结果」，用户明确同意才执行；这两个动作**不被「不用问我/你决定」豁免**。push 前必须再完整跑一次构建+测试。禁止 `--no-verify`/删测试装绿，5 轮不过走 `[STALLED]`。详见 [commit.md 第 0 节](references/commit.md)。
4. **规范单一事实源**：coding 与 review 使用同一份冻结在项目内的规范（`openspec/standards/`），review 结论必须引用规则 ID。未冻结规范不得进入 code。
5. **门禁不过不推进，但有重试预算**：校验失败、测试失败、review 有 BLOCKER 时先停在当前阶段修复；**同一问题修复重试 ≤5 轮**（一次「改代码→重跑门禁」算一轮，纯读日志/查文档不计入但也不许无限调查）。第 5 轮仍不过则进入**受阻降级**：
   1. journal 追加 `[STALLED]` 条目：现象、5 轮尝试各自做了什么、根因假设、止血方式、需要人介入的具体事项；
   2. **先止血让编译/构建恢复绿色**：首选 `git stash`/还原本批改动回到最近绿色提交；次选显式跳过失败测试（`@Disabled`/`@pytest.mark.skip`，reason 必填并指向该 journal 条目）或最小桩实现；禁止删断言、空 catch、静默 suppress 后假装通过；
   3. 然后**可以转去做不依赖该问题的其他任务**，但必须先告知用户；没有不相关任务可做时停下等介入；
   4. 受阻 change 在 routing 中持续显示为受阻（未关闭的 `[STALLED]`），后续会话不得忽略；问题解决后补测试、移除 skip、关闭条目。
   细则见 test.md「重试预算与受阻降级」。
6. **如实报告**：命令失败就贴失败信息，不许把没跑过的测试说成通过；改动外的破坏性/对外动作先征得用户同意。
7. **不与 OpenSpec 抢所有权**：proposal/design/tasks/spec delta 只写 OpenSpec 规定格式；本 skill 自己的记录只放 change 下的 `letwork/` 子目录。
8. **语言**：与用户交流、journal、review 报告用中文；proposal/spec 等 OpenSpec 产物遵循项目 `openspec/config.yaml` 的 product language 约定（无约定则中文）。

## 快速恢复上下文

每次进入一个活动 change，先读：`proposal.md`（一句话目标）、`tasks.md`（进度）、`letwork/journal.md`（最近 3 条）、`letwork/commits.md`（已提交到哪），再决定动作。
