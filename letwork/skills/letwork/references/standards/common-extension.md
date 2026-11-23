# 通用编码规范补全（common-extension）

> **定位**：本文是阿里 Java 手册（`java-alibaba.md`）/ Go Uber / Python Google 等语言分册之外的**跨语言补全规则**，默认值见下，**项目可自由修改**：复制到项目 `openspec/standards/common-extension.md` 后，阈值、条目都可以按团队习惯增删，code/review 以项目内修改后的版本为准。
> 与 `common.md` 的关系：common.md 是基础通用 checklist（命名/函数/提交等），本文件聚焦**可读性硬约束与异常/空值纪律**，两者冲突时以项目内显式修改为准，否则本文件优先级更高（更严格）。

## CE-1 异常：只 catch 自定义异常，禁止兜 JDK/语言原生异常【强制】

- 业务代码中禁止 `catch (RuntimeException)`、`catch (Exception)`、`catch (Throwable)` 这类无差别捕获；Go 中禁止 `recover` 后静默吞错，Python 中禁止 `except Exception` 兜底后不处理。
- 业务异常**统一定义**：多模块项目放 `common`（或 `shared`/`error` 包），单模块项目放独立 exception 包/文件；按领域细分（如 `NotFoundException`/`ConflictException`/`ValidationException`），继承统一基类。
- 语言/平台层面的异常（NPE、IllegalState、IOException 等）：
  - 能在边界校验预防的（非法入参、状态不对），提前显式判断并抛出自定义异常；
  - 无法预防的（IO/远程失败），在**边界层**捕获并转换为自定义异常，保留 cause（`new XxxException(msg, e)`），不丢原始堆栈。
- **唯一豁免**：框架最外层统一处理器（如 `@RestControllerAdvice`、HTTP middleware、进程入口）可以兜底原生异常，职责是转成标准错误响应并记录，业务层不允许。
- 判定：code 自检发现宽 catch 即返工；review 中出现违反按 BLOCKER 处理。

## CE-2 空值：方法返回禁止 null【强制】

- 查不到/无结果：Java/Kotlin 用 `Optional<T>`；Go 用 `(值, ok)` 或 `(值, error)` 约定；Python 用 `Optional[T]` 类型标注并在无结果时返回 `None` 且文档/命名显式表达（如 `find_optional_xxx`）。
- 集合/Map 返回空结果用空集合（`List.of()`/`Collections.emptyList()`），不返回 null。
- 错误语义不用 null 表达：失败走自定义异常（CE-1），成功与否不走「返回 null 表示出错」。
- 入参为 null 的处理：公开方法在入口显式校验并抛自定义 `ValidationException`，内部方法靠调用约定保证非空，不层层判空。
- 字段可空必须显式：Java 注解/Optional、Go 指针或 sql.Null*、Python `Optional[]`，禁止无标注的隐式可空。

## CE-3 方法长度：单方法默认 ≤ 80 行【推荐，阈值可调】

- 计数含空行与注释；超过阈值必须拆分。
- 推荐拆法：按「参数校验 → 主流程 → 结果组装/转换」切分，每段一个私有方法，方法名表达意图（`validateXxx`/`loadXxx`/`toResponse`），而不是 `do1/do2/handle`。
- 项目可在本文件顶部把阈值改为 60/100 等；review 以修改后的值为准。

## CE-4 循环嵌套：默认最多 2 层【强制】

- 两层（外层遍历 + 内层查找/转换）是上限；出现第三层 for/while 即返工。
- 常用解法：
  - 内层是「按键找值」→ 先建 Map 索引，把 O(n²) 查找降为 O(1)；
  - 内层是数据转换 → 抽成独立方法（`toView(item)`）；
  - Go 用表驱动 + 辅助函数，Python 用推导式/字典预聚合，Java 用 Stream（仅限逻辑清晰时，不为流式而流式）。
- 嵌套与 CE-3 通常同时出现，长方法里的多层循环优先按本条处理。

## CE-5 可读性总则【强制】

- 一个方法只做一件事；名字表达业务意图，禁止 `data/info/tmp/handle2/process` 这类空泛命名（循环短变量 i/j/k 除外）。
- 注释解释**为什么**（约束、坑、业务背景），不复述代码在做什么；逻辑需要长注释才能懂时，先重构命名与结构。
- 优先语言惯用且易懂的写法（Java record/Optional、Go 表驱动、Python 推导式），禁止为炫技牺牲可读性的嵌套三元、超长链式调用。
- 一段代码评审者需要问「这在干嘛」即视为不达标，先重写再评审。
- 重复出现两次以上的逻辑抽公共方法/工具，不允许复制粘贴后各自演化。

## 设计模式/算法前置确认（与 design-alignment 联动）

- 功能涉及算法或设计模式时，**编码前必须先对齐**：候选方案（解决什么问题/结构/代价）→ 推荐 → 用户确认 → 落 ADR，再写实现；详见 `design-alignment.md`。
- 编码顺序：抽象骨架（接口/模型/签名，先编译通过）→ 参考实现打通主链路 → 同构实现并把重复逻辑抽到基类/工具 → 边界异常。
- 该条在 review 中检查实现是否偏离已确认的 ADR，偏离必须新建 ADR，不允许静默改设计。

---

## 项目自定义区（复制到项目后在此填写/修改）

<!--
修改示例：
- CE-3 阈值调整为：单方法 ≤ 60 行。
- 新增 CE-6：Controller 方法 ≤ 30 行。
- 豁免：xxx 包内的 generated 代码不受 CE-3/CE-4 约束。
-->

- （待填写）
