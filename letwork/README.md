# letwork — 基于 OpenSpec 的需求驱动研发流 Skill

一套 Claude Code 个人 skill：把「需求分析 → 任务拆分 → 编码 → 测试 → 评审 → 按任务提交 → 归档复盘」串成由 [OpenSpec](https://github.com/Fission-AI/OpenSpec) 管理的流水线。

- **需求分析**用 grilling 式轮次访谈（设计树 / frontier）把一句话需求逼到边界清晰、场景可验收。
- **编码与评审共用同一份冻结的代码规范**（内置阿里 Java 黄山版 / Uber Go / Google Python 库存规范）。
- **代码按任务维度逐个提交**，一个任务一次 commit，不允许一次性全量提交。
- **每一步都留痕**：问题、决策、改进、评审报告、提交账本都记录在对应需求目录下。
- 可以走完整流水线（`/letworkstart` 自动路由），也可以**只单独使用其中任意一步**（见下文「用法二」）。

---

## 目录

- [命令一览](#命令一览)
- [安装](#安装)
- [快速开始（5 分钟全流程）](#快速开始5-分钟全流程)
- [用法一：完整流水线（自动路由）](#用法一完整流水线自动路由)
- [用法二：单独使用某一步](#用法二单独使用某一步)
- [每个需求（change）的产物](#每个需求change的产物)
- [代码规范库](#代码规范库)
- [阶段与门禁](#阶段与门禁)
- [架构](#架构)
- [OpenSpec 原理与多人协同](docs/openspec-collaboration.md)
- [其他 agent（Cursor / Codex 等）能用吗](#其他-agentcursor--codex-等能用吗)
- [依赖与降级](#依赖与降级)
- [验证记录（狗粮测试）](#验证记录狗粮测试)
- [FAQ / 故障排查](#faq--故障排查)
- [版本记录](#版本记录)

---

## 命令一览

| 命令 | 作用 | 单独使用的最低前置 |
|---|---|---|
| `/letworkstart` | 总入口：检查仓库现状，自动路由到当前阶段（可随时中途续跑） | git 仓库 |
| `/let-analyze [需求描述]` | 需求分析：grilling 访谈 → proposal + spec delta + design | git 仓库（无 openspec 会引导初始化） |
| `/let-plan` | 任务拆分：生成可独立实现/测试/提交的 tasks.md | 已有确认过的 change |
| `/let-code [任务号]` | 编码：一次一个任务，开工前冻结代码规范，机械化自检 | tasks.md 存在 |
| `/let-test` | 运行当前任务相关测试并记录真实证据 | 当前任务已有实现 |
| `/let-review` | 双轴评审：代码规范符合度 + spec/场景一致性 | 有提交或待评审 diff |
| `/let-commit [步骤说明]` | 按任务提交（禁止全量 add）；带步骤说明时为简单步骤单提 | 有已完成的任务/步骤 |
| `/let-retro [内容]` | 记录问题/决策/改进；归档前自动汇总复盘 | 无（随时可用） |

---

## 安装

### 1. 前置要求

| 依赖 | 必需性 | 说明 |
|---|---|---|
| git | 必需 | 所有流程在 git 仓库内进行 |
| Claude Code | 必需 | skill 运行环境 |
| Node.js ≥ 22.12 | 安装 OpenSpec CLI 时需要 | `node --version` 检查 |
| OpenSpec CLI | **推荐但非必需** | 提供 change 脚手架、validate、archive；缺失时 skill 降级为手工维护产物（见[依赖与降级](#依赖与降级)） |

安装 OpenSpec CLI（三选一）：

```bash
# 方式 A：npm（注意真实包名，裸 openspec 是占位假包）
npm install -g @fission-ai/openspec@latest

# 方式 B：Homebrew
brew install openspec

# 方式 C：官方脚本
curl -fsSL https://openspec.dev/cli/install.sh | sh
```

验证：`openspec --version`（应输出 ≥ 1.16）。

### 2. 获取 skill 并安装

```bash
# 克隆（确保你的 SSH 公钥已加到 GitHub 账号；HTTPS 亦可）
git clone git@github.com:crazychengmm/devskills.git
cd devskills/letwork

# 一条脚本完成软链安装，并打印安装的版本号
bash ports/claude/install.sh
```

输出示例：

```text
✓ letwork v0.5.1 已安装
  安装位置: ~/.claude/skills（9 个命令，软链模式）
  生效方式: 新开 Claude Code 会话后输入 /let 验证补全
```

如果仓库已在本地（开发模式），重跑同一脚本即可，幂等安全。

**只装部分命令**：软链是按目录独立的，不需要哪个就不链哪个。例如只想要评审和提交两步：

```bash
ln -sfn "$PWD/skills/letwork"    "$HOME/.claude/skills/letwork"
ln -sfn "$PWD/skills/let-review" "$HOME/.claude/skills/let-review"
ln -sfn "$PWD/skills/let-commit" "$HOME/.claude/skills/let-commit"
```

> 注意：8 个 `/let-*` 命令都是薄包装，真正的规程在核心 `letwork` 里，所以任何 `/let-*` 都必须同时安装 `letwork`。

### 3. 验证安装

1. 新开一个 Claude Code 会话（软链在新会话被扫描）。
2. 输入 `/let` 应能补全出 `/letworkstart`、`/let-analyze` 等 9 个命令。
3. 在任意 git 仓库内运行 `/letworkstart`，它会开始做启动检查与路由。

### 4. 确认版本、升级与卸载

```bash
# 确认本地安装的版本（版本号唯一事实源：核心 SKILL.md 的 frontmatter）
grep '^version:' ~/.claude/skills/letwork/SKILL.md

# 升级：拉取最新版后重跑安装脚本（软链不变时可省略），脚本会打印新版本号
cd devskills && git pull && bash letwork/ports/claude/install.sh
```

升级生效规则（解决「pull 了但好像没变」）：

- 软链指向仓库文件，`git pull` 后**磁盘内容立即更新**，无需重新建链；
- 但**已经打开的会话可能持有旧内容**——升级后请**新开一个会话**再验证版本号；
- 在会话中直接问「letwork 当前是什么版本」，agent 会读取 SKILL.md 顶部版本行回答。
# 卸载：删除软链
rm ~/.claude/skills/letwork ~/.claude/skills/letworkstart \
   ~/.claude/skills/let-analyze ~/.claude/skills/let-plan \
   ~/.claude/skills/let-code ~/.claude/skills/let-test \
   ~/.claude/skills/let-review ~/.claude/skills/let-commit \
   ~/.claude/skills/let-retro
```

---

## 快速开始（5 分钟全流程）

```bash
mkdir my-feature && cd my-feature && git init
```

然后在 Claude Code 中：

```
你：/letworkstart 我想做一个把 Markdown 转成 HTML 的小工具
```

接下来会发生的事：

1. 首次使用自动引导 `openspec init`（需要你确认）。
2. **analyze**：Claude 一轮给出几个带推荐答案的问题（输入形式？转义策略？CLI 还是库？），你按编号回答或直接补充；确认后生成 proposal / spec delta / design，自动跑 `openspec validate`。
3. **plan**：生成带任务组的 tasks.md，每个任务标注覆盖的 requirement。
4. **code**：首次编码前询问代码规范（Python 项目默认推荐 Google Python + PEP8），冻结到 `openspec/standards/`；然后一次只做一个任务，完成后机械化自检（编译/行长/lint）。
5. **test**：运行测试，只认真实退出码，证据记入 journal。
6. **review**：机械检查（第零轴）+ 规范轴（引用规则 ID）+ spec 场景一致性轴。
7. **commit**：展示暂存清单等你确认，一个任务一次提交，自动登记 commits.md。
8. 全部任务完成后 **retro 复盘 → openspec archive**，spec 合入主干，过程记录随归档保留。

中途随时关掉会话都没关系——下次进来再跑 `/letworkstart`，它根据产物状态判断你停在哪一步。

---

## 用法一：完整流水线（自动路由）

`/letworkstart` 读取仓库可观察状态推导当前阶段，依据包括：是否有 openspec、有几个活动 change、proposal/spec/tasks 完成度、未勾选任务数、工作树 diff、测试证据、review 结论、commits 记账。它会**把判断依据摆给你看并等你确认**，不会擅自跳转。

典型使用时机：

- 「继续昨天的需求」——不知道自己停在哪一步时；
- 一个需求中途接手；
- 只想让它告诉我现在该干嘛。

---

## 用法二：单独使用某一步

每个 `/let-*` 都可以脱离完整流程单独使用——它们跳过路由，直接执行对应阶段的规程（含该阶段自己的前置门禁，不满足会停下来告诉你）。

### `/let-analyze [需求描述]`

- **什么时候单用**：已有项目里冒出一个新需求，只想先把需求理清楚、落成文档，暂不拆任务。
- **行为**：没有 openspec 时先引导初始化；grilling 访谈后创建 change 并产出 proposal/spec delta/design，跑 validate。
- **示例**：`/let-analyze 给现有的导出接口加 CSV 格式`
- **产出后可停**：change 留在 `openspec/changes/`，以后 `/let-plan` 或 `/letworkstart` 接续。

### `/let-plan`

- **什么时候单用**：需求（proposal + spec）已经和团队确认，只要拆任务。
- **前置门禁**：存在通过 validate 的活动 change；不满足会退回 analyze。
- **产出**：任务组 + 每条任务 ≤ 半天、可独立测试、标注覆盖的 requirement。

### `/let-code [任务号]`

- **什么时候单用**：tasks.md 已存在（手写的也行），只想让它按规范实现某一个任务。
- **行为**：
  1. 首次使用若项目没有冻结规范，会弹窗让你选：库存规范（按语言推荐）/ 自带规范（给路径）/ 仅通用规范；
  2. 只做指定任务号（不指定则取第一个未勾选任务），**不会自动连续做下一个**；
  3. 完成后先跑机械化自检（Python: py_compile/行长或 ruff；Go: gofmt/vet/build；Java: mvn compile/checkstyle），过了才勾选任务。
- **示例**：`/let-code 2.1`

### `/let-test`

- **什么时候单用**：代码写完了，只想让它跑测试并留下证据。
- **行为**：按项目语言选真实命令（go test / mvn test / pytest / unittest），失败如实贴报错并回到编码；测试输出重定向判退出码，不会被管道吞掉。

### `/let-review`

- **什么时候单用**：提 PR 前只想做一次正式评审，即使需求文档不是用 letwork 写的。
- **行为**：
  - **第零轴**机械检查（格式/编译/lint）先清零；
  - **轴一 规范符合度**：按项目 `openspec/standards/` 冻结规范逐条核对，结论引用规则 ID（如 `J-ERR-02`、`P-LINE-01`）；规范未冻结时先走一次规范选择；
  - **轴二 spec 一致性**：需要有活动 change（对照 delta 中的 requirement/scenario 检查实现与测试证据）；**没有 change 时只做规范轴**，并在报告中声明覆盖范围。
- **示例**：`/let-review`（评审自分支基点以来的全部 diff）

### `/let-commit [步骤说明]`

- **什么时候单用**：只想让它帮你做规范的任务维度提交，哪怕代码不是它写的。
- **铁律**：只显式暂存当前任务的文件（禁止 `git add -A/.`），提交前展示清单等你确认，Conventional Commits + `Openspec-Change`/`Task` trailer，提交后登记账本；不自动 push。
- **简单步骤模式**：给一句说明即为与 tasks.md 无关的独立小步提交，如 `/let-commit 修复空指针`，trailer 记 `Task: step`。

### `/let-retro [内容]`

- **什么时候单用**：任何时候——踩了个坑、做了个重要取舍、想到一条改进，都可以随时记录。
- **行为**：按 PROBLEM / DECISION / IMPROVEMENT / NOTE 四类追加到当前 change 的 `letwork/journal.md`；change 归档前会被要求做一次汇总复盘。

---

## 每个需求（change）的产物

```
openspec/changes/<change-name>/
├── .openspec.yaml                 # OpenSpec 元数据
├── proposal.md                    # Why / What Changes / Capabilities / Impact
├── design.md                      # Context / Goals / Non-Goals / Decisions / Risks
├── tasks.md                       # 任务组与勾选状态（勾选=已自检）
├── specs/<capability>/spec.md     # delta：SHALL 需求 + WHEN/THEN 场景
└── letwork/                       # 本 skill 私有目录（随归档保留，不参与 validate）
    ├── journal.md                 # 过程留痕（PROBLEM/DECISION/IMPROVEMENT/NOTE）
    ├── review.md                  # 最新评审报告（历史轮次保留）
    └── commits.md                 # 任务 ↔ commit SHA 记账表
```

归档（`openspec archive`）后 delta 合入 `openspec/specs/`，整个 change 移入 `changes/archive/YYYY-MM-DD-<name>/`，letwork 记录随之永久保留。

---

## 代码规范库

skill 内置四份规范（`skills/letwork/references/standards/`）：

| 文件 | 内容 | 来源与许可 |
|---|---|---|
| `common.md` | 语言无关：命名、函数设计、错误处理、日志、注释、测试、安全、提交，附各语言机械化检查一行命令 | 本 skill 自有 |
| `java-alibaba.md` | 《阿里巴巴 Java 开发手册·黄山版》(2022.2.3) 精简改编 checklist，规则 ID `J-` | Apache-2.0，https://github.com/alibaba/p3c |
| `go-uber.md` | Uber Go Style Guide 索引式 checklist（叠加 Effective Go / CodeReviewComments），ID `G-` | MIT，https://github.com/uber-go/guide |
| `python-google.md` | Google Python Style Guide + PEP 8 / PEP 257 索引式 checklist，ID `P-` | CC-BY 3.0，https://google.github.io/styleguide/pyguide.html |

冻结机制：

1. 项目首次进入 code/review 且 `openspec/standards/` 为空时，按检测到的语言（pom.xml/go.mod/requirements.txt/pyproject.toml）推荐库存规范，三选一：库存 / 自带（提供路径，转成统一 checklist）/ 仅通用规范。
2. 选定后复制到项目的 `openspec/standards/` 并在该目录 README 记录来源版本与冻结日期。
3. **项目副本是唯一事实源**：coding 与 review 用同一份；skill 升级不会回改项目副本，需要更新时由你显式决定。

---

## 阶段与门禁

```
analyze ──validate + 用户确认──▶ plan
plan   ──任务可追溯 + validate──▶ code ──机械自检+人工规范自检──▶ test
test  ──真实退出码为绿──▶ review ──无 BLOCKER + validate --strict──▶ commit
commit ──显式暂存+用户确认+记账──▶ 下一任务 …… 全部完成 ──▶ retro ──▶ archive
```

任何门禁不过就停在当前阶段，不许跳步；测试失败、评审有 BLOCKER、校验失败都会把你拉回对应阶段。

---

## 架构

仿 mattpocock-skills 的 grill-me 模式（薄命令包装 + 单一核心引擎）：

```
skills/
├── letwork/                    # 核心引擎（model-invoked，持有全部规程）
│   ├── SKILL.md                # 启动检查 / 路由 / 八条铁律
│   ├── references/             # 各阶段细则 + OpenSpec v1.16 速查
│   │   ├── routing.md  bootstrap.md  openspec-cheats.md
│   │   ├── analyze.md  plan.md  code.md  test.md
│   │   ├── review.md   commit.md  retro.md
│   │   └── standards/          # 规范库（common + Java/Go/Python）
│   └── templates/              # journal / review / commits 模板
├── letworkstart/               # /letworkstart（route 模式）
└── let-analyze … let-retro/    # 7 个阶段命令（stage 模式）
```

包装命令每个只有几行，职责是把调用转发给 `letwork`；规程只在核心里维护一份，按需渐进加载，不占上下文。

---

## 其他 agent（Cursor / Codex 等）能用吗

可以。规程、规范库、模板都是纯 Markdown，与 agent 无关；只有「斜杠命令自动注册」是 Claude 专属外壳，换成目标工具的载体即可。OpenSpec 本身原生支持 40+ 工具（`openspec init --tools cursor|codex|gemini|github-copilot|zed|warp|…`）。

| 用法 | 适合 | 怎么装 |
|---|---|---|
| 复制 `ports/AGENTS.md` 到项目根 | 任何读 AGENTS.md 的工具（Codex、Cursor、Zed 等），零脚本 | `cp ports/AGENTS.md <项目根>/AGENTS.md` |
| Cursor 原生命令 | Cursor 用户 | `bash ports/cursor/install.sh`（软链 skills + 生成 ~/.cursor/commands） |
| Codex CLI 原生命令 | Codex 用户 | `bash ports/codex/install.sh`（生成 ~/.codex/prompts） |
| 任意其他工具 | Gemini CLI / Copilot / Windsurf 等 | 按 [docs/porting.md](docs/porting.md) 的通用 6 步移植 |

非 Claude 环境的两点降级（移植版已内置处理）：

- 没有弹窗提问 UI 时，grilling 访谈变成一条消息内编号 Q1..Qn（带推荐答案），按编号回答。
- 没有 Skill 工具时，命令的内容就是指示 agent **Read 仓库里的核心 SKILL.md 与对应 references 后执行**，因此规程更新（git pull）后无需重装命令。

## OpenSpec 原理与多人协同

不熟悉 OpenSpec 或团队多人并行开发时，先读：**[docs/openspec-collaboration.md](docs/openspec-collaboration.md)**。核心一句话：change 目录按特性物理隔离（并行几乎零冲突），主规格 `specs/` 只在归档时单点写入（冲突收敛到可控时刻），journal 等追加型记录冲突时两边都保留。文档内含冲突概率矩阵、分支工作流、同 capability 并行/归档冲突处理与 CI 建议。

## 依赖与降级

- 推荐安装 OpenSpec CLI 获得完整能力：`openspec init/new change/validate/archive/status/list`。
- CLI 完全不可用（无 Node、无法安装）时，skill 按 `references/openspec-cheats.md` 的模板手工维护全部 markdown 产物，用人工自检清单替代 validate，手工移动目录归档；journal 中会记录该降级决定。
- skill 本身不依赖任何运行时（纯 Markdown 指令）；`openspec init` 会在项目里生成官方 `/opsx:*` 命令，与本 skill 共存不冲突。

---

## 验证记录（狗粮测试）

- [2026-11-02 #10 5 项目批量（Java/Python×2/Go×2）](docs/dogfood/2026-11-02-batch-five-projects.md)：首次覆盖 Go 与并发测试，35 用例，回灌 gofmt/并发测试/限流区分，形成 v0.13。
- [2026-11-02 #9 ipam-v2 VLAN 管理](docs/dogfood/2026-11-02-ipam-v2-vlan.md)：v0.10 预览 + v0.9 git notes 真实写入实测，回灌确认豁免/预览精简/notes 持久性，形成 v0.11。
- [2026-11-02 #8 方案预览先行（Markdown+Mermaid）](docs/dogfood/2026-11-02-preview-first.md)：正式 spec/代码前先出一页预览确认，形成 v0.10。
- [2026-11-02 #7 git notes 备注（可选）+ 设计模式优化轴](docs/dogfood/2026-11-02-design-axis-git-notes.md)：三轴评审，notes 机制与设计建议双向演练，形成 v0.9。
- [2026-11-02 #6 用户反馈：门禁重试上限与受阻降级](docs/dogfood/2026-11-02-stalled-gate.md)：5 轮重试预算 + `[STALLED]` 止血/转任务/人介入机制，形成 v0.8。
- [2026-11-01 #5 用 letwork 开发 IPAM 分层业务系统](docs/dogfood/2026-11-01-ipam.md)：首次覆盖 Spring Boot 分层 + 数据库规范（J-DDL/IDX/ORM 全参数化），jsecscan 交叉扫描 0 命中，回灌分层测试节奏形成 v0.7。
- [2026-11-01 #4 用户实测：commit 不会做/不能选择性分批](docs/dogfood/2026-11-01-user-commit-feedback.md)：commit 规程重写为主动分批 + 绿色提交不变量 + 暂存快照验证，形成 v0.6。
- [2026-11-01 #3 用 letwork 开发 jsecscan Java 静态扫描器](docs/dogfood/2026-11-01-jsecscan.md)：Java 首战——阿里规范经官方 p3c-pmd 机械化 0 违规，自举扫描抓到真 BLOCKER，回灌 4 项形成 v0.5。
- [2026-11-01 #2 用已安装的 letwork 开发 sastscan 静态代码扫描器](docs/dogfood/2026-11-01-sastscan.md)：v0.2 四项改进全部实战生效（机械违规 0 返工、红测试零提交、勾选零遗漏），再回灌 3 项形成 v0.3。
- [2026-11-01 #1 用 letwork 开发 secscan 依赖漏洞扫描器](docs/dogfood/2026-11-01-secscan.md)：全链路走通，暴露并回灌 4 项流程改进（机械化自检门禁、测试退出码纪律、勾选/记账双向核对、review 第零轴）。

---

## FAQ / 故障排查

**Q：`npm install openspec` 对吗？**
不对。npm 上裸 `openspec` 是 0.0.0 的占位假包。真实包是 `@fission-ai/openspec`，或直接 `brew install openspec`。

**Q：`openspec new change` 报 already exists 但目录里没有 .openspec.yaml？**
脚手架不是原子的：长 flag 和值之间漏空格（如 `--goal"文本"`）会建出半成品空目录。确认目录内无有价值内容后删除重建；正常创建后应立即看到 `.openspec.yaml`。

**Q：必须装 OpenSpec CLI 才能用吗？**
不是。CLI 缺失时走手工模板 + 人工自检清单的降级路径，只是没有自动 validate/archive。

**Q：项目已有自己的规范怎么办？**
在规范选择弹窗选「自带规范」并给路径，skill 会读取后转成统一 checklist 格式冻结到 `openspec/standards/`。

**Q：可以只在评审环节用它吗？**
可以，只安装 `letwork` + `let-review`。没有活动 change 时评审只跑规范轴，报告中会声明未覆盖 spec 一致性。

**Q：会自动 push 或改我的仓库设置吗？**
不会。不自动 push、不自动合并；安装 CLI、初始化、归档等对外/结构性动作都会先征得你同意。

**Q：OpenSpec 升级后命令变了怎么办？**
`references/openspec-cheats.md` 基于 v1.16 核实；大版本升级后如遇命令异常，以 `openspec --help` 为准并更新该文件。

---

## 版本记录

- **v0.13.0**（2026-11-02）：5 项目批量（Java×1/Python×2/Go×2 首次）狗粮回灌——Go 机械检查改为先 `gofmt -w` 自动格式化再验证；test.md 新增并发代码测试规则（`-race`、禁 sleep 同步、CAS、channel 信号、背压突发语义）；环境限流（429/registry 超时）不消耗代码修复 5 轮预算，按 Retry-After 重试；bootstrap 补 `go mod init` 等语言工程初始化。
- **v0.12.0**（2026-11-02）：新增 [OpenSpec 原理与多人协同文档](docs/openspec-collaboration.md)——spec/change/archive 三概念、冲突概率矩阵（change 隔离/journal 追加/standards 冻结/specs 归档单点写）、分支工作流、同 capability 并行与归档冲突处理、CI 建议；cheats 与 README 挂入口。
- **v0.11.0**（2026-11-02）：ipam-v2 同栈增量狗粮回灌——明确「不用问我」=本次确认门禁一次性豁免（产物仍出、记 journal、不延续）；同栈/同域增量时预览可精简为差异+取舍（先读代码确认同栈）；git notes 持久性说明（fetch 恢复、review.md 才是随代码存档、归档提交不继承备注）。
- **v0.10.0**（2026-11-02）：**方案预览先行**——非平凡需求在正式 spec/代码前先出一页 `letwork/preview.md`（Markdown + Mermaid 流程图/分层图 + 关键取舍），用户确认方向后再展开，避免错方向浪费 token；新增预览模板与 Mermaid 自检；长报告先给提纲确认。
- **v0.9.0**（2026-11-02）：评审从双轴变三轴，新增**设计模式优化轴**（SUGGESTION 不阻断，观察信号→模式对照表，禁止凑数/过度设计）；评审结论可按用户选择写入 **git notes**（`refs/notes/review` 挂提交，不进代码树不改哈希，多轮 append），git notes/PR 评论均为可选项；经 notes 机制与设计轴双向演练验证。
- **v0.8.0**（2026-11-02）：门禁**重试预算与受阻降级**——同一问题最多修复 5 轮，仍不过则记 `[STALLED]`（尝试清单/待介入事项）、先止血恢复绿色（还原提交或显式 skip，禁止删断言/空 catch）、告知用户后转做不依赖任务、routing 持续识别受阻状态直到 `[STALLED-CLOSED]`；journal 模板增加 STALLED 格式。
- **v0.7.0**（2026-11-01）：IPAM 分层业务系统狗粮回灌——test.md 新增分层项目测试节奏（局部快反馈/提交点全量/测试切片分工/真实启动冒烟/H2 与生产方言差异显式登记，含自增键显式指定列）；数据库规范分册（J-DDL/J-IDX/J-SQL/J-ORM）首次实战达标。
- **v0.6.0**（2026-11-01）：用户实测反馈回灌，commit 规程重写——任务测试为绿后**主动规划分批提交**；确立**绿色提交不变量**（每个 commit 独立可编译可测，半成品只留工作树）；选择性暂存（hunk 级 `git add -p`/`apply --cached`）；按依赖序分批；工作树有半成品时用 `git stash --keep-index` 只验证暂存快照（scratch 仓库实测）。
- **v0.5.1**（2026-11-01）：SKILL.md frontmatter 增加 `version` 版本标记（唯一事实源）；新增 `ports/claude/install.sh` 安装脚本（幂等，安装/升级时打印版本号）；README 补版本确认与升级生效说明。
- **v0.5**（2026-11-01）：经 jsecscan（Java/Maven）第三次狗粮回灌——新增 [p3c-pmd 机械化接入指南](skills/letwork/references/standards/java-p3c-setup.md)（版本兼容矩阵/ruleset 名/实测 pom）；code.md 增加编译型语言 API 查实纪律、依赖版本核实与首次构建超时；test.md 增加工具类项目自举验收（jsecscan 自举抓到真 BLOCKER）。
- **v0.4**（2026-11-01）：跨 agent 支持——`ports/AGENTS.md` 通用移植版、Cursor 安装脚本（skills+commands）、Codex 安装脚本（prompts）、[docs/porting.md](docs/porting.md) 任意工具移植指南；两份安装脚本均经沙箱 HOME 实测。
- **v0.3**（2026-11-01）：经 sastscan 狗粮测试回灌——脚手架 flag 空格与创建后校验提示；common.md 增加可粘贴的「机械化检查一行命令」；commit.md 固化实现/测试分开提交的推荐粒度；README 补全安装与单命令使用指南。
- **v0.2**（2026-11-01）：经 secscan 狗粮测试回灌——code 增加工具链预检与机械化自检；test 增加退出码纪律；commit 增加 micro-checklist 与双向核对；review 增加机械检查第零轴。
- **v0.1**：初版；OpenSpec 速查基于 v1.16 核实（见 `skills/letwork/references/openspec-cheats.md`）。
- 库存规范为精简 checklist，完整手册请访问各来源链接。
