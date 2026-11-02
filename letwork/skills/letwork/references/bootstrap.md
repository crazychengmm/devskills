# 初始化引导（仓库还没有 openspec/ 时）

## 1. 环境检查（只读）

```bash
node --version     # 需要 ≥ v22.12.0（@fission-ai/openspec 要求）
openspec --version # 已装？
```

真实包信息：**`@fission-ai/openspec@latest`**（npm 上的裸 `openspec` 是 0.0.0 占位假包，禁止安装）。

## 2. 安装 CLI（先征得用户同意；安装是对外动作）

按现场条件给出选项，不擅自全局安装：

- 有 Node ≥22.12：`npm install -g @fission-ai/openspec@latest`（或 pnpm/yarn/bun 等价命令）
- macOS 有 Homebrew：`brew install openspec`
- 不想全局装：项目内用 `npx @fission-ai/openspec@latest <cmd>` 调用（注意 npx 每次有解析开销）
- 官方脚本（用户知情可选）：`curl -fsSL https://openspec.dev/cli/install.sh | sh`

装完 `openspec --version` 验证。需要登录/交互的安装让用户用 `! <命令>` 自己执行。

## 3. 初始化项目

首选 CLI（会按所选工具生成 .claude/skills/openspec-* 与 /opsx:* 命令，与本 skill 共存不冲突）：

```bash
openspec init . --tools claude
# 常用 flag：--language <语言>  --profile core|expanded  --force  --no-animation
```

若 init 是交互式且无法在当前会话完成，让用户用 `! openspec init` 自行跑完；或经用户同意后采用**手工最小脚手架**降级（validate 可识别）：

```
openspec/
├── config.yaml          # 内容见下
├── specs/               # 空目录（放 .gitkeep）
└── changes/
    └── archive/.gitkeep
```

`config.yaml` 最小内容：

```yaml
schema: spec-driven

context: |
  <两三行项目技术栈与约定：语言/框架/包管理器/测试命令>
```

> config.yaml 的 context 会注入 OpenSpec AI 工作流，务必写实；rules 段可先不写。

## 4. 各语言项目自身的初始化（与 OpenSpec 无关，勿漏）

OpenSpec 只管需求产物，不创建语言工程；在 code 第一个任务前完成：

- Go：`go mod init <module-path>`（如 `github.com/<org>/<repo>`），拉依赖后 `go mod tidy`；`.gitignore` 忽略测试/构建产物。
- Java：`mvn archetype` 或手写 pom.xml（版本组合先查 Maven Central，见 code.md）。
- Python：按需建 `pyproject.toml`/包目录与 `tests/`。

## 5. 初始化后验证

- `openspec list` 不报错（无 change 时输出空列表）。
- 告知用户 OpenSpec 自带的 `/opsx:*` 命令与本 skill 的分工：日常研发走 `/letworkstart`；`/opsx:apply`、`/opsx:archive` 等也可单用，本 skill 的 archive 步骤内部就是调 CLI。
- 在仓库根 `.gitignore` 无需特殊处理（openspec 产物应提交）。

## 6. CLI 完全不可用时的降级

无 Node、无法安装时仍可手工维护全部 markdown 产物（格式见 openspec-cheats.md），但：
- 跳过所有 `openspec validate/archive` 命令，改用本 skill 自带的产物自检清单（cheats 末尾）。
- 归档手工执行：建 `openspec/changes/archive/YYYY-MM-DD-<name>/`，把 change 目录整体移入，并手工把 delta 合入 `openspec/specs/<capability>/spec.md`。
- 在 journal.md 记录一条 DECISION：因何降级、何时补 validate。
