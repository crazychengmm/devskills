# 狗粮测试 #12：既存项目进场摸底（intake）机制

- 日期：2026-11-04
- 来源：用户需求——既存项目开始前先总结架构/风格/模块职责，既存问题提示用户决定；不改则记录，相关模块开发时再一起改。
- 验证对象：真实既存项目 `work/autoop`（15 模块 Maven/459+113 文件，只读调查，产物生成在 /tmp 演示未污染仓库）。

## 回灌内容（v0.15.0）

- 新增阶段 **intake（仅既存项目）**与 `references/intake.md`：
  - 只读有界调查（~20 文件）：构建依赖、模块结构、代码风格、测试现状、机械检查基线、TODO/空 catch/重复等信号；
  - 产出 `openspec/letwork/project-profile.md`（Mermaid 架构图、模块职责表、观察到的约定、构建测试命令）；
  - 产出 `openspec/letwork/debt-backlog.md`（DEBT-xxx：位置/风险/建议/关联模块关键词/状态），逐条由用户决定现在修或暂缓；
  - 联动：analyze 新 change 时按模块关键词匹配欠债并再次提示（同一 change 只问一次），review 第零轴检查触及文件，修复后标 CLOSED+change+sha；新发现的既存问题追加台账而非混入当前提交。
- 新增两个模板：project-profile.md、debt-backlog.md。
- SKILL 启动检查第 4 步、阶段表、analyze（2a 节）、review 第零轴同步；默认入乡随俗（既有风格优先，安全强制规则除外）。

## 实测产出

对 autoop 的摸底（约 10 条命令、未通读代码）即得出：DDD 分层（domain 仓储接口 + infra 实现）、15 模块依赖图、ApiResult/ErrorCode 统一约定、record/Javadoc 风格、0 TODO/0 printStackTrace 的良好信号、4 条待用户决定的欠债（无静态检查接入、执行器模块测试密度、Testcontainers 前置、逐模块规范差异未核）。画像 Mermaid 11 边静态校验通过。

## 结论

有界只读调查 + 两个项目级文档的模式可行且成本低（避免一上来通读 459 个文件）；「欠债随关联模块复现」的闭环靠 backlog 关键词匹配实现。
