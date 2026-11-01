# commit — 按任务提交阶段

核心铁律：**一次提交只对应一个任务（或用户显式指定的一个简单步骤），禁止 `git add -A` / `git add .` / `git commit -a`。** 不自动 push、不自动合并。

推荐提交粒度：**实现（feat/fix/refactor）与测试（test）分两次提交**，都挂同一个 `Task:` 号——回滚、review、cherry-pick 时能分开处理；一个任务跨多次提交时在 commits.md 逐行登记，双向核对按任务号聚合即可。

## 1. 提交前检查（micro-checklist，逐项确认）

1. 明确本次提交对象：当前任务号（与 tasks.md、journal 对齐）或用户给的步骤说明。
2. **任务已勾选**：对应 tasks.md 条目是 `[x]`（勾选意味着编码双自检已过）。发现「代码写完提交了但忘勾选」时，退回 code 补自检再勾选，不靠记忆补勾。
3. **测试真实为绿**：测试进程退出码为 0（扫描/lint 类为其预期码），且不是被管道吞掉的假绿（见 test.md 退出码纪律）。
4. `git status --short` 列出全部改动，按任务范围分成「本次提交 / 不相关」。
5. 不相关改动：提示用户，另开任务或另行提交，绝不顺手带入；半成品/游离文件（失败尝试残留）先清理。
6. 门禁：该任务测试已过（test 阶段）；处于 review 节点时 BLOCKER 已清零。未完成的任务文件不提交。

## 1b. change 收尾双向核对（进入 review/archive 前）

- tasks.md 每个 `[x]` 条目在 commits.md 至少有一行对应提交；
- commits.md 每一行都能对回一个已勾选任务或明确标注 `Task: step`；
- 两表对不上（有勾选无提交 / 有提交无勾选）时先修账，不进 review。

## 2. 显式暂存并确认

只按文件路径显式暂存：

```bash
git add path/foo.go path/foo_test.go
git status --short && git diff --staged --stat
```

把「将提交的文件 + commit message 草稿」完整展示给用户，得到明确确认后再执行 commit。

## 3. Commit message 格式

Conventional Commits：`<type>(<scope>): <subject>`，type ∈ feat/fix/docs/style/refactor/test/chore/perf/build/ci；subject 用中文或项目既有语言，祈使、≤50 字符。body 说明「为什么」与关键取舍。末尾 trailer：

```
Openspec-Change: <change-name>
Task: <组号.序号>
```

简单步骤模式（`/let-commit <步骤说明>`，且步骤不属于 tasks.md 任务）：Task 行写作 `Task: step`，subject 直接用步骤说明；同样要记账。

示例：

```
feat(auth): 登录失败返回统一 401 错误体

Openspec-Change: add-login-rate-limit
Task: 2.1
```

## 4. 记账（每次提交后必做）

把结果登记到 `letwork/commits.md`（模板见 [templates/commits.md](../templates/commits.md)）：任务/步骤、文件清单、`git rev-parse --short HEAD`、message subject、时间。journal 追加 `[NOTE] <任务号> 已提交 <sha>`。

## 5. 多任务积压时

若工作树积压了多个任务的改动：按任务逐个「选文件 → 确认 → 提交 → 记账」循环，宁可多次小提交。无法从文件层拆分（同一文件被多个任务交织修改）时，如实告知用户，建议的最粗粒度是「一个任务组一次提交」，并在 body 列出任务号，仍需用户确认。

## 6. 全部完成时

tasks.md 全部勾选、review 无 BLOCKER、`openspec validate <change> --strict` 通过、commits.md 无遗漏后：
1. 若没做过归档前复盘，先走 retro；
2. 询问是否 `openspec archive <change>`（经同意再执行，可用 `-y`）；
3. 归档后验证 change 已移入 `changes/archive/YYYY-MM-DD-<name>/`、delta 已合入 specs/，告知用户可自行 push（本 skill 不 push）。
