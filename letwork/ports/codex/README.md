# Codex 适配

Codex CLI 两个原生机制：

- `~/.codex/prompts/<name>.md` → `/<name>` 斜杠命令；
- 项目根 `AGENTS.md`（或全局 `~/.codex/AGENTS.md`）自动注入上下文。

## 安装

```bash
bash ports/codex/install.sh
```

生成 9 个命令：`/letworkstart`、`/let-analyze`、`/let-plan`、`/let-code`、`/let-test`、`/let-review`、`/let-commit`、`/let-retro`。每个命令指示 Codex 读取仓库中的核心 SKILL.md 与对应阶段细则后执行——因此 `git pull` 更新规程后命令无需重装。

再把通用 AGENTS.md 放入项目（推荐，项目级）或全局：

```bash
cp ports/AGENTS.md <你的项目根>/AGENTS.md     # 项目级
cp ports/AGENTS.md ~/.codex/AGENTS.md         # 全局
```

## 使用

在 Codex CLI 中：

```
/letworkstart
/let-analyze 给导出接口加 CSV 格式
/let-code 2.1
/let-review
/let-commit 修复空指针
```

没有弹窗 UI，grilling 访谈会变成一条消息里的编号问题，按编号回答。

## 卸载

```bash
rm -f ~/.codex/prompts/letworkstart.md ~/.codex/prompts/let-*.md
# 以及你复制的 AGENTS.md（自行决定是否删除）
```
