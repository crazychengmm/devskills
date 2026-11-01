# analyze — 需求分析阶段

目标：把一句话需求逼成「边界清晰、场景可验证、capability 划分合理」的 OpenSpec change。方法沿用 grilling 的设计树访谈。

## 1. grilling 访谈（必做，哪怕需求看起来很清楚）

把需求建模成一棵**设计树**：每个决策都分叉出依赖它的子决策。

- **frontier** = 前置条件都已确定、现在就能问的决策集合。一轮问完整张 frontier，编号 Q1..Qn。
- 每个问题给标题、正文（可多段/多选）、以及 `➡️` 推荐答案；措辞让用户回「yes」即采纳推荐。事实类问题自己查（可派子 agent 并行，不阻塞其余问题），**只把取舍/产品决策抛给用户**。
- 一轮结束后等用户回答（可按编号简答），根据回答重算 frontier，进入下一轮。
- frontier 清空且用户确认「需求已经清楚」后才动手写产物。

轮次格式：

```
❓ **Q1 - <标题>**: <问题正文，含选项>
➡️ <推荐答案>

---

❓ **Q2 - <标题>**: ...
➡️ <推荐答案>
```

至少要覆盖（未问到的默认不成立，需在 Non-Goals 显式排除）：

1. 要解决的真实问题/场景与目标用户；成功后什么现象可观察。
2. 范围边界：显式 Non-Goals（这期不做什么）。
3. 输入/输出、异常路径、权限与并发、向后兼容。
4. 可验收的关键场景（happy path + 至少一个失败/边界场景）。
5. 对现有系统的影响面（读代码确认，不让用户口述事实）。

## 2. 创建 change 脚手架

需求方向明确（不需要等访谈完全结束）即可创建，名字用 kebab-case 动宾短语：

```bash
openspec new change <name> --description "<一句话>"
```

**flag 与值之间永远留空格**，创建后立即确认 `.openspec.yaml` 已生成（CLI 不原子：参数粘连时可能只建空目录，重试报 already exists；此时确认无有价值内容后删除重建）。

CLI 不可用时按 openspec-cheats.md 手工建目录与 `.openspec.yaml`（`schema: spec-driven`、`created: <YYYY-MM-DD>`）。同时创建私有目录 `openspec/changes/<name>/letwork/`，从 templates 复制 journal.md，写入分析开始条目。

## 3. 产出物

1. **proposal.md**：Why 写透「问题、为什么现在做、不做会怎样」（50–1000 字符）；Capabilities 一节：
   - 新行为 → New Capabilities，路径是「内聚的系统能力」而非实现任务（反例：`add-user-api`；正例：`user-auth` 或 `identity/user-auth`）；
   - 只是内部实现/重构、无外部行为变化 → 不列 capability，改在 `.openspec.yaml` 设 `skip_specs: true`。
2. **specs/<capability>/spec.md delta**：每个 capability 的需求用 SHALL/MUST 写成可验证条款，每条至少一个 `#### Scenario:`，场景必须有 WHEN/GIVEN 与 THEN；写**可观察行为与契约**，实现机制放 design.md。**新 capability 必须在 delta 顶部写 `## Purpose`**（≥50 字符，一两句话说明该能力为何存在），否则 archive 后主 spec 会留下 `TBD - created by archiving change ...` 占位。
3. **design.md**：OpenSpec 工作流中 design 是 tasks 的前置产物（`openspec status` 中 tasks 依赖 design），所以每个 change 都要写；内容可短，简单需求每个小节一两句即可，但 Context / Goals / Non-Goals / Decisions / Risks 结构保持完整。
4. **journal.md**：每个关键取舍追加 `[DECISION]`；访谈中发现的现状问题追加 `[PROBLEM]`。

## 4. 完成门禁

- `openspec validate <name>` 通过（CLI 不可用时走人工自检清单）。
- 向用户复述：capability 列表 + 每条 requirement 的一句话摘要 + Non-Goals，等明确确认。
- 用户要求改动时迭代 spec 再重新 validate，不带着未确认需求进 plan。
