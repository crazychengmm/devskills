# 狗粮测试 #13：4 项目验证 v0.15（intake 进场摸底 + 欠债闭环）

- 日期：2026-11-04
- 项目：v-jcache（Java TTL 缓存）、v-pycsvjoin（Python CSV 关联）、v-golru（Go 泛型 LRU）、v-gowatch（Go 目录快照差异）

## 重点：v0.15 intake/欠债机制端到端验证（v-jcache 两阶段）

1. phase-1 故意带两处技术债提交（null 校验重复两份、System.out 日志）+ 一处构建层欠债（无静态检查）。
2. phase-2 以「重新进场」方式跑 intake：产出 project-profile.md（含 Mermaid）与 debt-backlog.md（DEBT-001/002/003）。
3. 新 change `add-cache-stats`（命中/未命中统计）触及 Cache.put/get → analyze 2a 关键词匹配命中 DEBT-001/002 → 自主授权模式决定一并修复（提取 requireKey、移除 System.out、改 AtomicLong 计数）；DEBT-003（p3c）与本次不关联 → DEFERRED 保留。
4. 11 测试全绿后关闭 DEBT-001/002（CLOSED + change 名），台账如实记录关闭方式；评审 notes 注明欠债处置。
5. 结果：**欠债发现→关联复现→修复→关闭/暂缓**闭环全部按规程跑通。

## 其他三项目

| 项目 | 关键点 | 测试 |
|---|---|---|
| v-pycsvjoin | stdlib csv，inner/left join，右列 r. 前缀 | 4 |
| v-golru | Go 泛型 + 双向链表 LRU，16 goroutine race | 5（race×2） |
| v-gowatch | SHA-256 快照差异 + CLI 基线 | 3 |

## 本批再次被门禁/validate 拦截的问题（未进入提交）

- gowatch 编译错误（Diff.Empty 误写 `diff`）——validate 之外由 vet 拦截；**但批量脚本中 `go test 2>&1 | tail` 吞了退出码，仍执行了 init 提交**（红提交事故），修复后 amend 首个提交恢复绿色。
- gowatch spec「错误传播」缺 Scenario——validate 明确报错，补上后通过。
- CacheStatsTest 继承 CacheTest 复用时钟，private 工厂方法不可继承，改包级可见。
- 批量回归从错误 cwd 用绝对 -s 跑 unittest 导致 ImportError 误报。

## 回灌（v0.15 → v0.15.1）

test.md 第 0 节补两条编排反例（管道吞退出码、跨目录 discover 误报），均来自本批真实事故；intake 机制本身验证通过无需改动。
