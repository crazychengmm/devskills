# code — 编码阶段

一次只做一个任务。前置门禁：tasks.md 已确认；规范已冻结（见下）。

## 1. 语言识别（只读事实，自己查）

按仓库标志判定，可多选：
- Java：`pom.xml` / `build.gradle*`
- Go：`go.mod`
- Python：`pyproject.toml` / `requirements*.txt` / `setup.py`

## 2. 规范门禁（未冻结不得编码）

检查 `openspec/standards/` 目录：存在 `common.md` 与至少一份语言分册、且 `openspec/standards/README.md` 记录了来源与冻结日期 → 视为已冻结，直接 Read 使用。

否则用 AskUserQuestion 让用户三选一（按识别出的语言给推荐项；多语言可多选）：

1. **采用库存规范（推荐）**：从本 skill 的 `references/standards/` 复制——
   - Java → `java-alibaba.md`（阿里巴巴 Java 开发手册·黄山版 checklist）
   - Go → `go-uber.md`（Uber Go Style Guide checklist）
   - Python → `python-google.md`（Google Python Style Guide + PEP 8 checklist）
   - 任意语言都叠加 `common.md`
2. **使用我自己的规范**：用户给文件路径或 URL；读取后转成统一 checklist 格式（规则名 + 一句话检查点 + 规则 ID），保存到 `openspec/standards/<lang>-custom.md`。
3. **仅用通用规范 / 本次跳过规范门禁**：只复制 `common.md`，并在 standards/README.md 与 journal 记录用户的跳过决定（review 阶段会注明规范覆盖不全）。

选定后：
- 复制文件到 `openspec/standards/`；写/更新 `openspec/standards/README.md`：每份规范的来源、版本或抓取日期、许可证链接、冻结日期、适用模块。
- journal 追加 `[DECISION] 规范冻结：<清单>`。
- **冻结后项目副本就是唯一事实源**；skill 库存更新不回改项目副本，需更新时由用户显式决定（review 可提示版本陈旧）。

## 3. 单任务循环

对「下一个未勾选任务」（用户指定了任务号则用指定的）：

0. **工具链预检（第一个编码任务前做一次，切换技术栈时重做）**：先确认解释器/编译器/构建工具真实可用（`python3 --version`、`go version`、`java -version`/`mvn -v`）。不可用就先解决或换栈；**不要在工具链未验证前写实现文件**——曾出现 Go 不可用导致半成品 .go 文件残留、之后被误带入提交的事故。
   - **编译型语言（Java/Go）的第三方 API 纪律**：不熟悉的库 API 先查官方 javadoc 或解压 jar 核实类/方法签名（`javap -cp <jar> <类名>`），不凭记忆写——实测凭记忆写错 3 次（包路径、方法名），编译门禁虽能拦住但浪费往返。
   - **依赖版本先查实**：写 pom.xml/go.mod/requirements 前从 Maven Central metadata、pkg.go.dev、PyPI JSON 确认真实最新版本与兼容性（典型暗坑：p3c-pmd 2.1.1 是 PMD6 内核，必须配 maven-pmd-plugin 3.13.x，插件 3.21+ 默认 PMD7 不兼容，见 [standards/java-p3c-setup.md](standards/java-p3c-setup.md)）。
   - **首次构建给足超时**：Maven/Gradle 首次运行要下载插件与依赖，命令超时设 5–10 分钟；预检阶段先验证制品仓库可达（如 `curl -sI https://repo1.maven.org`）。
1. 复述任务与它覆盖的 requirement、验收场景；说明准备改哪些文件（先给计划，大改动等确认）。
2. Read 冻结规范：`openspec/standards/common.md` + 对应语言分册；编码中实时遵守，规则 ID 可用于解释「为什么这么写」。
3. 实现：只做当前任务范围内的改动；发现必须顺手改的相邻问题，先在 journal 记 `[PROBLEM]` 并询问是否另开任务，不夹带。
4. 自检（默认顺序 code→review→test 下，本阶段门禁只到「编译通过」，不跑测试）：
   - **机械化检查（编译/构建级，零成本先跑）**——
     - Python：`python3 -m py_compile <改动文件>`；行长检查 `awk 'length>80{print FILENAME":"FNR}' <改动 .py 文件>`（默认 80 列；若 pyproject/setup.cfg 配置了更大的 line-length/black，以项目配置为准）；项目已配 `ruff check`/`flake8`/`black --check` 时直接用项目命令；
     - Go：`gofmt -l .` 必须空输出、`go vet ./...`、`go build ./...`；
     - Java：`mvn -q compile`（或 gradle compileJava），项目配了 checkstyle/spotless 时必须跑；接入阿里 p3c-pmd 的项目还要 `mvn -q pmd:pmd`（接法与版本兼容见 [standards/java-p3c-setup.md](standards/java-p3c-setup.md)）；行宽按 J-FMT-03 用 awk 抽查 ≤120；
     - 检查不过 = 编译错误或违反【强制】规范（如行长/格式），先修，不许勾选任务或提交；**同一问题连修 5 轮仍不过按 test.md「重试预算与受阻降级」处理：记 `[STALLED]` → 止血恢复可编译 → 转做不依赖的任务 → 等人介入**。
   - **人工对照规范分册**逐条过改动文件（重点：命名、错误处理、日志、边界/null、并发、资源释放、安全）。
   - 注意：默认流程下**测试在全部代码写完并 review 后集中进行**（test 阶段）；本阶段不写不跑测试。TDD 项目（config.yaml 声明 `test_strategy: tdd`）仍按每任务即测。
5. 勾选 `tasks.md` 中实现类任务 `- [x]`；journal 追加 `[NOTE] <任务号> 实现完成（编译通过，待 review/test）：<摘要>`。勾选是「编译自检已过」的声明，不代表测试通过。
6. 全部实现类任务完成、编译通过后，**主动准备进入 review**（而不是提交后等待）；提交按 commit.md 两级确认执行，code 阶段的提交只需编译绿，test 阶段之后的提交必须测试绿。

## 4. 编码中的问题处理

- 发现需求/任务本身有误或缺失：停止编码，回到 plan（或 analyze）补 spec/任务，重新 validate；journal 记 `[PROBLEM]` + 根因。
- 遇到环境/依赖问题：先自查（日志、官方文档、本地已有配置），把排查过程与结论记 journal；需要用户操作（登录、授权、交互式安装）时明确给出 `! <命令>`。
