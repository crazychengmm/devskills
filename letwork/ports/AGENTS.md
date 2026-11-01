# AGENTS.md — letwork 需求驱动研发流（跨 agent 通用版）

> 本文件供任何读取 AGENTS.md 的编码 agent 使用（Codex、Cursor、Zed、Gemini CLI 等）。
> 用法：复制到目标项目根目录（`cp <devskills>/letwork/ports/AGENTS.md ./AGENTS.md`，或追加到已有 AGENTS.md）。
> 完整阶段细则在 skill 仓库（默认 `~/devskills/letwork/skills/letwork/`，下称 `$LETWORK`），需要时用 Read 读取；本文件自身包含最小可执行规程。

## 你是谁、做什么

当用户要求开发一个需求/功能时，按 letwork 流水线推进：**需求分析 → 任务拆分 → 编码 → 测试 → 评审 → 按任务提交 → 归档复盘**。每个需求是一个 OpenSpec change，全过程产物记录在 `openspec/changes/<change>/` 下。

自然语言触发词（用户不一定用斜杠命令）：「开始这个需求」「分析一下需求」「拆任务」「按规范编码」「跑测试」「评审」「按任务提交」「记录一个问题/复盘」「继续上次的」——分别对应下面的阶段。

## 启动检查（每次进入先做）

1. 是否在 git 仓库内（`git rev-parse --show-toplevel`）。不是则提示用户先 git init。
2. 是否有 `openspec/`。没有：征得同意后运行 `openspec init . --tools <本工具名>`（支持 claude/cursor/codex/gemini/github-copilot/zed/warp 等 40+）；CLI 不可用时按 `$LETWORK/references/bootstrap.md` 手工搭建最小结构。
3. OpenSpec 命令与格式以 `$LETWORK/references/openspec-cheats.md` 为准（真实包名 `@fission-ai/openspec`；npm 上裸 `openspec` 是占位假包）。
4. 用户说「继续」时：读 `$LETWORK/references/routing.md` 的决策表，根据 proposal/tasks 勾选状态、diff、commits 记账推导当前阶段，**说明依据并等用户确认**。

## 阶段规程（门禁不过不推进）

### 1. analyze（需求分析）
- 用 grilling 访谈：把需求建模成决策树，一轮问完当前所有「前置已决」的问题，编号 Q1..Qn，每题给推荐答案（用户答 yes 即采纳）。事实类问题自己查文件/代码，只有取舍类决策问用户。
- 创建 change：`openspec new change <kebab-name> --description "<一句话>"`（**flag 与值间必须有空格**；创建后确认 `.openspec.yaml` 存在）。
- 产出 proposal.md（Why ≥50 字符）、`specs/<capability>/spec.md`（**新 capability 顶部写 `## Purpose`**；需求用 SHALL/MUST，每条至少一个 WHEN/THEN 场景）、design.md（必备，可短）。
- `openspec validate <name>` 通过后请用户确认。
- 细则：`$LETWORK/references/analyze.md`。

### 2. plan（任务拆分）
- 写 tasks.md：任务组 + `- [ ] 1.1 …`，每任务 ≤ 半天、可独立测试，描述后标注覆盖的 requirement；测试与文档是显式任务。
- 每条 requirement 至少被一个任务覆盖；validate 通过后请用户确认。
- 细则：`$LETWORK/references/plan.md`。

### 3. code（编码，一次一个任务）
- 先做工具链预检（解释器/编译器可用），再开工，避免半成品残留。
- **规范门禁**：项目 `openspec/standards/` 为空时，按语言（pom.xml/go.mod/requirements.txt/pyproject.toml 识别）询问用户：采用库存规范（Java 阿里黄山版 / Go Uber / Python Google+PEP8，文件在 `$LETWORK/references/standards/`）/ 自带规范（给路径，转成 checklist）/ 仅通用规范；选定后**复制到 `openspec/standards/` 并写 README 记录来源与冻结日期**。
- 单任务循环：取第一个未勾选任务（用户指定号则用指定）→ 读规范 → 实现（不夹带）→ 机械化自检（见下）→ 人工对照规范 → 勾选 `[x]` → 停下，不自动做下一任务。
- 机械化自检一行命令见 `$LETWORK/references/standards/common.md` 顶部（Python: py_compile+行长/ruff；Go: gofmt+vet+build；Java: mvn compile/checkstyle）。
- 细则：`$LETWORK/references/code.md`。

