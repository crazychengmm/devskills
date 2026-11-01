---
name: letworkstart
description: OpenSpec 需求驱动研发流的总入口——检查项目现状并自动路由到当前该做的阶段（初始化 / 需求分析 / 任务拆分 / 编码 / 测试 / 评审 / 提交 / 归档复盘）。
disable-model-invocation: true
---

Call the Skill tool with "letwork".

- Enter mode: **route**（先判定现状，再给出当前阶段与依据，等用户确认后进入）。
- 把用户在命令后输入的参数原样透传（例如想做的需求的一句话描述）。
