# 实测反馈 #15：MCP 工具（serena / codebase-memory-mcp）接入约定

- 日期：2026-11-05
- 背景：用户已装 serena（LSP 符号 MCP）与 codebase-memory-mcp（CBM，持久本地知识图谱，17 工具/混合 LSP/基础设施关系/跨会话）；问对 skill 是否提效。

## 结论与回灌（v0.18.0）

新增 `references/mcp-integration.md`，定位为**可选增强层**：

### 分工
- serena：实时符号导航（定义/引用/实现/重命名影响面、写 API 前核实签名）。
- CBM：持久图谱，新仓库理解、impact 影响面、跨服务调用链、相关测试、架构决策、快照对比。
- memory 类（预留）：只存跨项目术语/踩坑/STALLED 三类，禁止项目内过程写入。
- grep/find：小项目与简单文本的兜底。

### 阶段映射
intake 用 CBM 出架构图（与抽读交叉验证）；analyze 用 MCP 自查影响面不问用户；code 用 serena 核实 API + CBM 查波及文件；review 三轴取证。

### 不可逾越的边界（关键）
1. 编译器/测试/文件事实 > MCP 返回（索引会过期，过期先重建再下结论）。
2. MCP 输出不能替代编译通过、测试通过与任何门禁。
3. 结论必须落入 letwork 正式产物（review.md/journal/ADR），不直接引用图谱当报告。
4. MCP 故障按环境瞬时错误处理，降级原生工具不阻塞。
5. <20 源文件的小项目默认不用图谱，避免过度工具化。

### 同步位置
SKILL 启动检查第 7 条、code/review/intake 三处挂引用；OpenSpec/glossary/ADR 的事实源地位不变。
