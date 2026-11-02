# 狗粮测试 #11：Go HTTP 服务 + 多 change 并行 + 时间注入 + skip_specs

- 日期：2026-11-03
- 被测：letwork v0.13
- 项目：
  - `v-goredirect`（Go 标准库 HTTP 短链服务，net/http + httptest + RWMutex）
  - `v-pytoken`（Python 令牌桶，FakeClock）
- 覆盖此前从未走过的四条路径。

## 1. Go HTTP 服务（首次）

- Store（map + RWMutex，写锁内双检保证并发同 slug 只一个成功）、Handler（POST/GET/302/404/409/400）、cmd 可执行。
- httptest 表驱动 7 场景 + 响应结构 + 32 goroutine 同 slug 并发（恰好 1 个 201、31 个 409），`go test -race -count=3` 通过。
- 真实启动冒烟第一次用固定 `sleep 1` 得到全 000 假失败 → 改就绪轮询后 201/409/302/404/400 全对。

## 2. 多 change 并行路由（首次）

- v-goredirect 主特性归档后，同时创建 `add-health-detail` 与 `add-link-listing` 两个活动 change。
- `openspec list` 正确显示两个 change；分别 validate --strict 通过；各自独立实现/提交；先归档 A 后，B 的 validate 仍通过（change 目录隔离再次验证）；归档后主 specs 含 3 个 capability。

## 3. 时间相关代码测试纪律（首次系统化）

- v-pytoken 令牌桶通过注入 Clock（生产 time.monotonic / 测试 FakeClock）零真实睡眠，精确断言 1.5s→1 个令牌、容量上限、批量不扣减，6 用例瞬时完成。
- 与 jretry 的 Sleeper 注入跨语言呼应，规则沉淀进 test.md 5a。

## 4. skip_specs 维护型变更（首次）

- 主特性归档后做内部重构 change `refactor-extract-refill`（提取重复的补充逻辑），`.openspec.yaml` 写 `skip_specs: true`、无 specs/ 目录。
- `validate --strict` 输出 INFO「zero deltas accepted」；归档后主 spec 零改动；既有 6 测试全绿作为验收。

## 回灌 v0.14

1. routing.md：多 change 在用户授权自主推进时的确定性选择（受阻优先 → 创建最早 → 进度最靠后），声明依据并列出其余 change。
2. test.md 5a：时间相关代码必须注入时钟，禁真实 sleep 等墙钟，含 FakeClock 与回拨用例。
3. test.md 5b：真实进程/HTTP 冒烟必须就绪轮询（healthz 探针 + 超时上限），禁止固定 sleep（本次 000 假失败实证）。
4. openspec-cheats：skip_specs 端到端做法（元数据/产物形态/validate 输出/归档效果）。
