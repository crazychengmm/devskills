# Java 规范机械化：p3c-pmd 接入指南（2026-11 实测）

把冻结的 java-alibaba.md checklist 变成 CI/本地可执行检查。以下版本组合经 Maven Central 真实构建验证（JDK 21、Maven 3.9.16）。

## 版本兼容矩阵（关键暗坑）

| 组件 | 版本 | 说明 |
|---|---|---|
| `com.alibaba.p3c:p3c-pmd` | **2.1.1**（截至验证日最新） | 基于 **PMD 6** 内核的规则包 |
| `org.apache.maven.plugins:maven-pmd-plugin` | **3.13.0** | 3.13.x 系列默认 PMD6；**3.21+ 默认 PMD7，加载 p3c 2.1.1 会失败** |

不要用「插件最新版 + p3c 最新版」的直觉组合——两者大版本必须配套，或等 p3c 发布 PMD7 兼容版本。

## pom.xml 配置

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-pmd-plugin</artifactId>
  <version>3.13.0</version>
  <configuration>
    <targetJdk>11</targetJdk>
    <!-- 首版先报告不阻断：评审时按报告人工决定；稳定后可改 true 做 CI 红线 -->
    <failOnViolation>false</failOnViolation>
    <printFailingErrors>true</printFailingErrors>
    <rulesets>
      <ruleset>rulesets/java/ali-comment.xml</ruleset>
      <ruleset>rulesets/java/ali-concurrent.xml</ruleset>
      <ruleset>rulesets/java/ali-constant.xml</ruleset>
      <ruleset>rulesets/java/ali-exception.xml</ruleset>
      <ruleset>rulesets/java/ali-flowcontrol.xml</ruleset>
      <ruleset>rulesets/java/ali-naming.xml</ruleset>
      <ruleset>rulesets/java/ali-oop.xml</ruleset>
      <ruleset>rulesets/java/ali-orm.xml</ruleset>
      <ruleset>rulesets/java/ali-other.xml</ruleset>
      <ruleset>rulesets/java/ali-set.xml</ruleset>
    </rulesets>
  </configuration>
  <dependencies>
    <dependency>
      <groupId>com.alibaba.p3c</groupId>
      <artifactId>p3c-pmd</artifactId>
      <version>2.1.1</version>
    </dependency>
  </dependencies>
</plugin>
```

注意：

- ruleset 文件名是 **`ali-flowcontrol.xml`**（不是 ali-flow.xml）；共 10 个文件，可从 p3c-pmd jar 内 `rulesets/java/` 目录核实。
- `targetJdk` 不要设 21：PMD6 不认识高版本号；源码语法级别由 `maven.compiler.release` 控制，两者独立。
- 运行：`mvn pmd:pmd`，报告在 `target/pmd.xml` 与 `target/site/pmd.html`；违规计数 `grep -c "<violation" target/pmd.xml`。

## review 中的用法

- 第零轴：`mvn -q test`（编译+测试）→ `mvn -q pmd:pmd`（规范）→ 行宽抽查（J-FMT-03 ≤120，PMD6 的 p3c 不查行宽，用 awk 补）。
- pmd 报告 0 违规时，规范轴只需人工过 PMD 不覆盖的点（架构分层、业务语义、安全规则 J-SEC 的上下文判定）。
- 第三方库版本写入 pom 前先查 Maven Central metadata 确认存在，不凭记忆写版本号。
