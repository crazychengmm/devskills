# commit — 分批、选择性、绿色提交

核心铁律：**一次提交只对应一个任务（或用户显式指定的一个简单步骤），禁止 `git add -A`、`git add .`、`git commit -a`。** 不自动 push、不自动合并。

第二铁律（绿色提交）：**任何一个 commit 被 checkout 出来，工程都必须能编译、测试通过。** 半成品、未接线的代码可以留在工作树，但不能进任何一个 commit。

推荐提交粒度：实现（feat/fix/refactor）与测试（test）分两次提交、按「实现先于测试」的顺序，同挂一个 `Task:` 号——这样两个 commit 各自都是绿色的。

## 1. 触发时机（不要被动等待）

- 任务完成 + 机械化自检通过 + 测试为绿后，**主动向用户提出提交方案**（哪几个文件、分几批、每批 message），用户确认后立即执行，不要让用户再追问「怎么不提交」。
- 用户直接调用 `/let-commit` 时，跳过建议直接进入下面的分批与暂存流程。
- 工作树积压多个已完成任务时，一次性规划出**多批提交**，逐批执行，每批独立验证。

## 2. 分批与选择性暂存

1. `git status --short` + `git diff --stat` 盘点全部改动，按任务归属分组：
   - 一个文件只服务一个任务 → 整文件暂存；
   - 同一文件混了多个任务/无关改动 → **只暂存本批的 hunk**，见下；
   - 纯无关改动（格式化、他人的活、调试残留）→ 不带入，提示用户。
2. 分批顺序按依赖关系：基础设施/模型 → 核心实现 → 接线/CLI → 测试 → 文档/示例。测试提交必须在对应实现**之后**（测试先于实现的 commit 是红的）。
3. 部分暂存（同一文件拆任务）的两种方式：
   - 交互式（最稳）：让用户执行 `! git add -p <文件>` 自行选择 hunk；
   - 非交互：`git diff <文件> > /tmp/h.patch` → 编辑 patch 只留本批 hunk → `git apply --cached /tmp/h.patch`。
4. 暂存后用 `git diff --staged --stat` 与用户确认清单和 message，再验证、提交。

## 3. 绿色验证（每批提交前必做）

### 3a. 普通模式（本批文件与工作树其余改动相互独立）

在完整工作树上跑该语言的「编译 + 相关测试」：

| 语言 | 验证命令 |
|---|---|
| Java/Maven | `mvn -q compile && mvn -q test`（改动局部可先 `-Dtest=<类>` 快速反馈，提交前全量） |
| Java/Gradle | `./gradlew build` 或 compileJava + test |
| Go | `gofmt -l .`（空输出）、`go vet ./...`、`go build ./...`、`go test ./... -count=1` |
| Python | `python3 -m py_compile <改动文件>` + `python3 -m unittest discover -s tests`（或 pytest） |
| Node | 以 package.json scripts 为准（build + test） |

判定只看真实退出码：重定向到文件再判 `$?`，或 `set -o pipefail`（见 test.md）。

### 3b. 严格模式（工作树还有未提交的半成品，可能污染验证）

只验证**即将提交的暂存快照**，保证 commit 本身绿色（命令已实测）：

```bash
git stash push --keep-index -m "wip during let-commit"   # 藏起未暂存改动（含未跟踪用 -u）
<跑编译与测试>     # 失败则不允许提交
git commit -m "..."
git stash pop      # 取回未提交工作，继续下一批
```

失败处理：`git stash pop` 取回改动，回到 code 修复，严禁带红提交。**同一问题连修 5 轮仍不过时，不要继续硬试**，按 test.md「重试预算与受阻降级」走：`[STALLED]` 记录 → 止血恢复绿色（还原本批或显式 skip）→ 告知用户后转不依赖任务。

## 4. micro-checklist（每批逐项确认）

1. 对象明确：对应 tasks.md 任务号或用户给的步骤说明；
2. 任务已勾选 `[x]`（勾选意味着编码双自检已过）；漏勾先退回 code 补自检，不靠记忆补勾；
3. 编译 + 测试真实为绿（3a 或 3b）；
4. 暂存清单经用户确认；无无关文件、无游离半成品、无临时生成物（target/__pycache__ 等靠 .gitignore 兜底）；
5. review 节点上 BLOCKER 已清零。

## 5. Commit message 与 trailer

Conventional Commits：`<type>(<scope>): <subject>`，type ∈ feat/fix/docs/style/refactor/test/chore/perf/build/ci；subject 祈使、≤50 字符；body 写「为什么」。末尾：

```
Openspec-Change: <change-name>
Task: <组号.序号>
```

简单步骤模式（`/let-commit <步骤说明>`，且不属于 tasks.md 任务）：`Task: step`。

## 6. 记账（每次提交后立即做，不要攒到最后）

登记到 `letwork/commits.md`：任务/步骤、文件清单、`git rev-parse --short HEAD`、subject。journal 追加 `[NOTE] <任务号> 已提交 <sha>`。

## 7. 收尾双向核对（进入 review/archive 前）

- tasks.md 每个 `[x]` 在 commits.md 至少有一行对应提交；
- commits.md 每一行都能对回已勾选任务或标注了 step；
- 两表不一致先修账。

## 8. 全部任务完成

tasks.md 全勾选、review 无 BLOCKER、`openspec validate --strict` 通过、账本一致后：先 retro 汇总，经用户同意执行 `openspec archive <name>`，归档后告知用户可自行 push（本 skill 永不 push）。
