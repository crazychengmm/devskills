---
name: let-commit
description: 按任务维度提交代码——一次只提交当前任务的文件并记账；也支持把一个简单步骤单独提交。
disable-model-invocation: true
---

Call the Skill tool with "letwork".

- Enter mode: **stage:commit**（跳过路由，直接执行提交规程；绝不 `git add -A` 式一次性全提交）。
- 把用户在命令后输入的参数原样透传：若给了步骤说明（如 `/let-commit 修复空指针`），走「简单步骤」单提模式。
