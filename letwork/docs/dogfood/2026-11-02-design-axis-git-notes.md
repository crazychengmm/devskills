# 实测反馈 #7：评审结论写 git notes（可选）+ 增加设计模式优化轴

- 日期：2026-11-02
- 来源：用户实测反馈（两点）
  1. review 结论写到 git 代码 review 的备注中；
  2. 评审增加设计模式优化考虑。
  3. 补充澄清：git 代码 review（notes/PR 评论）是用户可选项，不是必须项。

## 回灌内容（v0.9.0）

### 设计模式优化轴（轴三）
- review 从双轴变三轴：规范符合度 / spec 场景一致性 / **设计模式优化**。
- 轴三级别统一 SUGGESTION，不阻断；给观察信号→模式的对照表（长 if 分发→策略注册表、原始类型→值对象、构造复杂→Builder/工厂、近似代码→提取等）。
- 每条建议必须含位置/观察/建议/收益/成本，**无像样建议写「无」，禁止凑数、禁止为套模式过度设计**；用户逐条选 采纳/挂账/拒绝。

### git notes 备注（可选项）
- 默认必做产出只有 `letwork/review.md`；评审开始时询问是否写 git notes，用户明确要才写。
- 命令：`git notes --ref=review add/append -F`；格式见 review-format.md「git notes 摘要格式」。
- notes 不进代码树、不改提交哈希；远端可见需显式 `git push origin refs/notes/review`（仍需同意）。
- PR 评论（`gh pr review`）同为可选项，需要 gh 登录。

## 测试（规程演练，非单测）

1. **git notes 机制演练**（ipam 临时副本）：add 写入→show 读回→提交哈希不变、工作树不脏→append 保留两轮→独立 ref `refs/notes/review` 存在，5 项断言全过。首跑因演练脚本路径写错失败，修正后干净通过。
2. **设计轴双向验证**：
   - 真问题：在 ipam 上提出 2 条站得住的建议——`allocateAuto` 先物化全部可用地址（/8 约 1677 万个 Long）再过滤，应换 SortedSet 间隙查找；`Subnet` record 混入非表列的 `allocatedCount` 统计字段，应拆视图 DTO。
   - 反向（不凑数）：对已内聚的 `Cidr` 值对象走清单，无类型分发/无重复/无空值分支，结论「无建议」。
3. **一致性**：SUGGESTION 级别在 SKILL.md/review.md/review-format.md/模板中统一；git notes 在四处均标注「可选」。
