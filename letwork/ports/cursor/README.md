# Cursor 适配

## 安装

```bash
bash ports/cursor/install.sh
```

脚本做两件事（全部软链/生成在 `~/.cursor/` 下）：

1. 把 9 个 skill 目录软链到 `~/.cursor/skills/`（Cursor 支持 Agent Skills / SKILL.md 格式的版本可直接发现；以 Cursor 官方文档为准）。
2. 在 `~/.cursor/commands/` 生成 `/letworkstart`、`/let-analyze` … `/let-retro` 共 9 个命令文件，内容是让 agent 读取仓库内核心规程并执行（`$ARGUMENTS` 透传）。

## 使用

- 新开会话，输入 `/letworkstart` 或用自然语言：「分析这个需求」「拆任务」「按规范编码 2.1」「评审一下」「按任务提交」。
- 阶段门禁、规范冻结、journal/commits 记录与 Claude 版完全一致。
- 没有弹窗提问 UI 时，agent 会在一条消息里编号列出问题并给推荐答案，按编号回答即可。

## 项目级（不装到全局）

- 把 `ports/AGENTS.md` 复制到项目根，或把命令文件放到项目的 `.cursor/commands/`、skill 放到 `.cursor/skills/`。

## 卸载

```bash
find ~/.cursor/skills -maxdepth 1 -name 'let*' -type l -delete
rm -f ~/.cursor/commands/letworkstart.md ~/.cursor/commands/let-*.md
```
