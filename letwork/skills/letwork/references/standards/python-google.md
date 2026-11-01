# Python 代码规范 checklist — Google Python Style Guide + PEP 8 / PEP 257（索引式精简）

> **来源**：
> - Google Python Style Guide（CC-BY 3.0）：https://google.github.io/styleguide/pyguide.html（条目标题为原文小节号/名）
> - PEP 8（Style Guide for Python Code）：https://peps.python.org/pep-0008/
> - PEP 257（Docstring Conventions）：https://peps.python.org/pep-0257/
>
> 本文件是索引式 checklist，一条一句可检查标准，细节与正反例看原文。级别为本 skill 标注：【强制】= PEP8/语言陷阱/明确要求，【推荐】= Google 默认主张，【参考】= 视场景。ID 前缀 `P-`。
> 前提：项目代码过配置好的 linter（Google 指南要求 pylint；现实项目常用 ruff/flake8 + black/isort/mypy，以项目配置为准）。Python 版本 ≥3.9（类型注解写法按项目版本）。

## 2 Language Rules（语言规则）

- **P-LINT-01【强制】 Lint**：所有代码跑 linter；抑制警告用最小范围（行内 `# noqa: <code>`）并写理由，不全局关掉检查。
- **P-IMP-01【强制】 Imports**：只用 `import x` / `from x import y`；不使用通配符 import；每个 import 独占一行；顺序三组：标准库 / 第三方 / 本项目，组间空行（isort/ruff I 规则）。
- **P-IMP-02【推荐】**：为避免名字冲突用 `import foo as bar`（只在必要时）；不与内建名（list/type/id/file）冲突。
- **P-PKG-01【推荐】 Packages**：优先完整模块路径导入；同包内相对导入可接受，避免深入的相对导入（`from ..` 超过两级）。
- **P-EXC-01【强制】 Exceptions**：谨慎使用异常；自定义异常继承项目统一基类（最终继承 Exception，不继承 BaseException）；不用 assert 做运行时校验（优化模式会丢）。
- **P-EXC-02【强制】**：裸 `except:` 禁止；至少 `except Exception:` 且尽量捕获具体类型；异常处理要么恢复要么带上下文重新抛出（`raise X from e`）。
- **P-GLB-01【推荐】 Mutable Global State**：避免可变全局状态；需要时用模块级常量（全大写）或显式单例/依赖注入，不靠全局可变变量传参。
- **P-COMP-01【推荐】 Comprehensions**：推导式可用于简单映射/过滤；多层嵌套（>2 个 for）、复杂副作用的改写循环。
- **P-ITER-01【推荐】 Default Iterators/Operators**：容器遍历直接 `for x in container`、成员判断 `x in container`；字典遍历 `.items()`；不要按索引遍历 list。
- **P-GEN-01【参考】 Generators**：惰性大序列用生成器；注意生成器只能迭代一次，需要复用时物化成 list。
- **P-LAMBDA-01【推荐】 Lambda Functions**：lambda 只用于一次性小表达式；需要命名复用、超过一行或难读时 def。
- **P-COND-01【推荐】 Conditional Expressions**：三元表达式只用于简单情形，不嵌套。
- **P-DEF-01【强制】 Default Argument Values**：默认参数绝不使用可变对象（[]、{}、set()）——函数定义期共享导致串数据；用 None 并在函数内构造。
- **P-PROP-01【推荐】 Properties**：轻量计算、无副作用的访问用 property；昂贵计算、可能失败、需要传参的用普通方法。
- **P-BOOL-01【推荐】 True/False Evaluations**：判空直接 `if seq:`；与 None 比较必须 `is None`/`is not None`；布尔判断注意 `False==0`、空容器与 None 的语义区别，别混用。
- **P-DEC-01【推荐】 Decorators**：装饰器谨慎使用、文档化；functools.wraps 保留元信息；避免装饰器隐式做 IO/改签名到调用方无法预期。
- **P-THD-01【强制】 Threading**：不依赖内建类型原子性做并发正确性；共享状态用 queue/锁/asyncio；IO 并发优先高级抽象，不裸造线程池。
- **P-POWER-01【参考】 Power Features**：反射、动态 metaclass、importlib 等高级特性只在不可避免时使用，并注释充分理由。
- **P-TYPE-01【推荐】 Type Annotated Code**：新代码写类型注解；公共 API 必填；尽量过 mypy/pyright（配置严格度按项目）。

