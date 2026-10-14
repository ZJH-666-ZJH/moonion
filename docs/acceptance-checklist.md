# 验收核对清单

此清单区分代码检查和实际发布，不能代替主办方复验。

| 验收要求 | 证据 | 本次状态 |
| --- | --- | --- |
| MoonBit 为主要语言，moonc ≥ 0.10.14 | 根目录核心 `.mbt`；CI 版本门禁 | 本地 0.10.14 开发版，满足最低版本 |
| 公开仓库、清晰提交记录 | 原仓库 `ZJH-666-ZJH/moonion`、原有 Git 历史 | 恢复原始历史，以新增提交修复，不重写旧提交 |
| 核心功能、清晰结构 | 值模型、文本/二进制、符号表模块 | 97 组官方固定输入及 100 组交叉输出验证；详细范围见修复记录 |
| README 安装、使用、示例可复现 | 两份 README、3 个业务示例、interop 示例 | 文档区分旧包与未发布修复版 |
| CI 检查、构建、测试 | `.github/workflows/ci.yml` | 四后端检查/构建，三后端测试和官方交叉验证；以该提交实际 CI 结果为准 |
| 至少一个可运行示例 | `examples/catalog_record`、`binary_roundtrip`、`sexp_filter` | 本地运行；CI 再运行 |
| 核心路径完整测试 | 原测试、`regression_wbtest.mbt`、`interop_wbtest.mbt` | wasm-gc/js 各 132 个测试通过，包含失败路径；并非全量官方符合性认证 |
| 发布 mooncakes.io | 已有 0.1.2；待发布修复版本 0.1.3 | **修复版尚未发布，按维护者要求暂缓** |
| OSI 开源许可证及参考项目许可 | `LICENSE`、`THIRD_PARTY.md`、模块元数据 | Apache-2.0；Python 仅为测试依赖，不复制其源码 |

本地验证与交叉验证命令见 `docs/acceptance-repairs.md`。Windows 环境缺少 C 编译器，native 构建与测试必须检查 Ubuntu CI，不能仅凭本地 `moon check --target native` 判断通过。
