# devskills

个人 Claude Code skill 合集。每个 skill 独立成目录，可整套安装，也可只软链其中某几个命令到 `~/.claude/skills/` 使用。

## Skills

| Skill | 说明 | 详细文档 |
|---|---|---|
| **letwork** | 基于 OpenSpec 的需求驱动研发流：`/letworkstart` 按仓库现状自动路由，串起 需求分析（grilling 轮次访谈）→ 任务拆分 → 编码 → 测试 → 规范评审 → 按任务提交 → 归档复盘；编码与评审共用一份冻结规范，内置 Java（阿里黄山版）/ Go（Uber）/ Python（Google+PEP）规范库；支持完整流水线，也支持只单独使用其中任意一步 | [letwork/README.md](letwork/README.md) |

## 30 秒安装（letwork 全套 10 个命令）

前置：Claude Code、git；推荐安装 [OpenSpec](https://github.com/Fission-AI/OpenSpec) CLI（非必需，缺失时自动降级为手工维护产物）：

```bash
# OpenSpec CLI 三选一（需要 Node ≥ 22.12；真实包名带 scope，裸 openspec 是占位假包）
npm install -g @fission-ai/openspec@latest   # 或：brew install openspec
```

克隆并安装：

```bash
git clone git@github.com:crazychengmm/devskills.git ~/devskills
cd ~/devskills

# 一条脚本完成软链安装，并打印安装的版本号
bash letwork/ports/claude/install.sh
```

验证：**新开一个 Claude Code 会话**，输入 `/let` 应补全出 `/let-grill`、`/letworkstart`、`/let-analyze`、`/let-plan`、`/let-code`、`/let-test`、`/let-review`、`/let-commit`、`/let-retro`。确认版本：`grep '^version:' ~/.claude/skills/letwork/SKILL.md`。

> HTTPS 克隆改用 `git clone https://github.com/crazychengmm/devskills.git`。
> 软链是开发模式：`git pull` 后立即生效，无需重新安装。

## 只装其中几个命令

每个 `/let-*` 都是薄包装，真正的规程在核心 `letwork` 里，所以**最少要链核心 + 你要用的命令**。例如只要评审和提交：

```bash
ln -sfn "$PWD/letwork/skills/letwork"    "$HOME/.claude/skills/letwork"
ln -sfn "$PWD/letwork/skills/let-review" "$HOME/.claude/skills/let-review"
ln -sfn "$PWD/letwork/skills/let-commit" "$HOME/.claude/skills/let-commit"
```

## 快速上手

在任意 git 仓库里对 Claude Code 说：

```
/letworkstart 我想做一个把 Markdown 转成 HTML 的小工具
```

它会检查现状并引导你走完全流程；中途随时可以退出，下次再跑 `/letworkstart` 会根据产物状态判断你停在哪一步。

也可以**单独使用某一步**（跳过路由），例如：

| 场景 | 命令 |
|---|---|
| 拷问一个非软件想法/决策（不要仓库） | `/let-grill 搬家方案怎么选` |
| 只想把一个新需求访谈清楚并落成文档 | `/let-analyze 给导出接口加 CSV 格式` |
| 需求已定，只要拆任务 | `/let-plan` |
| 只按规范实现 tasks.md 中的 2.1 | `/let-code 2.1` |
| 提 PR 前只做一次正式评审 | `/let-review` |
| 只做规范的任务维度提交 | `/let-commit` |
| 只想把一个小步骤单独提交 | `/let-commit 修复空指针` |
| 随时记录踩坑/决策/改进 | `/let-retro` |

各命令单独使用时的前置条件、行为细节见 [letwork/README.md 的「用法二」](letwork/README.md#用法二单独使用某一步)。

## 其他 agent 也能用

规程与规范是纯 Markdown，不绑定 Claude：`letwork/ports/AGENTS.md` 可复制到任意项目给 Codex/Cursor/Zed 等读取；并提供 Cursor、Codex 的一键安装脚本；Gemini/Copilot 等按 `letwork/docs/porting.md` 移植。详见 [跨 agent 说明](letwork/README.md#其他-agentcursor--codex-等能用吗)。

## 仓库结构

```
devskills/
├── README.md                  # 本页（合集首页）
└── letwork/                   # skill：OpenSpec 需求驱动研发流
    ├── README.md              # 完整文档：安装/全流程/单命令/跨 agent/FAQ
    ├── docs/
    │   ├── dogfood/           # 狗粮测试报告（用自己开发自己，持续改进）
    │   └── porting.md         # 任意 agent 移植指南
    ├── ports/                 # 跨 agent 适配
    │   ├── AGENTS.md          # 通用项目规则版（复制到项目根）
    │   ├── cursor/install.sh  # → ~/.cursor/skills + commands
    │   └── codex/install.sh   # → ~/.codex/prompts
    └── skills/
        ├── letwork/           # 核心引擎 + 阶段规程 + 规范库 + 模板
        └── let-grill/                    # 通用拷问（无仓库前置）
            letworkstart/ … let-retro/   # 8 个研发流薄包装命令
```

## 更新与卸载

```bash
# 更新：拉取后重跑安装脚本会打印新版本号；新开会话后生效
cd ~/devskills && git pull && bash letwork/ports/claude/install.sh

# 卸载 letwork 全套
rm ~/.claude/skills/letwork ~/.claude/skills/let-grill \
   ~/.claude/skills/letworkstart \
   ~/.claude/skills/let-analyze ~/.claude/skills/let-plan \
   ~/.claude/skills/let-code ~/.claude/skills/let-test \
   ~/.claude/skills/let-review ~/.claude/skills/let-commit \
   ~/.claude/skills/let-retro
```

## 版本记录

- letwork **v0.17.1**（2026-11-05）：阶段顺序 code→review→test，测试集中在代码写完后；提交门禁分编译绿/测试绿两档。
- letwork **v0.17.0**（2026-11-05）：git 本地提交与远端推送两级强制确认、编译/测试不过禁止提交、pre-commit 钩子兜底、push 前再完整验证。
- letwork **v0.16.1**（2026-11-04）：问卷两点减负纪律（先拷问 send 再动笔、单概念题+允许答「不知道」）；Codex/Cursor 安装脚本补 /let-grill；根 README 同步。
- letwork **v0.16.0**（2026-11-04）：通用 /let-grill 拷问入口（无仓库前置）+ 访谈实时沉淀（术语表/ADR/异步问卷）。
- letwork **v0.15.1**（2026-11-04）：批量编排反例（管道吞退出码/跨目录 discover）。
- letwork **v0.15.0**（2026-11-04）：既存项目进场摸底——架构画像 + 既存问题台账，欠债随关联模块开发复现提示。
- letwork **v0.14.0**（2026-11-03）：Go HTTP/多 change 并行/时间注入/skip_specs 首次覆盖；多 change 自主路由、时钟注入、冒烟就绪轮询。
- letwork **v0.13.0**（2026-11-02）：5 项目批量狗粮（首次覆盖 Go/并发）——gofmt 自动格式化、并发测试 -race 规则、环境限流不计入修复预算、Go 工程初始化。
- letwork **v0.12.0**（2026-11-02）：新增 OpenSpec 原理与多人协同文档（冲突矩阵、分支工作流、归档冲突处理）。
- letwork **v0.11.0**（2026-11-02）：ipam-v2 狗粮——确认门禁一次性豁免语义、同栈增量预览精简、git notes 持久性说明。
- letwork **v0.10.0**（2026-11-02）：方案预览先行——正式 spec/代码前先出一页 Markdown+Mermaid 预览确认；长报告先提纲后全文。
- letwork **v0.9.0**（2026-11-02）：评审新增设计模式优化轴（三轴）；评审结论可按用户选择写入 git notes（可选）。
- letwork **v0.8.0**（2026-11-02）：门禁重试预算（≤5 轮）与受阻降级（`[STALLED]` 止血恢复绿色、转任务、等人介入）。
- letwork **v0.7.0**（2026-11-01）：IPAM 分层业务系统狗粮——数据库规范分册实战达标，新增分层测试节奏（切片分工/真实冒烟/方言差异登记）。
- letwork **v0.6.0**（2026-11-01）：commit 阶段重写——主动分批选择性提交 + 绿色提交不变量（每个 commit 独立可编译可测）+ 暂存快照验证。
- letwork **v0.5.1**（2026-11-01）：SKILL.md 版本标记 + 一键安装脚本（安装/升级打印版本号）。
- letwork **v0.5**（2026-11-01）：Java/Maven 首次狗粮（jsecscan）——p3c-pmd 机械化接入指南、编译型语言 API 查实纪律、工具类自举验收。
- letwork **v0.4**（2026-11-01）：跨 agent 支持（AGENTS.md 通用版 + Cursor/Codex 安装脚本 + 移植指南）。
- letwork **v0.3**（2026-11-01）：两次真实项目狗粮测试后回灌（机械化自检门禁、测试退出码纪律、勾选/记账双向核对、review 第零轴、脚手架健壮性、可粘贴检查命令、实现/测试分开提交）。详见 [letwork/README.md#版本记录](letwork/README.md#版本记录) 与 `letwork/docs/dogfood/`。
