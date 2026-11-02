# OpenSpec 原理与多人协同

本文解释 letwork 依赖的 OpenSpec 是怎么组织需求的，以及它为什么天然适合多人并行开发。版本基于 OpenSpec v1.16（命令清单见 `skills/letwork/references/openspec-cheats.md`）。

## 1. 三个核心概念

| 概念 | 是什么 | 类比 |
|---|---|---|
| **spec（规格）** | 系统当前行为的唯一事实源，存在 `openspec/specs/<capability>/spec.md`，只写 SHALL/MUST 条款与 WHEN/THEN 场景 | 已生效的「法律」 |
| **change（变更提议）** | 一次需求/特性的完整工作区，存在 `openspec/changes/<change-name>/`，做需求期间所有产物都在这里 | 一条「提案」+ 工作台 |
| **archive（归档/合并）** | change 完成后把其中的 **delta（增量）** 合并进 specs 主规格，change 目录移入 `changes/archive/YYYY-MM-DD-<name>/` | 提案表决通过，成为法律 |

关键顺序：**先有提案（change），动手改代码；提案归档时才动主规格（specs）。** specs 目录平时几乎不写，这是低冲突的根源。

## 2. change 内部结构（天然的工作隔离单元）

```
openspec/changes/add-vlan-management/
├── .openspec.yaml                  # 元数据（schema/created/goal）
├── proposal.md                     # Why / What / Capabilities / Impact
├── design.md                       # 技术设计、取舍、风险
├── tasks.md                        # 任务清单（勾选驱动进度）
├── specs/<capability>/spec.md      # delta：ADDED/MODIFIED/REMOVED Requirements
└── letwork/                        # letwork 私有产物（不参与 validate）
    ├── preview.md                  # 方案预览（v0.10）
    ├── journal.md                  # 过程留痕（追加型）
    ├── review.md                   # 评审报告
    └── commits.md                  # 提交账本
```

delta 只描述「这次要加/改/删哪些需求」，不是完整规格：

```markdown
## ADDED Requirements
### Requirement: 创建 VLAN
系统 SHALL 支持以 vlanId（1–4094）创建 VLAN……
#### Scenario: 越界被拒绝
- **WHEN** 提交 4095
- **THEN** 返回 400
```

归档时这些 delta 被拼进 `openspec/specs/<capability>/spec.md`，主规格随之长大。

## 3. 为什么适合多人并行：写时机决定冲突概率

冲突的本质是「多人在同一时间写同一文件」。OpenSpec 把不同内容的**写时机错开**了：

| 内容 | 变更时机 | 冲突概率与处理 |
|---|---|---|
| `changes/<各自change>/` | 做需求期间 | **极低**：一个 change 对应一个特性分支，目录以 change 名隔离，互不碰对方文件，和「不碰别人的包」一个道理 |
| `letwork/journal.md` 等 | 同 change 内持续追加 | 仅在多人同时做**同一个** change 时；纯追加日志型文件，冲突解决就是**两边条目都保留** |
| `standards/`（冻结规范） | 首次冻结，之后极少改 | 改规范本来就该团队评审后统一升级；真撞了说明两人同时在改标准，冲突反而是提醒信号 |
| `openspec/specs/`（主规格） | **只在 archive 时**由 delta 合并写入 | 只有两个 change 同时归档且改同一 capability 才撞；`openspec validate --strict` 会暴露结构问题，手工解 git 冲突后重新 validate |
| 业务代码 | 全程 | 按模块/包归属与正常 code review 流程，OpenSpec 不改变代码冲突规律，但 spec 提前明确了边界，减少「改同一块逻辑」的概率 |

## 4. 推荐的多人工作流

### 4.1 一个特性一个分支 + 一个 change（最常见）

```
main
 └─ feat/vlan   ← 对应 changes/add-vlan-management/（只在此分支存在/活跃）
 └─ feat/audit  ← 对应 changes/add-audit-log/
```

1. 开发者从 main 切分支，`openspec new change <name>` 只在自己分支创建 change 目录；
2. 各自在 `changes/<自己的>/` 里写 proposal/design/tasks/delta 与代码，**物理上碰不到对方的文件**；
3. PR 合入 main 后（或合入时 CI 跑 validate），在 main 上执行 archive，delta 进主规格。

