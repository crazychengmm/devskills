# retro — 复盘与过程记录

可在任意时刻调用（`/let-retro [要记录的内容]`）；也是 archive 前的必经环节。

## 1. journal 记录规则

文件：`openspec/changes/<change>/letwork/journal.md`（从 [templates/journal.md](../templates/journal.md) 初始化）。按时间倒序或正序持续追加，模板二选一后全篇统一。每条：

```markdown
### 2026-11-01 15:40 [PROBLEM] go test 在 macOS 上找不到工具链
- 现象：...
- 根因：...（查不清就写「未定位」+ 已排除项）
- 处理：...
- 改进：<可执行项；没有则省略>
```

TAG 用法：
- `PROBLEM`：过程中遇到的问题/故障/返工。必须含现象、根因（或未定位声明）、处理。
- `DECISION`：技术/范围取舍。必须含决定与理由、被否掉的备选。
- `IMPROVEMENT`：可执行的改进项（自己/流程/工具），写明建议动作，避免空话。
- `NOTE`：阶段流转与普通事实（完成、提交、外部依赖变化）。

规则：即时记录，不攒到最后补；一条只讲一件事；只写事实与可执行结论，不写情绪流水账。

## 2. 归档前汇总复盘

archive 前自动执行一次（若本次 change 已有汇总条目则跳过）：

1. 通读 journal，产出 `## 复盘汇总（YYYY-MM-DD）` 追加到 journal.md：
   - **做得好的**：2–4 条具体做法（可复用，最好能变成 checklist/规范条目）。
   - **踩的坑**：按 PROBLEM 聚合，每条一句话根因。
   - **下次改进**：从 IMPROVEMENT 收敛出 ≤5 条，每条有动作和适用场景。
   - **规范建议**：若发现 coding/review 中反复出现的规范盲区，提议沉淀到项目 `openspec/standards/`（经用户同意再改冻结规范，记录版本变更）。
2. 与用户过一遍汇总，确认无遗漏后才允许 archive。

## 3. 跨 change 的长期改进

单条改进只属于某个 change；当同类 IMPROVEMENT 在两个以上 change 出现，提示用户把它升级为全局约定（写入团队/个人 CLAUDE.md 或规范库新版本），由用户决定。
