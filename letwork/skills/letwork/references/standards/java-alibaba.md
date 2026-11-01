# Java 代码规范 checklist — 阿里巴巴 Java 开发手册（黄山版）精简改编

> **来源与版权**：本文件是《阿里巴巴 Java 开发手册·黄山版》（2022.2.3 发布）的**精简 checklist 衍生物**（非原文），按 Apache License 2.0 署名改编。
> 官方仓库：https://github.com/alibaba/p3c （完整 PDF、IDE 插件、p3c-pmd 规则均在仓库内；本文件只列可在 review 中逐条判定的检查点，详细说明/正例/反例以官方手册为准）。
> 规则级别沿用手册：【强制】/【推荐】/【参考】。ID 前缀 `J-`，冻结日期记入 openspec/standards/README.md。
> 适用 JDK 8+；项目已有明确约定（如框架强制的命名）从其约定，在 review 报告中标注豁免。

## 一、编程规约

### 命名风格 J-NAMING

- **J-NAMING-01【强制】** 标识符只能用字母/数字；类名 UpperCamelCase（DO/BO/DTO/VO/AO/PO/UID 等缩写例外可全大写），方法/变量 lowerCamelCase。
- **J-NAMING-02【强制】** 包名全小写、点分单数；抽象类用 `Abstract`/`Base` 开头；异常类 `Exception` 结尾；测试类 `被测类Test`。
- **J-NAMING-03【强制】** 类型与括号之间不加额外标识：数组定义 `int[] arr` 而非 `int arr[]`。
- **J-NAMING-04【强制】** POJO 布尔属性不要加 `is` 前缀（部分序列化框架会丢 is 导致反序列化失败）。
- **J-NAMING-05【强制】** 数据库列名含下划线映射到 POJO 用 `@Column`/Map 注解显式映射，不靠魔法名字猜。
- **J-NAMING-06【强制】** 包/类/方法/变量不使用拼音与英文混合、不直接用中文；杜绝不规范英文缩写（如 condition 缩成 condita）。
- **J-NAMING-07【推荐】** 接口和实现：服务/dao 接口不加 `I` 前缀；实现类若必须区分用 `Impl` 后缀；抽象与实现的命名体现设计模式（如 `XxxFactory`）。
- **J-NAMING-08【参考】** 常量/枚举名见词知义；枚举类带类型名后缀可接受（如 ProcessStatusEnum）。

### 常量定义 J-CONST

- **J-CONST-01【强制】** 不允许任何魔法值（未定义常量的字面量）直接出现在代码中。
- **J-CONST-02【强制】** `long l = 1L` 用大写 L，不用小写 l（与 1 混淆）。
- **J-CONST-03【推荐】** 常量按层次归类、集中管理：跨应用共享 → 二方库 constant 类；应用内共享 → 应用 constant；子系统内共享 → 子系统 constant。
- **J-CONST-04【推荐】** 常量类分层：非常量不要塞进 constant 类；常量类按业务域拆分，不要一个巨类。

### 代码格式 J-FMT

- **J-FMT-01【强制】** 大括号：非空代码块换行写法（K&R 风格），空块写成 `{}` 可同行。
- **J-FMT-02【强制】** 左小括号后、右小括号前不空格；任何二目/三目运算符两侧加空格；`if/for/while/switch/do` 与括号间加空格。
- **J-FMT-03【强制】** 单行字符数 ≤120，超长在逗号/运算符前断行，新行缩进 2 级（4 空格起，共 8 空格）。
- **J-FMT-04【强制】** 方法参数换行、链式调用换行规则与手册一致；单个方法总行数建议 ≤80。
- **J-FMT-05【强制】** IDE 提交前统一格式化（项目提供 code-style XML/p3c-formatter，禁止个人 tab/空格混用；缩进 4 空格）。
- **J-FMT-06【推荐】** 单个方法总行数 ≤80；类内顺序：静态字段→实例字段→构造器→公有方法→私有方法，getter/Setter 放最后。
- **J-FMT-07【推荐】** 相邻方法、不同逻辑块、字段区之间可用一行空行分隔；方法内连续空行不超过 1 行。

### OOP 规约 J-OOP

