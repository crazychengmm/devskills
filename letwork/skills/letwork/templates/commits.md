# Commits 记账 — <change-name>

> 每次任务/步骤提交后追加一行。SHA 用 `git rev-parse --short HEAD` 取。
> 一个任务原则上对应一次提交；同任务多次提交如实逐行登记。

| # | 任务/步骤 | 文件（相对路径，逗号分隔） | Commit SHA | Subject | 时间 |
|---|---|---|---|---|---|
| 1 | 例：2.1 登录失败统一错误体 | src/auth/AuthController.java, src/auth/AuthTest.java | a1b2c3d | feat(auth): 登录失败返回统一 401 错误体 | YYYY-MM-DD HH:mm |
