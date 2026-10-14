# 0.1.3 修复记录（尚未发布 MoonCakes）

## 问题与修复

| 问题 | 修复 | 回归证据 |
| --- | --- | --- |
| VarUInt / VarInt 终止位方向错误 | 最高位 1 表示最后一字节；VarInt 首字节保留符号位，后续按大端拼接 | 边界值黄金字节；官方二进制固定输入 |
| 标准 `1d0` 被误读 | 指数和系数严格按 decimal payload 读取；`e00100ea528001` 解析为 `1d0` | 邮件 decimal 回归测试 |
| 外部本地符号表无法读取，产品记录二进制被官方实现拒绝 | 修正可变整数、注解长度、符号槽和字段 SID；增加调用方提供的共享表目录 | 97 组外部输入；产品记录及共享表交叉读写 |
| `200d0` 往返成 `-72d0` | signed-magnitude 系数在高位为 1 时补符号字节；负零不丢失 | `200d0`、`-200d0`、128 边界及负零固定输入 |
| `.001` 变 `.1` | 按指数补前导零，保留小数精度；二进制 UTC 字段与本地偏移正确转换 | `.001`、`.000`、`.0100`、13 位小数秒及跨日/跨年 |
| clob 的 `FF` 变为 `C3BF` | clob 独立按字节处理，文本非 ASCII 必须使用字节转义 | 256 种字节的文本/二进制往返，官方输入/输出 |
| `+00:99` 被接受 | 分别检查时区小时和分钟；检查日期、时分秒及小数范围 | 非法偏移、非闰年 2 月 29 日、秒 60 回归 |
| 截断 decimal 被接受 | 每个 payload 有独立读取上界；指数不能跨越外层容器边界读取 | 每组固定输入的截断前缀；畸形注解/容器/变长整数 |
| sexp 输出逗号 | sexp 使用空白分隔；拒绝输入中的非法逗号 | `sexp_sample` 官方交叉验证 |

同时修复了浮点数文本的类型丢失及负零、Int64 最小值、三字节 UTF-8 过长编码、Base64 非法填充、数值下划线/前导零、非法转义、符号关键字、符号表空槽/追加/重置、嵌套深度与长度/SID 整数溢出。增加长字符串、长 clob、Unicode 转义和换行续接。struct 中的 NOP 不应因其不使用的字段 SID 无法解析而报错，这条路径也有独立测试。

## 独立验证的方法

不是只比较本库自己的写入和读取结果。

1. 使用 Amazon 的 `amazon.ion==0.13.0` 为 97 组合法文本生成固定二进制，保存在 JSON 文件中。MoonBit 测试读取这些二进制，并与对应文本解析结果比较。
2. 示例程序实际调用 MoonIon 编码；Python 脚本让官方读取器分别读取其文本和二进制输出，用 `ion_equals` 比较类型和值。共 100 组，包含共享表导入数据和两个项目样例。
3. 在修复前的提交 `fc8bf25eee6d134e60c060b174afff2be94aa907` 上仅添加相同的 97 个外部固定输入测试：总计 113 个测试，57 通过、56 失败。原有 16 个测试本来就全部通过，因此不能作为外部兼容性的充分证据。
4. 修复后 `wasm-gc` 和 `js` 后端各 132 个测试全部通过，两个后端的 100 组交叉验证均通过。
5. 对 97 组固定输入逐字节截断；枚举 65,536 组短二进制输入进行无崩溃检查。

输入范围覆盖所有 Ion 1.0 基本类型，但不是全量官方符合性测试集。本次没有性能对比数据，不声称达到 ion-python 的全部语法兼容范围。

## 插桩覆盖率

`moon coverage analyze -- -f summary` 在 wasm-gc 上报告：核心库 2,210 / 2,739 个插桩点命中，约 **80.7%**。统计仅包含根目录生产 `.mbt`，不将 CLI/示例计入分母；这是工具报告的插桩点覆盖率，不是行覆盖率或完整符合性证明。

## 复现

```sh
moon version --all
moon check --target wasm-gc --deny-warn
moon build --target wasm-gc
moon test --target wasm-gc
moon test --target js
python -m pip install amazon.ion==0.13.0
python tests/verify_interop.py --target wasm-gc
python tests/verify_interop.py --target js
moon coverage analyze -- -f summary
```

最初修复及覆盖率测量使用 `moonc v0.10.14+7d59c7ec9-dev`，随后在 `moonc v0.10.15+943464bfa` 稳定版上重新执行测试与官方交叉验证。已适配 0.10.15 的 `Int32` 类型名及格式化输出；最终源码最低要求为 0.10.15。四个后端的静态检查通过；wasm-gc、wasm、js 构建通过。Windows 环境没有系统 C 编译器，native 构建/测试由 Ubuntu CI 验证，不能用静态检查冒充 native 构建成功。

## 发布状态与 API 变更

本次仅修复并更新 GitHub；`moon.mod` 预留 0.1.3。没有发布 MoonCakes、没有改动已发布 0.1.2，也没有创建发布标签。请在登录正确的 MoonCakes 账号后另行发布修复版本。

- `load` / `loads`、二进制读取和转换接口增加可选 `catalog` 参数，原本不传目录的调用仍有效。
- 新增 `SharedSymbolTable`。
- `SymbolTable.locals` 从 `Array[String]` 改为 `Array[String?]`，用于保留未知槽位；直接构造/修改这个字段的调用方需要适配。
- 无法解析的 SID 返回 `InvalidSymbol`，不再把它错误映射为空字符串。
