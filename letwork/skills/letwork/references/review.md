# review — 代码评审阶段

三轴评审（规范 / spec 一致性 / 设计模式优化）+ OpenSpec 校验，结论写入 git notes。先读 [standards/review-format.md](standards/review-format.md) 拿到级别定义与报告格式。

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

## 3b. 轴三：设计模式优化（建议项，不阻断）

规范轴回答「是否违规」，spec 轴回答「是否做对了需求」，本轴回答「**能不能设计得更好**」。只给有实际收益的建议，级别统一为 SUGGESTION，不制造 BLOCKER/MAJOR；同时做反向检查——不为套模式而过度设计（YAGNI）。

按以下清单观察 diff（跨语言通用，命名以 Java 习惯举例）：

| 观察到的信号 | 可考虑的模式/手段 |
|---|---|
| 三处及以上近似代码、复制修改 | 提取方法/类（DRY）、模板方法 |
| 按类型/字符串的长 if-else、switch 分发 | 策略模式 + 注册表、多态、枚举行为 |
| 对象构造参数多、有多种合法组合 | Builder；创建条件复杂 → 工厂 |
| 方法既改状态又做决策又格式化输出 | 单一职责拆分；领域逻辑从 controller 下沉 service/domain |
| long/String 等原始类型承载领域概念（IP、金额、CIDR） | 值对象（小类型 + 行为内聚，参考 Cidr） |
| 到处判空/空集合分支 | Optional、空对象 |
| 线性扫描热点、可预先排序的数据 | 有序集合/索引、TreeSet 间隙查找 |
| 跨层 new 具体实现、难以测试替换 | 依赖注入到接口 |
| 同步轮询/回调嵌套 | 事件/观察者（仅在确有解耦收益时） |

每条建议写清：**位置（文件:行）→ 观察 → 建议的模式/重构 → 预期收益（可读性/扩展性/性能）→ 成本估计**。没有像样的优化点就明说「无」，**禁止凑数**。用户对每条建议选：采纳（回 code 作为新任务）/挂账（journal `[IMPROVEMENT]`）/拒绝（注明理由或标注 YAGNI）。

## 4. 校验

```bash
openspec validate <change> --strict
```

CLI 不可用时走 openspec-cheats.md 人工自检清单。失败原样贴出。

## 5. 产出、git notes 备注与处置

### 5.1 完整报告

写入 `letwork/review.md`（模板见 [templates/review.md](../templates/review.md)，含三轴 + 设计建议区），对话给出摘要。

### 5.2 git notes 备注（可选项，用户选择才做）

完整报告 `letwork/review.md` 是**默认且必须**的产出。是否额外把摘要写进 git 备注由用户决定，不强制：

- 评审开始时确认：「是否把评审摘要写到 git notes（挂在被评审提交上，不进代码树、不改哈希）？」用户明确要才做；没有要求就只写 review.md。
- 同理，发到 GitHub/GitLab PR 评论（`gh pr review --comment`）也是可选项，需要 `gh` 已登录且用户明确要求。

用户选择 git notes 时，把**评审摘要挂到被评审范围的 HEAD 提交**（git 原生备注，不进代码树、不改提交哈希）：

```bash
# 首次添加；同一提交再次评审改用 append（保留历次轮次）
git notes --ref=review add -F <摘要文件> <被评审HEAD>
git notes --ref=review append -F <摘要文件> <被评审HEAD>
# 查看与列出
git notes --ref=review show <sha>
git notes --ref=review list
```

- 备注内容（精简，约 10–20 行）：评审日期与轮次、被评审范围（base..HEAD）、结论（BLOCKER/MAJOR/MINOR/SUGGESTION 计数）、validate 结果、测试结果、**设计建议条数与一句话列表**、完整报告路径（change 下 `letwork/review.md`）。格式见 review-format.md 的「git notes 摘要格式」。
- notes 默认不随普通 push/clone 传播（它是独立 ref `refs/notes/review`，不是分支提交）；需要远端可见时显式推送：`git push origin refs/notes/review`（仍需用户同意，不自动推）。
- **持久性提醒**：归档检查时若本次评审写了 notes，提醒用户两件事：① 新机器/新克隆要取回备注需 `git fetch origin refs/notes/review:refs/notes/review`；② 不推远端的 notes 只存在本地，机器故障会丢——重要评审摘要同时已保存在 change 的 `letwork/review.md`（随代码提交），notes 只是提交上的便捷索引，不是唯一存档。
- notes 挂在「被评审的那个提交」上；归档产生的新提交不会自动继承，如需给归档提交也挂备注，对新 sha 再 append。
- 发了 notes 时 journal 记录 `…，notes 已挂 <短sha>`；没发就不写这句，不把 notes 当作必做项。

### 5.3 处置

- 有 BLOCKER → 回 code 修复，修复后重评对应条目（review.md 保留历史，新报告标注轮次与日期；notes 用 append 追加新一轮）。
- 零 BLOCKER 且 validate 通过 → 放行 commit/archive；MAJOR 与 SUGGESTION 逐条得到用户「修 / 挂账 / 拒绝」决定，挂账写 journal `[IMPROVEMENT]`。
