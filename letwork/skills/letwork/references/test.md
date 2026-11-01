# test — 测试阶段

目标：为刚完成的任务拿到**真实的测试证据**。不许凭代码阅读宣称「应该能过」。

## 0. 退出码纪律（先读，本次踩过坑）

- 判定通过只看**测试进程自己的退出码**，不看输出里有没有 OK 字样。
- 禁止 `test ... | head/tail/grep` 这种管道直接接 `set -e`：管道退出码是最后一个命令的，测试失败会被吞掉，随后照常提交。正确姿势二选一：
  - 重定向到文件再判：`python3 -m unittest discover > /tmp/t.txt 2>&1; rc=$?; tail -5 /tmp/t.txt; [ $rc -eq 0 ]`；
  - 或 shell 先 `set -o pipefail`。
- 被测对象本身用退出码表达结果（扫描器/lint/grep：1=检出问题）时，显式接住：`cmd; rc=$?`，再断言 `rc` 等于**预期值**，既别被 `set -e` 误伤中断，也别把非零误读为测试失败。
- 一次测试红了之后的任何提交都必须等重跑变绿；红测试提交是最高级别流程事故，journal 记 PROBLEM。

## 1. 确定测试范围

- 当前任务覆盖的 requirement/scenario 对应哪些测试：优先新增/修改的测试文件；其次受影响模块的既有测试。
- 任务描述或 plan 中标注的验收场景必须有对应测试触达；没有就先补测试（补测试本身算当前任务范围，勾选前完成）。

## 2. 运行命令（按语言；以项目实际构建配置为准，先查 package/pom/go.mod）

- Go：`go test ./... -count=1`（改动局部时先 `go test ./<pkg>/... -run <名>` 快速反馈，再全量）。竞态敏感代码加 `-race`。
- Java/Maven：`mvn -q test`（或 `-Dtest=<类>#<方法>` 限定）；Gradle：`./gradlew test --tests <pattern>`。
- Python：`python -m pytest <路径> -v`（无 pytest 时用 `python -m unittest`，并在 journal 记录工具缺失）。
- 前端/Node：以项目 package.json scripts 为准（`npm test` / `vitest` / `jest`）。

命令在项目根执行；长命令给足超时；沙箱/权限导致跑不了时，让用户用 `! <命令>` 代跑并把输出贴回。

## 3. 结果处理

- **全过**：把证据写入 `letwork/journal.md`：命令、通过用例数/耗时（一行摘要）、覆盖的场景列表；然后提示进入 review 或 commit。
- **失败**：如实贴失败用例名与关键报错；在 journal 记 `[PROBLEM] <现象> → <定位> → <处理>`；回到 code 修复后重跑，连续多次失败要向用户暴露并求助，不静默吞掉。
- **跳过/无法执行**：说明原因（无测试框架、缺中间件），给出最小替代验证（构造输入手动跑一次等）并标注证据等级，由用户决定是否放行。

## 4. 完成门禁

- 所有新增/变更行为都有自动化测试触达；当前任务范围内测试全绿。
- 不做与任务无关的大范围重构去「顺手修好测试」；既有失败测试先如实记录，区分「本次引入」与「历史遗留」。

## 5. 自举验收（工具类项目必做）

被开发对象本身是扫描器/解析器/linter/代码生成器等「处理代码的工具」时，除靶场测试外必须加一步**拿它处理它自己的代码**：

- 扫描器扫自身源码（预期：0 命中或仅有在 INFO 中说明的受控项）、解析器解析自身全部源文件（预期：0 解析错误）。
- 实测价值很高：Java 版 jsecscan 的自举扫描抓到一个靶场测试发现不了的真 BLOCKER（解析器默认 Java8 语法级别，连自己用的 record 都解析不了）。
- 自举失败按正常缺陷处理：回 code 修复 → 加回归测试 → 重跑，不允许带着「扫不了自己」的工具进入 review。

## 6. 分层业务项目的测试节奏

对 Spring Boot 这类分层应用（ipam 狗粮验证），采用「局部快反馈 + 提交点全量 + 一次真实冒烟」：

- **局部快反馈**：开发单个类时只跑该测试（`mvn test -Dtest=XxxTest`、`go test -run`、`pytest tests/x.py`），不每次全量；
- **提交点全量**：每个 commit 前必须跑完整 `mvn test`（绿色提交不变量，见 commit.md）；
- **测试切片分工**：纯领域值对象用单元测试；DAO 用 H2/Testcontainers 集成测试；Controller 用 WebMvcTest 等切片测试 mock 掉 service；至少保留一个 `@SpringBootTest` 验证整体装配；
- **真实启动冒烟**：涉及 HTTP/消息/启动配置的项目，review 前真实启动一次（fat jar + curl 走一条主链路状态码链），切片测试 mock 掉的序列化、状态码映射只有真跑才暴露。
- **测试库与生产库方言差异要在 design.md 显式列出**：如 H2（MySQL 模式）把 `DEFAULT CURRENT_TIMESTAMP` 列也当作 generated keys，自增主键回填必须 `prepareStatement(sql, new String[]{"id"})` 显式指定键列；H2 BIGINT 与 MySQL INT UNSIGNED 的类型差异也要写明映射。
