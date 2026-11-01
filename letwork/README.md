# letwork — 基于 OpenSpec 的需求驱动研发流 Skill

一套 Claude Code 个人 skill：把「需求分析 → 任务拆分 → 编码 → 测试 → 评审 → 按任务提交 → 归档复盘」串成由 [OpenSpec](https://github.com/Fission-AI/OpenSpec) 管理的流水线。需求分析用 grill 式轮次访谈把需求逼问清楚；编码与评审共用一份冻结的代码规范；代码按**任务维度**逐个提交。

## 命令一览

| 命令 | 作用 |
|---|---|
| `/letworkstart` | 总入口：检查仓库现状，自动路由到当前阶段（可随时中途续跑） |
| `/let-analyze [需求描述]` | 需求分析：grilling 访谈 → OpenSpec proposal + spec delta |
| `/let-plan` | 任务拆分：生成可独立实现/测试/提交的 tasks.md |
| `/let-code [任务号]` | 编码：一次一个任务，开工前冻结代码规范 |
| `/let-test` | 运行当前任务相关测试并记录证据 |
| `/let-review` | 双轴评审：代码规范符合度 + spec/场景一致性 |
| `/let-commit [步骤说明]` | 按任务提交（禁止全量 add）；带步骤说明时为简单步骤单提 |
| `/let-retro [内容]` | 记录问题/决策/改进；归档前汇总复盘 |

## 架构

仿 mattpocock-skills 的 grill-me 模式：

```
skills/
├── letwork/                # 核心引擎（model-invoked，持有全部规程）
│   ├── SKILL.md
│   ├── references/         # 各阶段细则 + OpenSpec 速查
│   ├── references/standards/  # 规范库（通用 + Java/Go/Python 库存规范）
│   └── templates/          # journal / review / commits 模板
├── letworkstart/           # 8 个薄包装命令（user-invoked）
└── let-analyze … let-retro/
```

## 代码规范库

- `common.md`：语言无关通用规范（命名、错误处理、日志、测试、安全、提交）。
- `java-alibaba.md`：《阿里巴巴 Java 开发手册·黄山版》（2022.2.3）**精简改编 checklist**，Apache-2.0，来源 https://github.com/alibaba/p3c 。
- `go-uber.md`：Uber Go Style Guide 索引式 checklist（MIT），叠加 Effective Go / CodeReviewComments。
- `python-google.md`：Google Python Style Guide（CC-BY）+ PEP 8 / PEP 257。

项目首次进入 coding 阶段时，若项目内没有冻结规范，会让你选择：采用库存规范 / 提供自己的规范 / 仅用通用规范。选定后复制到项目的 `openspec/standards/` 并记录来源与冻结日期，之后 coding/review 都以项目副本为准。

## 依赖

- git 仓库；OpenSpec CLI（`@fission-ai/openspec` ≥ 1.16，需 Node ≥22.12；`brew install openspec` 亦可）。CLI 不可用时 skill 会降级为手工维护产物（见 `references/bootstrap.md`）。
- ⚠️ npm 上裸 `openspec` 包是 0.0.0 占位假包，真实包是 `@fission-ai/openspec`。

## 安装（当前默认不安装，需要时执行）

把 `skills/` 下每个目录软链到个人 skills 目录：

```bash
for d in skills/*/; do
  ln -sfn "$(cd "$d" && pwd)" "$HOME/.claude/skills/$(basename "$d")"
done
```

验证：新开会话输入 `/letworkstart` 应能补全。卸载：删除 `~/.claude/skills/letwork*` 对应软链即可。

## 每个需求（change）的产物

OpenSpec 标准产物：`proposal.md`、`design.md`、`tasks.md`、`specs/<capability>/spec.md` delta。

letwork 自有产物在 change 下的 `letwork/` 子目录（归档时随 change 一起进入 archive）：

- `journal.md`：过程留痕（PROBLEM / DECISION / IMPROVEMENT / NOTE）。
- `review.md`：评审报告（规则 ID + spec 场景核对）。
- `commits.md`：任务 ↔ commit SHA 记账表。

## 验证记录（狗粮测试）

- [2026-11-01 #2 用已安装的 letwork 开发 sastscan 静态代码扫描器](docs/dogfood/2026-11-01-sastscan.md)：v0.2 四项改进全部实战生效（行长 0 返工、红测试零提交、勾选零遗漏），再回灌 3 项形成 v0.3。
- [2026-11-01 #1 用 letwork 开发 secscan 依赖漏洞扫描器](docs/dogfood/2026-11-01-secscan.md)：全链路走通，暴露并回灌 4 项流程改进（机械化自检门禁、测试退出码纪律、勾选/记账双向核对、review 第零轴）。

## 版本与更新

- **v0.3**（2026-11-01）：经 sastscan 狗粮测试回灌——脚手架 flag 空格与创建后校验提示；common.md 增加可粘贴的「机械化检查一行命令」；commit.md 固化实现/测试分开提交的推荐粒度。
- **v0.2**（2026-11-01）：经 secscan 狗粮测试回灌——code 增加工具链预检与机械化自检；test 增加退出码纪律；commit 增加 micro-checklist 与双向核对；review 增加机械检查第零轴。
- **v0.1**：初版；OpenSpec 速查基于 v1.16 核实（见 `skills/letwork/references/openspec-cheats.md`），OpenSpec 大版本升级后需重新核对命令与校验规则。
- 库存规范为精简 checklist，完整手册请访问各来源链接。