- **J-OOP-01【强制】** 静态方法/变量用类名访问，不用实例引用。
- **J-OOP-02【强制】** 覆写方法必须加 `@Override`。
- **J-OOP-03【强制】** 可变对象不能用来做 HashMap 的 key；若用了必须重写 hashCode/equals（或用不可变对象）。
- **J-OOP-04【强制】** `equals` 用常量或确定非空对象在前：`"yes".equals(x)`；包装类用 `equals` 比较，不用 `==`（Integer 缓存陷阱）。
- **J-OOP-05【强制】** 所有 POJO 类必须有包装类型（不用基本类型）；POJO 必须重写 `toString`（日志排障）；RPC/DAO 出参同理。
- **J-OOP-06【强制】** 构造方法里禁止加入业务逻辑，初始化逻辑放 init 方法；构造方法可被覆写的方法调用导致子类状态异常。
- **J-OOP-07【强制】** `String.split` 对 `.`/`|` 等需转义；字符串反转义等场景注意 `\\`。
- **J-OOP-08【强制】** `BigDecimal` 比较用 `compareTo`，不用 `equals`（1.0 与 1.00 equals 不等）；金额计算必须用 BigDecimal 且显式指定标度与舍入模式（通常 `RoundingMode.HALF_UP`）；**禁止** `new BigDecimal(double)`，用 `valueOf` 或 String 构造。
- **J-OOP-09【强制】** 集合转 Map 时注意 key 冲突策略（merge function），不允许静默覆盖。
- **J-OOP-10【强制】** 遍历集合时删除元素必须用 `Iterator.remove()`（或 removeIf / 过滤后重建）。
- **J-OOP-11【推荐】** 慎用 ArrayList 的 subList 视图（修改父集合抛 ConcurrentModificationException）；集合转数组用 `toArray(new T[0])`；数组转集合注意 `Arrays.asList` 返回定长视图，add/remove 抛异常。
- **J-OOP-12【推荐】** 类成员与方法访问控制从严：能 private 不 protected，能 final 不留非 final。
- **J-OOP-13【推荐】** 工具类构造器私有化（final class + private constructor），防止实例化与继承。

### 集合处理 J-COLL

- **J-COLL-01【强制】** `hashCode` 与 `equals` 必须同时重写，且遵守规范（相等对象 hashCode 相同）。
- **J-COLL-02【强制】** ArrayList 的 subList、asList、toArray 三个陷阱见 J-OOP-11；subList 不能强转 ArrayList。
- **J-COLL-03【强制】** 使用集合泛型，不出现裸类型（raw type）；`new HashMap<>()` 指定容量预估（初始容量 = 预计元素 / 0.75 + 1）。
- **J-COLL-04【强制】** 多线程场景使用并发集合（ConcurrentHashMap/CopyOnWriteArrayList）或外部同步；Collections.synchronizedXxx 的锁对象文档化。
- **J-COLL-05【推荐】** entrySet 遍历 Map，不用 keySet 后再 get（两次查询）；JDK8+ 优先 forEach。
- **J-COLL-06【推荐】** 去重/有序需求区分 HashSet/TreeSet/List，不滥用。

### 并发处理 J-CONC

- **J-CONC-01【强制】** 获取单例对象要保证线程安全（ Holder/枚举单例）；双重检查锁的实例字段必须 `volatile`。
- **J-CONC-02【强制】** 创建线程/线程池必须通过 ThreadFactoryBuilder/自定义工厂命名（`业务-用途-序号`），禁止裸 `new Thread()` 与 `Executors.newXxx`（无界队列易 OOM）。
- **J-CONC-03【强制】** 线程池显式 new ThreadPoolExecutor 并指定核心/最大/队列容量/拒绝策略/线程名；shutdown 有闭环。
- **J-CONC-04【强制】** `SimpleDateFormat` 非线程安全，用 ThreadLocal 或 java.time 格式化器；共享可变状态必须同步或用并发工具。
- **J-CONC-05【强制】** 加锁顺序在整个系统保持一致（按固定顺序获取多锁），防死锁；锁范围最小化。
- **J-CONC-06【强制】** `ThreadLocal` 必须 try/finally remove，线程池复用导致脏数据/内存泄漏。
- **J-CONC-07【强制】** 多锁/资金/幂等类场景，锁与事务边界清楚（锁在事务外还是内要显式设计并注释）。
- **J-CONC-08【推荐】** 优先用 JUC 工具（AtomicXxx、ConcurrentXxx、CountDownLatch）而非 wait/notify；条件判断用 while 防虚假唤醒。
- **J-CONC-09【参考】** 慎用 `@Async`/异步任务的异常处理与上下文传递（traceId、安全上下文）。

### 控制语句 J-CTRL

- **J-CTRL-01【强制】** switch 的每个 case 要么 continue/return/break，要么注释说明穿透；default 必须有。
- **J-CTRL-02【强制】** if/else/for/while/do 必须写大括号，即使单行。
- **J-CTRL-03【强制】** 三目运算符注意自动拆箱 NPE（`Boolean a = cond ? b : c`，b/c 为包装类型混基本类型时）。
- **J-CTRL-04【推荐】** 卫语句提前 return，避免超过 3 层 if 嵌套。
- **J-CTRL-05【推荐】** 条件表达式中不执行复杂方法调用，先取布尔变量并命名。
- **J-CTRL-06【推荐】** 循环体内不进行耗时无关操作（远程调用、查库）；注意循环内 N+1。
- **J-CTRL-07【参考】** 方法返回值可以为 null 时调用方必须判空；公开接口优先返回空集合/Optional 而非 null（团队约定统一）。

