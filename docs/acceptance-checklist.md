# 验收清单

本仓库按验收要求保留可复现证据，MoonCakes 发布由维护者手动完成，本文件不代替发布操作。

| 要求 | 仓库内证据 | 验证方式 |
| --- | --- | --- |
| MoonBit 为主要语言，moonc ≥ 0.10.14 | `*.mbt`、`moon.mod`、CI 版本门禁 | `moon version --all`；CI 检查 `moonc` 版本 |
| 公开仓库与清晰历史 | Git 提交记录、`repository` 字段 | `git log --oneline`、GitHub 仓库页面 |
| 核心功能可用 | 文本/二进制读写、Ion 值模型、符号表模块 | `moon check`、示例运行 |
| README 与可复现示例 | `README.md`、`examples/`、`cmd/main` | 按 README 命令执行 |
| 持续集成 | `.github/workflows/ci.yml` | 覆盖格式、四目标检查、测试、示例 |
| 核心路径测试 | `moonion_test.mbt`、`moonion_wbtest.mbt` | `moon test --target wasm-gc` |
| MoonCakes 发布 | `moon.mod` 的模块元数据 | 由维护者在 MoonCakes 页面手动发布 |
| OSI 许可证 | `LICENSE`、`moon.mod` | Apache-2.0 文本与元数据一致 |

## 本地验收命令

```text
moon version --all
moon fmt
moon info
moon check --target wasm-gc --deny-warn
moon test --target wasm-gc
moon test --target js
moon run examples/catalog_record
moon run examples/binary_roundtrip
moon run examples/sexp_filter
moon run cmd/main
```

`native` 目标需要本机 C 编译器；GitHub Actions 在 Ubuntu runner 上会执行该目标。发布前请使用与 CI 相同或更高版本的 MoonBit 工具链。
