# 评审报告格式与级别约定

## 严重级别

| 级别 | 判定 | 处置 |
|---|---|---|
| **BLOCKER** | 正确性缺陷、数据损坏/丢失、安全漏洞、会导致崩溃的空指针/并发问题、明确违反语言分册【强制】规则且无豁免理由、spec 要求未实现 | 必须修复后重评，不得提交/归档 |
| **MAJOR** | 当前能跑但高概率埋坑：错误处理缺失、边界未覆盖、抽象错误、超范围改动、spec 场景缺测试、违反【推荐】规则中影响可维护性者 | 逐条由用户决定修复或挂账（挂账进 journal IMPROVEMENT） |
| **MINOR** | 风格、命名、局部简化、注释、轻微重复 | 可批量修复，不阻塞 |
| **SUGGESTION** | 轴三产出：设计模式/重构优化建议，当前实现没有错误 | 用户决定采纳（开新任务）/挂账（IMPROVEMENT）/拒绝（YAGNI 注明），不阻塞 |
| **INFO** | 提问、风险提示、规则冲突时的取舍建议、需要用户确认的产品语义 | 无需修复，需要回复 |

判定原则：拿不准就降一级但保留 INFO 说明；绝不臆造不存在的问题充数；每条发现必须能在 diff 中指出具体位置。

## 报告模板（写入 `letwork/review.md`）

每轮评审覆盖旧报告：新报告置顶，历史轮次保留在下方折叠/分段。

```markdown
# Review — <change-name>

- 轮次：第 1 轮
- 时间：YYYY-MM-DD HH:mm
- 范围：<base..HEAD 或 工作树>，文件数/增删行
- 规范基线：openspec/standards/ 下实际加载的文件清单 + 冻结日期
- 校验：openspec validate --strict 结果（通过/失败摘要）

## 结论
- BLOCKER n / MAJOR n / MINOR n / SUGGESTION n / INFO n
- 放行条件：<一句话>

## 轴一：规范符合度
| 级别 | 规则 ID | 位置 | 问题 | 建议 |
|---|---|---|---|---|
| BLOCKER | J-ERR-02 | src/Foo.java:42 | catch 后只 e.printStackTrace() | 包装业务异常上抛并记录上下文 |

## 轴二：spec / 场景一致性
| Requirement / Scenario | 实现位置 | 测试证据 | 结论 |
|---|---|---|---|
| Requirement: 登录失败处理 / Scenario: 密码错误 | AuthController.java:58 | AuthTest#whenWrongPassword | ✅ |
| Requirement: X / Scenario: 锁定后重试 | — | — | ❌ 未实现 |

## 轴三：设计模式优化建议（SUGGESTION，不阻断）
| 位置 | 观察 | 建议模式/重构 | 收益 | 成本 | 用户决定 |
|---|---|---|---|---|---|
| XxxService.java:88 | 按类型 6 个 if 分支分发 | 策略接口 + Map 注册表 | 新增类型不改本类（OCP） | 中（约半天） | 待决定 |
| —（无像样建议时写「无」，禁止凑数） | | | | | |

## 超范围改动
- （无 / 文件:行 + 说明，要求回退或补 spec）

## INFO / 待确认
- ...
```

## git notes 摘要格式（可选项）

仅当用户选择把评审写到 git 备注时使用。挂到被评审 HEAD（`git notes --ref=review add/append -F`），保持 10–20 行纯文本：

```text
[letwork review] 第 N 轮 · YYYY-MM-DD HH:mm
范围: <base 短sha>..<head 短sha>（<文件数> 文件）
结论: BLOCKER 0 / MAJOR 0 / MINOR 2 / SUGGESTION 3
机械检查: mvn test <n> 通过；p3c 0 违规；validate --strict 通过
设计建议: ①<一句话> ②<一句话> ③<一句话>
完整报告: openspec/changes/<change>/letwork/review.md
```

## 引用约定

- 规则 ID 必须来自项目 `openspec/standards/` 实际存在的分册；分册缺失的维度写 `规范缺失(维度)` 作为 INFO，不能编造 ID。
- 位置格式 `相对路径:行号`；跨文件写起始位置并在描述中列出其余文件。
- 修复后重评只复核受影响条目，但必须重跑 validate 与受影响测试。