### 注释规约 J-COMMENT

- **J-COMMENT-01【强制】** 类、属性、方法的注释用 Javadoc 规范（`/** */`），抽象方法必须用 Javadoc 说明用途、入参、返回、异常。
- **J-COMMENT-02【强制】** 所有抽象类/接口的公有方法都要有 Javadoc（实现类方法 {@inheritDoc} 可接受）。
- **J-COMMENT-03【强制】** 注释掉的代码不允许提交；TODO/XXX 标记必须附责任人与处理时间/单号。
- **J-COMMENT-04【推荐】** 方法内部注释与代码同缩进；坏命名不靠注释救，先改名。
- **J-COMMENT-05【参考】** 好的命名与函数结构优先；注释讲 why，不讲 what。

## 二、异常日志

### 异常处理 J-ERR

- **J-ERR-01【强制】** Java 类库定义的异常（NPE/IndexOutOfBounds 等）不要用业务异常方式抛出，先做判空/边界处理。
- **J-ERR-02【强制】** catch 异常不能只 printStackTrace/吞掉；要么处理、要么转译上抛（保留 cause：`new BizException(msg, e)`）。
- **J-ERR-03【强制】** finally 块中禁止 return（会覆盖 try 中的异常/返回）；关闭资源用 try-with-resources。
- **J-ERR-04【强制】** 捕获异常与抛出异常必须匹配，不允许 catch 一个大 Exception/Throwable 掩盖不同问题（边界兜底除外，且要记日志）。
- **J-ERR-05【强制】** 方法返回值可以为 null 时调用方做防御；RPC/远程调用的异常按可重试/不可重试分类。
- **J-ERR-06【推荐】** 自定义异常分业务异常（可预期，带错误码）与系统异常（需告警）两系；错误码枚举集中管理。
- **J-ERR-07【推荐】** 参数校验在入口统一（JSR-303），业务内部不重复校验同一约束。

### 日志规约 J-LOG

- **J-LOG-01【强制】** 应用中不直接使用日志系统 API（Log4j/SLF4J 实现），依赖 SLF4J 门面。
- **J-LOG-02【强制】** 日志文件至少保存 15 天（运维约定）；日志使用占位符 `log.info("...{}", x)`，禁止字符串拼接。
- **J-LOG-03【强制】** 异常日志必须含异常栈：`log.error("msg", e)`；禁止 `log.error(e.getMessage())`。
- **J-LOG-04【推荐】** 分级使用：ERROR 影响可用性/需告警；WARN 可容忍但异常；INFO 业务关键节点；DEBUG 排障。
- **J-LOG-05【推荐】** 日志含 traceId/业务主键；可以用 MDC 在入口注入。
- **J-LOG-06【参考】** 可扩展/可开关的高级日志（大对象、批量明细）用 debug 并判 isDebugEnabled 或 guard。

## 三、单元测试 J-TEST

- **J-TEST-01【强制】** AIR 原则：自动化（Automatic）、独立（Independent）、可重复（Repeatable）；不依赖外部环境与执行顺序。
- **J-TEST-02【强制】** BCDE 原则：Border 边界、Correct 正确性、Design 设计文档、Error 错误（异常/空值/越界/超时）。
- **J-TEST-03【强制】** 测试方法不互相调用、不依赖执行顺序；每个用例独立准备数据并清理。
- **J-TEST-04【推荐】** 测试方法名 `test被测方法_场景_期望`；断言精确不断言「不抛异常」；核心分支覆盖率达到团队红线（参考 ≥80%）。
- **J-TEST-05【推荐】** 数据库/中间件用嵌入式或测试容器；mock 边界（HTTP/RPC/DB）而不是 mock 被测逻辑。

## 四、安全规约 J-SEC

- **J-SEC-01【强制】** 用户权限校验：在服务端对每一个受保护的 URL/方法做鉴权，不信任前端隐藏。
- **J-SEC-02【强制】** SQL 只允许参数化（PreparedStatement / MyBatis #{}），禁止字符串拼接 `${}` 拼用户输入（白名单字段除外并注释）。
- **J-SEC-03【强制】** 用户输入做合法性校验（长度、范围、类型、白名单枚举、特殊字符）；文件上传校验类型/大小/内容并隔离存储。
- **J-SEC-04【强制】** 防 XSS：输出到 HTML/JS 上下文做转义；富文本做白名单过滤。CSRF/重定向校验按框架能力开启。
- **J-SEC-05【强制】** 密钥/密码/Token 不硬编码、不打日志、不进异常信息；配置中心/凭据系统管理。
- **J-SEC-06【推荐】** 反序列化只对白名单类型（不直接反序列化不可信数据）；依赖保持更新（fastjackson/log4j 类漏洞教训）。