> change 在分支未合入前不必 archive；谁先合谁先 archive，后合的分支 rebase 后再 archive。

### 4.2 并行改不同 capability

完全无冲突：A 改 `vlan-management`、B 改 `ip-allocation`，delta 路径不同，归档各写各的 spec 文件。

### 4.3 并行改同一 capability（需要协调，但有护栏）

两人的 change 都给 `specs/vlan-management/spec.md` 加需求：

- 做需求期间：仍在各自 change 目录，不冲突；
- 归档时：先归档的合入 main，后归档的分支 rebase main 后，其 delta 仍描述「新增需求」，通常能干净合入；
- 若两人 **MODIFY/REMOVED 同一条 Requirement**：这是真正的语义冲突，validate 与评审会暴露——此时应该在 change 阶段就通过 proposal 评审发现「两个人在改同一条款」，合并提案或排队。

护栏命令：

```bash
openspec validate <change> --strict   # 归档前后都跑，delta 引用了不存在的需求会报错
openspec list                         # 看当前有哪些进行中的 change
openspec status --change <name>       # 看产物完成度
```

### 4.4 多人协作同一个 change（结对/接力）

同一个 change 目录在同一分支上，天然会并发改 `tasks.md`/代码：

- `tasks.md`：各勾各的任务号，git 冲突时按任务行合并（都是 `- [x] N.M` 行级改动）；
- `journal.md`：**纯追加**，冲突时两边条目全部保留，按时间排序即可，绝不丢弃任何一方的 `[PROBLEM]/[DECISION]/[STALLED]`；
- `review.md`：多轮评审用 append（git notes 同理 `--ref=review append`）；
- `commits.md`：账本各登记各的 SHA，合并时并列保留。

### 4.5 规范（standards/）升级

规范是团队共识，不是个人草稿：

- 冻结后只允许「提 PR → 评审 → 统一升级」，不随手改；
- 两人同时改 `openspec/standards/` 出现 git 冲突时，**停下开会对齐**，不要各改各的——这正是设计上的提醒信号；
- 升级后受影响的存量代码按新规则开 change 整改，与新需求解耦。

## 5. 归档冲突的具体处理

唯一会写主规格的时机是 archive。若 `git merge/rebase` 在 `openspec/specs/<cap>/spec.md` 冲突：

1. `openspec validate --strict` 先看结构错误（delta 引用缺失、格式不符）；
2. 手工解 git 文本冲突：两个 delta 通常都是「追加 Requirement」，把两边的 Requirement 块都保留、去重（同 ID 同内容）；
3. 重新 `openspec validate --strict` 直到通过；
4. 跑测试确认行为与合并后的 spec 一致；
5. 在 journal 记录这次语义合并的决定。

原则：**delta 冲突先问「是不是同一行为被定义了两次」，是的话归一；只是新增不同行为，并列保留。**

## 6. CI 里建议的校验

| 时机 | 命令/检查 |
|---|---|
| PR 流水线 | `openspec validate --strict --all`（或校验 PR 涉及的 change） |
| 有代码改动 | 正常 build/test + p3c/ruff 等规范机械检查 |
| spec 一致性 | 评审轴二：delta 的每个 Scenario 有代码与测试证据 |
| 归档动作 | 仅在 main 执行，归档提交单独成 commit |

## 7. letwork 在协同中的位置

letwork 不改变上述模型，只是把「每个 change 该怎么推进」标准化：

- **路由**（`/letworkstart`）靠 change 目录与 tasks 勾选状态判断进度，新成员接手分支即可知道停在哪；
- **journal** 是跨人交接的记忆：为什么这么决定、踩过什么坑、什么问题 `[STALLED]` 等人介入；
- **review.md + git notes**：评审结论既随代码存档（review.md），又挂在提交上（notes，可选）；
- **commits.md**：任务↔提交的账本，多人提交也能审计每个任务是否绿色；
- **冻结规范**保证所有人 coding/review 用同一份 checklist，避免「我以为的规范」。

一句话总结：**change 目录按特性物理隔离使并行几乎零冲突，主规格只在归档单点写入把冲突收敛到可控时刻，追加型记录全部「两边都留」——协同问题主要靠目录约定解决，而不是靠工具锁。**
