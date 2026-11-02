# 实测反馈 #8：报告/方案先出 demo 预览确认，再写代码与细化

- 日期：2026-11-02
- 来源：用户实测反馈——输出报告、流程之类，先出一个 demo（Markdown/Mermaid 等产物）确认没问题，再写代码或做更细致的工作，否则浪费 token。

## 回灌内容（v0.10.0）

- analyze.md 新增「2b. 方案预览先行」：
  - 顺序固定：grilling 收敛 → **preview.md（一页 Markdown + Mermaid）→ 用户确认** → 正式 proposal/design/spec/tasks → code。
  - 预览内容：目标/Non-Goals、主流程 Mermaid（flowchart/sequenceDiagram）、分层草图（组件职责+依赖，最多伪代码）、≤4 个关键取舍、风险待确认。
  - 先写文件 `letwork/preview.md` 并给确认入口；未确认不写正式 spec/不拆细任务/不写代码；改方向只改预览。
  - 平凡需求（小 bugfix/文案/访谈已到实现级）可跳过并说明理由。
  - **长报告同理**：正式评审/调研/扫描长报告前先给章节提纲与格式，确认后产出全文。
- 新增 `templates/preview.md` 模板（含确认勾选位）。
- Mermaid 静态自检规则：围栏成对、flowchart 声明、边/括号/标签配对、无孤儿节点；有 mermaid-cli 可渲染兜底。
- SKILL.md 铁律 1 吸收（事实自查 + 方案先预览后细化），analyze 阶段门禁增加「预览经用户确认」。

## 测试

- 用「IPAM 增加 VLAN 绑定」假需求走一遍预览：37 行一页内，5 个必需章节齐全、无实现代码、Mermaid 8 节点 6 边静态语法校验通过、模板围栏配对（6 标记偶数）。
- 反向：模板不含完整代码块（只有伪代码草图位），防止预览膨胀成实现。
