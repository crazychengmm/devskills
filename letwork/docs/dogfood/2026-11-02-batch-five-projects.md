# 狗粮测试 #10：5 项目批量验证（Java×1 / Python×2 / Go×2，首次覆盖 Go）

- 日期：2026-11-02
- 被测：letwork v0.12
- 项目（均为纯逻辑零外部服务）：
  - `v-jretry`（Java，纯 Maven 无 Spring）：重试执行器，7 测试
  - `v-logwatch`（Python）：nginx 日志解析聚合，6 测试
  - `v-cfgcheck`（Python）：声明式 INI 配置校验，7 测试
  - `v-goretry`（Go，首次）：重试库表驱动测试，9 用例
  - `v-gopool`（Go，首次并发）：有界 worker pool，6 用例，`-race` 连跑 5 轮
- 每个项目完整走 change→tasks→code→test→p3c/gofmt→review→git notes→archive，各 5 commits。

## 结果

- 全部 validate --strict 通过、归档成功、notes 均挂 refs/notes/review。
- Java 纯 Maven 路径（无 Spring）p3c 配置一次成功，证明 p3c-setup 文档不依赖 Spring。
- 35 个测试用例全部最终为绿；开发中被门禁拦截的问题见下。

## 开发中拦截的问题（证明门禁有效，均未进入提交）

- v-logwatch：测试里 `line` 未定义（应为 SAMPLE）→ 测试失败拦截。
- v-cfgcheck：3 行超 80 + 测试期望错（缺失非必填不该违规）→ 行长门禁 + 测试拦截。
- v-goretry：gofmt 有格式差异 → 自动 `gofmt -w` 修正。
- v-gopool：未使用 import×2（vet 拦截）、max 统计用 Load+Store 非原子（改 CAS）、背压测试用 sleep 同步（改 channel 信号）、drain 测试队列容量不足（背压语义澄清）。
- 过程中模型 API 两次限流，按返回提示等待后自动重试（用户授权）。

## 发现的 skill 缺口（回灌 v0.13）

1. **Go 格式化只列不改**：common.md 原来写 `gofmt -l`（只报告），但 gofmt 是规范格式化器，应先 `gofmt -w` 再验证；Python black/isort 同理（仅项目已配置时）。
2. **并发测试零指引**：写 pool 测试所需的 `-race`、禁 sleep 同步、CAS 统计、channel 信号、突发背压语义全靠现想。test.md 新增「5b. 并发代码测试」。
3. **环境限流与代码失败未区分**：429/registry 超时会被误算进 v0.8 的 5 轮代码修复预算；新增规则——环境瞬时错误不消耗预算，按 Retry-After 等待重试，持续 >10 分钟才 STALLED。
4. **Go 工程 bootstrap 缺 go mod init/tidy**：bootstrap.md 补各语言工程自身初始化一节。

## 流程观察

- v0.10 预览对这种小工具收益低，按「平凡任务跳过」执行，没有强行产出预览——精简规则有效。
- v0.6 绿色分批在 5 个项目一致执行（实现/测试分离提交），全部提交点可编译可测。
- 同域多项目（jretry/goretry）证明 change 隔离让并行验证互不干扰。