### 4. test（测试）
- 跑当前任务相关的真实测试（go test / mvn test / pytest / unittest），**判定只看测试进程退出码**：输出重定向到文件再判 `$?`，或 `set -o pipefail`，禁止 `test | head` 让管道吞掉失败。
- 扫描/lint 类工具退出码 1 表示「检出问题」时，显式接 `rc=$?` 并对照预期。
- 命令、结果、覆盖场景记入 change 下 `letwork/journal.md`；失败如实报告并回 code。
- 细则：`$LETWORK/references/test.md`。

### 5. review（评审）
- 第零轴：机械检查（格式/编译/lint）先清零。
- 轴一规范：按项目 `openspec/standards/` 逐条核对 diff，结论引用规则 ID（J-/G-/P-/C- 前缀），级别 BLOCKER/MAJOR/MINOR/INFO（定义见 `$LETWORK/references/standards/review-format.md`）。
- 轴二 spec 一致性：delta 中每个 requirement/scenario 有实现与测试证据；diff 不得有 spec 未声明的超范围行为。
- 再跑 `openspec validate --strict`。报告写入 `openspec/changes/<change>/letwork/review.md`；有 BLOCKER 回 code。
- 没有 change 时只做规范轴，并声明覆盖范围。

### 6. commit（按任务提交）
- **一次提交只对应一个任务；禁止 `git add -A`、`git add .`、`git commit -a`。**
- 提交前 micro-checklist：任务已勾选 ✓ 测试真实为绿 ✓ `git status` 区分本次/不相关文件 ✓ 暂存清单与 commit message 给用户确认 ✓。
- 显式 `git add <文件>`；Conventional Commits（feat/fix/docs/test/refactor/chore…），trailer：
  ```
  Openspec-Change: <change-name>
  Task: <组.号>
  ```
- 独立小步用 `Task: step`；推荐实现与测试分两次提交（同一 Task 号）。不自动 push。
- 每次提交登记 `letwork/commits.md`（任务/文件/SHA/subject）。收尾双向核对：每个 `[x]` 有提交，每行提交能对回任务。
- 细则：`$LETWORK/references/commit.md`。

### 7. retro / archive
- 问题/决策/改进随时追加到 `letwork/journal.md`，TAG：PROBLEM（现象/根因/处理）、DECISION（理由/备选）、IMPROVEMENT（可执行动作）、NOTE。
- 全部任务完成且 review/validate 通过后，归档前做一次汇总复盘，然后经用户同意执行 `openspec archive <name>`（delta 合入 specs/，change 移入 archive/，letwork 记录随归档保留）。

## 交互降级（非 Claude 环境）

- 没有交互式提问 UI 时：在一条消息里列出全部当前问题，编号 Q1..Qn，每题写出推荐答案，让用户按编号回答。
- 没有 Skill 工具时：用户用自然语言或本工具的自定义命令触发；agent 直接读取 `$LETWORK/references/<stage>.md` 执行，等价于调用核心 skill。
- 路径约定：若仓库不在 `~/devskills`，让用户告知实际路径，下文以该路径替换 `$LETWORK`。

## 铁律

1. 事实自查，决策问人；2. 每步留痕；3. 按任务推进与提交；4. coding/review 只用项目内冻结的同一份规范；5. 门禁不过不推进；6. 失败如实报告，不把没跑过的测试说成通过；7. 不自动 push、不做破坏性/对外动作（安装、初始化、归档先征得同意）；8. OpenSpec 产物只写官方格式，本流程私有记录只放 change 下的 `letwork/` 子目录。
