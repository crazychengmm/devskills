# review — 代码评审阶段

双轴评审 + OpenSpec 校验。评审是独立视角：先读 [standards/review-format.md](standards/review-format.md) 拿到级别定义与报告格式。

## 1. 确定评审范围（diff base）

按优先级确定 base：
1. 分支有上游：`git merge-base HEAD @{u}`（或与主分支的 merge-base）。
2. 单任务评审（最常见）：`letwork/commits.md` 中该任务首个提交之前。
3. 工作树未提交改动：`git diff` + `git diff --staged` + 新文件清单（`git status --short`）。

先打印 `git diff --stat <base>` 与文件清单给用户确认范围，避免漏评或评错。

## 1b. 第零轴：机械化检查（最便宜，先清零）

先跑零思考成本的机械检查，有失败直接退回 code 修复后重跑，不带着机械问题做人工评审：

- Python：`python3 -m py_compile`；行长（awk/ruff/flake8/black --check，阈值按项目配置）；项目有 ruff/flake8 配置时跑全量。
- Go：`gofmt -l .`（必须空输出）、`go vet ./...`、`go build ./...`。
- Java：`mvn -q compile`（或 gradle），项目配了 checkstyle/spotless 必须跑。
- 通用：`git diff --check`（冲突标记/尾随空白）。

> 经验：狗粮测试中 25 处超行长直到评审才发现，本应在 code 的机械化自检拦截。code 没做这道关，本身按 C-GIT-02 记一条流程问题。

## 2. 轴一：规范符合度

- Read 冻结规范（`openspec/standards/common.md` + 涉及语言分册）；若该目录不完整（用户跳过过分册），在报告开头声明覆盖缺口。
- 逐文件过 diff，按 checklist 核对；每条发现引用规则 ID（如 `J-NAMING-01`、`G-ERR-02`、`P-DOC-01`、`C-LOG-01`）。
- 严重级别：BLOCKER（正确性/安全/数据风险、明确违反强制规则）、MAJOR（会埋坑的设计/可维护性问题）、MINOR（风格/局部优化）、INFO（提问与建议）。
- 拿不准的规则冲突（场景无法同时满足两条）写 INFO 并给取舍建议，不擅自判违规。

## 3. 轴二：spec / 场景一致性

对照 change 的 delta spec 逐条核对：

- 每条 `### Requirement:` 在 diff 中有对应实现；每个 `#### Scenario:` 的 WHEN→THEN 有代码路径与测试证据（指出测试文件:用例名）。
- 反向检查：diff 里是否有 spec 未声明的行为变化（超范围实现 / 夹带需求）——有的话要么补 spec（回 analyze 重新 validate），要么从本次改动拿掉。
- tasks.md 中已勾选任务与 diff 是否相符（虚报完成、勾选了但没实现）。

## 4. 校验

```bash
openspec validate <change> --strict
```

CLI 不可用时走 openspec-cheats.md 人工自检清单。失败原样贴出。

## 5. 产出与处置

- 报告写入 `letwork/review.md`（模板见 [templates/review.md](../templates/review.md)），同时在对话给出摘要；journal 追加 `[NOTE] review 完成：BLOCKER n / MAJOR n / MINOR n`。
- 有 BLOCKER → 回 code 修复，修复后重评对应条目（报告保留历史，新报告标注轮次与日期）。
- 全部为零 BLOCKER 且 validate 通过 → 放行 commit/archive；MAJOR 项要逐条得到用户「修」或「挂账」的决定，挂账项写 journal `[IMPROVEMENT]`。