## 五、MySQL 规约

### 建表 J-DDL

- **J-DDL-01【强制】** 表名/字段名全小写、下划线分词、不超 32 字符、不使用数据库保留字（建议用业务前缀）；表名单数。
- **J-DDL-02【强制】** 主键 `id` bigint unsigned（或业务需要的类型），存储金额用 decimal，不用 float/double。
- **J-DDL-03【强制】** 几乎所有字符串用 varchar 而非 text；必须是 utf8mb4；每个字段必须有 comment（中文含义+枚举值）。
- **J-DDL-04【强制】** 字段尽量 NOT NULL 并给默认值（NULL 给优化/计算带来坑）；布尔/状态用 tinyint。
- **J-DDL-05【强制】** 表必备 `create_time`/`modify_time`（或团队统一审计字段）；逻辑删除标志明确。
- **J-DDL-06【推荐】** 单表行数预估、分表策略/冷热分离在设计期说明；避免预留过多扩展字段。
- **J-DDL-07【参考】** 字段名见名知意，枚举值在注释中逐项列出。

### 索引 J-IDX

- **J-IDX-01【强制】** 高频查询字段建索引；联合索引区分度高的在前；避免在索引列上做函数/运算/隐式类型转换。
- **J-IDX-02【强制】** 业务上具有唯一特性的字段必须建唯一索引（即使多表联合）。
- **J-IDX-03【强制】** 防止冗余/重复索引（如 (a,b) 与 (a)）；join 字段类型字符集必须一致并建索引。
- **J-IDX-04【推荐】** 单表索引数量建议 ≤5，单个联合索引字段数 ≤5；ORDER BY / GROUP BY 注意利用索引有序性。
- **J-IDX-05【推荐】** 利用覆盖索引避免回表；分页深翻页用游标/延迟关联优化。

### SQL 语句 J-SQL

- **J-SQL-01【强制】** 不使用 `SELECT *`；只取需要的列。
- **J-SQL-02【强制】** 禁止 count(列名) 替代 count(*) 的随意使用（语义差异）；count 多列不合法。
- **J-SQL-03【强制】** IN 集合控制数量（建议 <1000，分批）；避免隐式转换、前导模糊 `%x`。
- **J-SQL-04【强制】** 禁止存储过程做业务逻辑；禁止大表 DDL 无评审（锁表/gh-ost）。
- **J-SQL-05【推荐】** 分页、批量操作有上限；UPDATE/DELETE 必须带精确 WHERE 并先 SELECT 验证。
- **J-SQL-06【推荐】** 事务保持短小，不跨 RPC/HTTP；事务内不塞外部调用。

### ORM 映射 J-ORM

- **J-ORM-01【强制】** 不使用 ${} 拼接用户输入；动态 SQL 的表名/字段名用服务端白名单。
- **J-ORM-02【强制】** 大批量操作分批（建议每批 ≤1000 行）；批量语句长度/包大小受控。
- **J-ORM-03【推荐】** 一对一/一对多结果映射与 N+1 问题检查（懒加载在循环外触发）。
- **J-ORM-04【推荐】** POJO 与 DO 分层；不把持久化对象直接暴露给外部接口。

## 六、工程结构

### 应用分层 J-LAYER

- **J-LAYER-01【推荐】** 标准分层：controller/服务接口层 → service/manager(通用业务封装) → dao/mapper → 领域对象（DO/DTO/VO/BO/Query）。
- **J-LAYER-02【强制】** 层间依赖单向：controller 不直接访问 dao；跨域调用走 service；不允许反向依赖。
- **J-LAYER-03【强制】** 二方库/工具类不耦合业务 web 上下文；工具方法无状态。
- **J-LAYER-04【推荐】** 配置统一管理（application.yml/profile/配置中心），环境差异不写死。

### 二方库依赖 J-DEP

- **J-DEP-01【强制】** 依赖只在需要的模块声明，不全局滥加；版本由 dependencyManagement/BOM 统一锁定。
- **J-DEP-02【强制】** 排除冲突/冗余传递依赖；上线前看依赖树（同一库不允许出现多个大版本）。
- **J-DEP-03【推荐】** 不依赖 SNAPSHOT 发布；二方库升级评估兼容性与回滚。
- **J-DEP-04【参考】** 工具类库全公司/全组收敛（commons 系列、Guava 版本统一）。