## 3 Style Rules（风格规则）

- **P-SEMI-01【强制】 Semicolons**：行尾不写分号；一行不用分号拼多条语句。
- **P-LINE-01【强制】 Line length**：每行 ≤80 字符（Google；团队统一用 black 的 88 也可，但一个项目只能一个值）；长 URL/注释可例外。
- **P-PAREN-01【推荐】 Parentheses**：宁用括号隐式续行不用 `\`；除元组外可省括号就省；长条件用括号包裹分行。
- **P-IND-01【强制】 Indentation**：4 空格缩进，禁止 Tab；续行与括号元素对齐或悬挂缩进 4 空格。
- **P-BLANK-01【强制】 Blank Lines**：顶层定义之间 2 空行；方法之间 1 空行；`class` 定义后第一行不空行；函数内逻辑段间最多 1 空行。
- **P-WS-01【强制】 Whitespace**：括号内侧、逗号/分号前不加空格；二目运算符两侧 1 空格；关键字参数 `=` 两侧不加空格；不在行尾留空白。
- **P-SHEBANG-01【强制】 Shebang**：只在可直接执行的程序文件写 `#!/usr/bin/env python3`；被 import 的模块不写。
- **P-DOC-01【强制】 Comments and Docstrings**：模块、类、公有函数有 docstring（PEP 257）；函数 docstring 描述用途、Args/Returns/Raises（Google 风格分节）；注释讲 why，不复述代码。
- **P-DOC-02【推荐】**：docstring 用三重双引号、首尾样式符合 PEP 257（单行可同行）；测试方法可改用 docstring 描述场景。
- **P-STR-01【推荐】 Strings**：项目内引号风格统一（black 默认双引号）；日志/消息用 f-string 或 .format，日志给 logger 时优先 `%s` 惰性参数；拼接长字符串用隐式相邻拼接/join。
- **P-FILE-01【强制】 Files, Sockets**：文件/连接/锁等资源用 with 管理；不依赖 GC 关闭。
- **P-TODO-01【强制】 TODO Comments**：`# TODO(用户名/issue): 描述`，无主 TODO 不允许长期存在。
- **P-IMP-03【强制】 Imports formatting**：imports 全部在文件顶部、按 isort 分组；变量/常量定义不插在 import 中间。
- **P-STMT-01【强制】 Statements**：一行一句；`if/for/while` 体不挤在同一行。
- **P-GS-01【推荐】 Getters and Setters**：新式类用 property 而非 getX/setX；property 保持轻量、幂等、无副作用。
- **P-NAMING-01【强制】 Naming**：
  - 模块/包：`lower_with_underscores`（包优先无下划线短名）；
  - 函数/方法/变量：`lower_with_underscores`；
  - 类/异常：`CapWords`；
  - 常量：`ALL_CAPS`；
  - 私有内部：单下划线前缀；避免双下划线名称改写除非确有必要；
  - 不与内建/关键字冲突（`list_`、`type_` 可接受）。
- **P-NAMING-02【强制】**：`self`/`cls` 作为首参名固定；参数名不与保留字冲突。
- **P-MAIN-01【强制】 Main**：可执行入口写成 `def main(): ...` 并以 `if __name__ == "__main__": main()` 守卫，导入模块不产生副作用。
- **P-FUNC-01【推荐】 Function Length**：函数建议 ≤40 行（不含空行/注释），长于此时检查是否可拆；不追求机械达标，但优先小型化、单一职责。
- **P-TYPE-02【推荐】**：注解写法用内置泛型（`list[int]`、`X | None`）按项目最低 Python 版本决定；避免在注解里传字符串化前向引用（`from __future__ import annotations` 统一处理）。

## 测试（Google 指南 3.x 测试章节补充）

- **P-TEST-01【强制】**：测试文件 `*_test.py`，测试框架 pytest 或 unittest（项目统一）；测试独立、可重复、不依赖顺序与外网。
- **P-TEST-02【推荐】**：测试函数 `test_<被测>_<场景>_<期望>`；用 fixture/setUp 准备，不共享可变状态；断言具体值不断言「不抛异常」。
