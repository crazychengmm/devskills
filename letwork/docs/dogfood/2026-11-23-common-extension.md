# 实测反馈 #17：通用编码补全规范（CE-1~CE-5，v0.20）

- 日期：2026-11-23
- 来源：用户要求在阿里手册基础上增加可读性补全，项目可自由修改；并确认设计模式前置对齐（v0.19 已实现，本次核实挂载点完整）。

## 新增 standards/common-extension.md（默认值 + 自定义区）

| ID | 规则 | 级别 | review 判定 |
|---|---|---|---|
| CE-1 | 业务代码禁止 catch 原生 Exception/Throwable；业务异常统一 common 模块自定义，原生异常只在边界转换（保留 cause）；仅框架最外层处理器可兜底 | 强制 | 违反=BLOCKER |
| CE-2 | 方法返回禁止 null：Optional/(值,ok,error)/空集合；错误用异常不用 null；可空必须显式标注 | 强制 | 违反=BLOCKER |
| CE-3 | 单方法 ≤80 行（阈值项目可调），按校验/主流程/组装拆私有方法 | 推荐 | 违反=MAJOR |
| CE-4 | 循环嵌套 ≤2 层；第三层用 Map 索引/抽方法/表驱动/推导式消除 | 强制 | 违反=MAJOR |
| CE-5 | 可读性总则：单一职责、意图命名、注释讲 why、惯用写法、重复两次即抽象 | 强制 | 按影响定级 |

## 可修改性设计

- 文件下半部为「项目自定义区」，复制到 `openspec/standards/` 后阈值与条目都可改；code/review 以项目内版本为准。
- 规范冻结流程（code.md 三选项）默认带上 common-extension；review-format.md 补充 CE 的 BLOCKER/MAJOR 映射。

## 设计模式前置确认（用户追问，已在 v0.19 实现）

核实 `design-alignment.md` 在 analyze.md（2a-1）、code.md（骨架优先）、SKILL 铁律 5 三处挂载完整，无需重复建设；本次在 common-extension 中加了联动说明，保证规范文件与流程文件互相可达。
