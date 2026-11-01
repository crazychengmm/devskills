# devskills

个人 Claude Code skill 合集（私有）。每个 skill 独立成目录，可单独软链到 `~/.claude/skills/` 使用。

## Skills

| Skill | 说明 |
|---|---|
| [letwork](letwork/README.md) | 基于 OpenSpec 的需求驱动研发流：`/letworkstart` 自动路由，分析（grilling 访谈）→ 拆分 → 编码 → 测试 → 规范评审 → 按任务提交 → 归档复盘；内置 Java（阿里黄山版）/Go（Uber）/Python（Google+PEP）规范库 |

## 安装单个 skill

```bash
ln -sfn /path/to/devskills/<skill>/skills/<name> ~/.claude/skills/<name>
```

以 letwork 为例（9 个命令一起链）：

```bash
for d in letwork/skills/*/; do
  ln -sfn "$(cd "$d" && pwd)" "$HOME/.claude/skills/$(basename "$d")"
done
```

卸载：删除 `~/.claude/skills/` 下对应的软链。
