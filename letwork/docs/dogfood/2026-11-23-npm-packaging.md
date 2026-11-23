# 实测反馈 #18：npm 安装包装（v0.21）

- 日期：2026-11-23
- 需求：不发布 npm registry，支持 GitHub 安装与本地 tgz；本地真机 npm 安装。

## 实现

- package.json 放在**仓库根**（git URL 安装要求根目录有包清单）：bin=`letwork-link`、postinstall/preuninstall 钩子、files 白名单（只打 letwork/ 内容）、private=true 防误发布。
- `scripts/npm-postinstall.sh`：自定位包根，软链 skills/* 到 ~/.claude/skills，幂等。
- `scripts/npm-preuninstall.sh`：只删指向本包的软链，不碰用户其他 skill。
- `scripts/letwork-link.sh`：bin 入口，循环解析符号链接（兼容 macOS 无 readlink -f），供 npm12 拦截生命周期脚本时手动重建。

## npm 12.0.2 实测踩坑（写进 README）

1. **生命周期脚本默认拦截**：postinstall 不执行，只给 warning；`--allow-scripts=<pkg>` 与 `npm config set allow-scripts` 在实测环境未生效，`--dangerously-allow-all-scripts` 可靠；兜底是 bin 命令 `letwork-link`（全版本可用）。
2. **git 来源默认禁用**：`git+...`/`github:` 安装报 EALLOWGIT，需 `--allow-git=all`。
3. bin 通过符号链接调用时 `$0` 是全局 bin 路径，需解析真实路径才能定位包内脚本。
4. package.json 必须在仓库根，子目录包 git 安装报 ENOENT。

## 沙箱验证

- `npm pack` 71 文件、无 .git；tgz 安装后 letwork-link 建出 10 个软链、版本正确。
- 卸载清理仅在生命周期脚本被授权时自动执行，否则文档给出手动清理。

## 真机补充（用户机器 npm 12.0.2）

- git URL 安装在「git dep preparation」阶段以 `--global=false` 嵌套安装，`--dangerously-allow-all-scripts` 也无法授权其 postinstall（EALLOWSCRIPTS）——**git 路线统一要求安装后手动 `letwork-link`，文档已修正，不再宣称自动链接**。
- 真机 tgz 路线验证成功：`npm pack` → `npm i -g tgz`（postinstall 仅 warning 不阻断）→ `letwork-link`，10 个软链改指 `/opt/homebrew/lib/node_modules/letwork-skill/`，`npm ls -g` 可见包。
- `~/.npmrc` 的 allow-scripts 数组写法：`allow-scripts[]=<pkg>` 每行一个（保留原有 claude-code 条目）。
