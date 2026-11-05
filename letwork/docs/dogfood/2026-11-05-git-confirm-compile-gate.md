# 实测反馈 #14：git 两级确认 + 强制编译门禁

- 日期：2026-11-05
- 来源：用户明确要求——本地提交、远端提交都要确认；强制编译通过才能提交（本地/远端一致）。

## 回灌内容（v0.17.0）

### commit.md 新增第 0 节：强制确认 + 编译门禁
- **两级独立确认**：`git commit` 与 `git push` 各自需要用户明确同意；push 前再完整跑一次构建+测试（防本地状态漂移）。
- **不被一次性豁免覆盖**：「不用问我/你决定」不包含 git 写动作，与破坏性/对外动作同级。
- 分语言最小编译门禁表：Java `mvn compile/test`、Go `go build/test -race`、Python `py_compile + unittest`、Node `npm run build`。
- 装绿手段（--no-verify、删测试、空 catch）明确禁止；5 轮不过走 STALLED。
- 本地多批可用一句「这几批按方案提交」覆盖，但 push 仍单独确认。

### 机器级兜底
- 新增 `scripts/pre-commit.sample`：按项目类型自动跑构建/测试的 git 钩子，人或 agent 失误时也能挡住坏提交；明确是流程确认的补充而非替代。

### SKILL.md
- 铁律 3 重写（两级确认/push 前完整验证/不被豁免）；铁律 1 豁免范围显式排除 git 动作。

## 测试

- 临时 Go 仓库演练：编译错误被门禁拦截、修复后 GREEN；sample 钩子安装后绿色提交放行、坏语法提交被 `go vet` 拒绝。
- 干净环境复验排除环境噪音；确认无全局 hooksPath 干扰。

## 追加（同日）：阶段顺序调整为 code→review→test（v0.17.1）

- 用户要求：review 之前只要没有编译错误即可，测试在代码全部写完后集中进行。
- 调整：SKILL 阶段表、code/review/test/commit 四份规程统一为「code 编译级自检 → review（基线只需编译通过，轴二查测试计划覆盖度）→ test（集中编写并全量执行）」；提交门禁分两档（测试存在前编译绿、之后测试绿）；`openspec/config.yaml` 可声明 `test_strategy: tdd` 切回每任务即测。
- 与 v0.17 编译门禁兼容：push 前按当前阶段重跑对应门禁（code 阶段编译、test 阶段全量测试）。
