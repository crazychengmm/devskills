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

## 2a. 关联既存欠债（仅既存项目）

若 `openspec/letwork/debt-backlog.md` 存在，在访谈收敛后、写预览前：按本次需求涉及的模块/文件匹配 DEFERRED 或 OPEN 条目，列出相关欠债询问用户是否本次一起修（这是用户的明确要求：相关联模块开发时一起改）。同一 change 内对同一条只问一次；用户仍选择暂缓就更新「上次回顾日期」，不纠缠。决定一起修的条目状态改 `FIXING-随<change>处理` 并纳入任务；不改代码的纯记录不影响绿色门禁。

## 2b. 方案预览先行，确认后再细化（省 token 机制）
任何**非平凡**产物（多模块/多步骤/有多种设计可能的需求）在写正式文档与代码之前，先产出一份**轻量方案预览**给用户确认，再展开细节。顺序固定为：

```
grilling 访谈收敛 → 方案预览（Markdown + Mermaid，轻量）→ 用户确认/改方向
   → 正式 proposal/design/spec/tasks（细） → code
```

1. **预览内容（控制篇幅，能一页看完）**：
   - 目标与范围：做什么、不做什么（Non-Goals）；
   - **Mermaid 流程图/时序图/分层图**：主链路与关键异常路径；有数据结构时给核心模型关系图；
   - 模块/分层草图：组件名 + 一句话职责 + 依赖方向（不写完整代码，最多接口签名或伪代码片段）；
   - 关键取舍：2–4 个，每个一句话「选项 → 推荐 → 理由」；
   - 风险与待确认点。
2. **先写预览文件**：`openspec/changes/<name>/letwork/preview.md`（Markdown，Mermaid 用 ```mermaid 代码块），在对话给出链接与摘要。
3. **明确等确认**：询问「方向是否 OK / 要调整哪里」。用户没确认前**不写正式 spec、不拆细任务、不写代码**。
4. **用户改方向时只改预览**（预览改动便宜），再次确认；确认后预览作为 proposal/design 的骨架展开，并在 design.md 开头引用 preview.md。
5. 平凡需求（单函数 bugfix、文案、用户已在访谈中把方案说到实现级）允许跳过预览，直接说明「需求简单，跳过预览」。
7. **同栈/同域增量可精简预览**：技术栈与既有项目一致且只是加一个内聚能力（如已验证的 Spring Boot 项目再加一个域）时，预览可省略 Mermaid 主流程图与分层草图（复用已知架构），只保留「与现状的差异 + 本能力特有的取舍/风险」；全新领域或跨栈仍给完整预览。判断依据：读代码确认是否真同栈，不要凭项目名假设。
6. 报告类产物同理：评审/调研/扫描的**正式长报告**前，先给「将包含哪些章节、预计格式（表格/JSON/Mermaid）」的提纲，确认结构后再产出全文。

> 目的：错方向时浪费的是一份一页预览，而不是一套 spec + 实现 + 测试。

Mermaid 自检（写完预览顺手做）：代码围栏 ``` 必须成对；流程图首行为 `flowchart TD/LR`；每条边含 `-->`、方括号/花括号配对、边标签 `|文字|` 成对出现；图中声明的节点都应被边引用（无孤儿节点）。装有 mermaid-cli 时可 `mmdc -i <文件> -o /tmp/p.svg` 真实渲染兜底。

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
