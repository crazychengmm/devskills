# 路由决策表（route 模式）

目标：只根据仓库可观察状态，推导出当前应处阶段。**推导结果必须附依据，并等用户确认后再进入**；用户可强制指定阶段（stage 模式）。

## 第 1 步：收集现状（只读命令）

```bash
git rev-parse --show-toplevel                 # 是否 git 仓库
ls openspec                                   # 是否已初始化
openspec --version 2>/dev/null                # CLI 是否可用（npx @fission-ai/openspec --version 备选）
openspec list --json 2>/dev/null              # 活动 change 列表（排除 archive/）
git status --short                            # 工作树改动
git log --oneline -10                         # 最近提交（看任务提交节奏）
```

若只有一个活动 change，进入第 2 步；多个则列出让用户选（展示 change 名 + tasks 完成数 + 最近 journal 时间）。

## 第 2 步：单个 change 的阶段推导

对 `openspec/changes/<change>/` 按下表自上而下匹配，命中第一个未满足的行即为当前阶段：

| # | 检查 | 未满足 → 路由到 |
|---|---|---|
| 1 | `proposal.md` 的 `## Why` 已填写且非模板（≥50 字符），且 `specs/**/spec.md` 至少一个 delta 含 ADDED/MODIFIED Requirement（或 `.openspec.yaml` 有 `skip_specs: true`） | **analyze** |
| 2 | `tasks.md` 存在且含至少一个 `- [ ]`/`- [x]` 任务 | **plan** |
| 3 | `tasks.md` 中第一个未勾选任务尚无对应实现（对照 `letwork/commits.md` 与工作树） | **code** |
| 4 | 工作树有未提交的代码改动，且当前任务在 `journal.md` 无通过的测试证据 | **test** |
| 5 | 当前任务有提交（或待提交）但 `letwork/review.md` 不存在/结论含未修复 BLOCKER | **review** |
| 6 | 工作树有未提交改动，或已勾选任务数 > commits.md 中记账的任务提交数 | **commit** |
| 7 | **反向异常**：commits.md 有任务提交但 tasks.md 对应条目仍未勾选 | 回 **code** 核对（漏勾则补自检后勾选，虚报提交则修账），不许直接进下一步 |
| 8 | 仍有未勾选任务 → 回到 **code**（下一任务）；全部勾选、tasks↔commits 双向核对一致、review/`openspec validate --strict <change>` 通过 | 提议 **archive**（归档前先过一遍 retro） |

补充信号：
- **多个活动 change 时的选择**：默认列出让用户选；用户已明确授权自主推进（「不用问我」「你决定」等）时按确定性规则选，不随机：① 存在 `[STALLED]` 的 change 先处理受阻；② 否则选**创建最早**的（`openspec list` 顺序 + `.openspec.yaml` 的 created）；③ 创建时间相同选进度最靠后的（离完成近优先收尾）。在对话中声明选择依据，仍把其余 change 列出来供用户随时切换。
- **受阻优先**：journal 中存在未关闭的 `[STALLED]` 条目时，路由结果直接显示「受阻」：说明卡点与待人为介入事项，询问用户是①已解决（验证后关闭条目并回到原任务）、②先做其他不依赖任务，不允许忽略 STALLED 当作正常推进。
- `openspec status --change <name> --json` 给出机器可读状态（v1.16 实测字段）：`artifacts[]`（id=proposal/specs/design/tasks，status=ready/blocked/done）、`isPlanningComplete`、`isComplete`、`applyRequires`、`nextSteps`。用它交叉验证表中第 1–2 行；注意 **tasks 依赖 specs 与 design 都 done**。
- `openspec list --json` 的 `changes[].completedTasks/totalTasks/status/lastModified` 可用于多 change 列表展示。
- design.md 是工作流必备产物（可短但不可缺）。
- `letwork/journal.md` 最近条目标注的阶段仅作提示，不作路由依据（以产物状态为准）。

## 输出格式

```
我检查到：<关键事实 3-5 条，带数据>
判断当前应在：<阶段>（依据：上表第 N 行 + 具体观察）
回复「继续」进入，或直接说你想做的阶段/其他事。
```

## 特殊情形

- **无 openspec/ 目录**：先读 bootstrap.md 走初始化，完成后回到 analyze。
- **无活动 change、用户在命令里带了需求描述**：直接进 analyze；需求逼问清楚后再创建 change。
- **活动 change 已归档但 specs 想继续迭代**：这是新需求，创建新 change（analyze），不要翻改 archive/。
- **纯重构/纯文档任务**：允许 `skip_specs: true`，analyze 只产出 proposal + design，路由表第 1 行的 delta 条件相应豁免。
