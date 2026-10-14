# MoonIon

MoonIon 是用 MoonBit 实现的 Amazon Ion 1.0 文本与二进制编解码库。适合读取 Ion 格式的日志、配置、产品记录及离线数据，也可以给 MoonBit 工具提供与其他 Ion 实现交换数据的能力。

和 JSON 相比，Ion 能直接表达精确十进制数、带精度和时区的时间戳、符号、注解、字节数据及 S-expression。MoonIon 保留这些类型，不先转换为 JSON；struct 用字段数组表示，因此重复字段也不会被覆盖。核心库只依赖 MoonBit 标准库，Python 仅用于开发时的交叉验证。

## 当前版本说明

GitHub `main` 是 **0.1.3 修复候选版本**，包含二进制兼容性修复。**该版本尚未发布到 MoonCakes**。已发布的 0.1.2 不包含这些修复，不能用它验证本次修复结果。

在正式发布前，请从源码运行：

```sh
git clone https://github.com/ZJH-666-ZJH/moonion.git
cd moonion
moon check --deny-warn
moon test
moon run examples/binary_roundtrip
```

已发布版本的安装命令是 `moon add ZJH-666-ZJH/moonion@0.1.2`，这仅用于旧版本。后续发布 0.1.3 后会同步更新安装说明。

## 环境和接口

- `moonc` 不低于 0.10.15（使用该版本的 `Int32` 类型名）。
- 默认后端为 `wasm-gc`；CI 检查并构建 `wasm-gc`、`wasm`、`js`、`native`，测试后三者中的 `wasm-gc`、`js` 和 `native`。
- 使用本库的包在 `moon.pkg` 中导入：

```text
import {
  "ZJH-666-ZJH/moonion" @ion,
}
```

| 接口 | 用途 |
| --- | --- |
| `load` / `loads` | 读取文本的第一个值 / 整个数据流 |
| `dumps` / `dumps_all` | 写出单个值 / 带版本标记的文本数据流 |
| `load_bytes` / `loads_bytes` | 读取二进制的第一个值 / 整个数据流 |
| `dumps_bytes` / `dumps_bytes_all` | 写出含 BVM 和本地符号表的二进制 |
| `text_to_binary` / `binary_to_text` | 转换编码，不经过 JSON |

`load` 系列返回首个用户值，但会检查整个输入；空数据流返回 `EmptyDocument`。需要读取多个值时使用 `loads`。解析失败返回 `Result::Err(IonError)`，可通过 `code()` 和 `message()` 取得诊断。

## 三个可运行示例

### 1. 产品记录：注解、decimal 和 timestamp

```moonbit nocheck
///|
fn main {
  let product = @ion.catalog_sample()
  println(@ion.dumps(product))
}
```

运行 `moon run examples/catalog_record`。这个示例中的 `catalog` 指产品目录记录，不是共享符号表目录。金额使用十进制系数和指数存储，不依赖浮点数。

### 2. 文本转二进制，再读取字段

```moonbit nocheck
///|
fn main {
  match @ion.load("Product::{id: \"sku-42\", price: 200d0}") {
    Ok(value) => {
      let bytes = @ion.dumps_bytes(value)
      println(@ion.hex_encode(bytes))
      match @ion.load_bytes(bytes) {
        Ok(restored) => println(@ion.dumps(restored))
        Err(error) => println(error.message())
      }
    }
    Err(error) => println(error.message())
  }
}
```

运行 `moon run examples/binary_roundtrip`。二进制写出会收集字段名、符号值和注解，生成本地符号表，再编码记录。读入时先应用符号表，并按每个值声明的长度限制读取范围。

### 3. S-expression 过滤表达式

```moonbit nocheck
///|
fn main {
  let expression = @ion.sexp_sample()
  println(@ion.dumps(expression))
}
```

运行 `moon run examples/sexp_filter`。输出为 `('+' 1 ('*' 2 3))`，S-expression 成员用空白分隔，不使用 list 的逗号。这里提供的是数据表示，不是表达式求值器。

## 符号表

文本和二进制均支持本地符号表、空符号槽、`imports:$ion_symbol_table` 追加，以及版本标记后的表重置。读取共享符号表时，调用方可以显式提供目录：

```moonbit nocheck
///|
fn main {
  let catalog : Array[@ion.SharedSymbolTable] = [
    { name: "fields", version: 1, symbols: [Some("id"), Some("name")], },
  ]
  let input = "$ion_symbol_table::{imports:[{name:\"fields\",version:1,max_id:2}]} {$10:\"sku-42\"}"
  match @ion.load(input, catalog~) {
    Ok(value) => println(@ion.dumps(value))
    Err(error) => println(error.message())
  }
}
```

目录按名称和版本精确匹配，不发起网络查询。未提供的符号保留 SID 槽位，真正引用无法解析的 SID（包括 SID 0）时返回错误，而不是把它错误替换为空字符串。`SymbolTable.locals` 现在使用 `Array[String?]`，直接操作这个字段的旧调用方需要适配。

## 兼容性与质量验证

2026 年 10 月 14 日的本地结果：

- `wasm-gc`、`js` 各 **132 个测试全部通过**。
- **97 组固定输入**由 Amazon 的 `amazon.ion==0.13.0` 生成二进制；MoonIon 能正确读入，包括大整数、十进制负零、长长度/符号 ID、时间精度、注解和所有 256 种 clob 字节。
- **100 组输出交叉验证**：官方实现分别读取 MoonIon 的文本和二进制，再比较类型和值。额外样例包括产品记录、S-expression 和导入共享符号表的二进制。
- 对固定输入逐字节截断检查；完整版本标记/符号表可以是合法的空流，未完成的用户值不能被误认为已读完。
- 枚举 **65,536 组两字节二进制尾部**进行无崩溃检查。这个检查不等于证明所有非法输入都已覆盖。

```sh
moon test --target wasm-gc
moon test --target js
python -m pip install amazon.ion==0.13.0
python tests/verify_interop.py --target wasm-gc
python tests/verify_interop.py --target js
```

固定输入保存在 `tests/interop-fixtures.json`，生成脚本为 `tests/generate_interop.py`。Python 不参与库运行。CI 还在 Ubuntu 上构建、测试 `native` 并运行同样的交叉验证；本地 Windows 若无 C 编译器，则不能完成 native 构建。

这些数据是正确性检查，不是性能跑分，也不代表已通过 Amazon Ion 全部官方符合性测试集。问题说明和复现命令见 `docs/acceptance-repairs.md`。

## 支持范围与边界

支持 Ion 1.0 的 null、bool、int、float、decimal、timestamp、symbol、string、clob、blob、list、sexp 和 struct；保留 typed null、注解、decimal 的指数/负零、timestamp 的精度/未知偏移和重复字段。文本支持注释、常用及 Unicode 转义、长字符串和长 clob。

当前限制：

- 整个输入在内存中解析，不提供流式读取器。
- 容器/注解解析深度上限为 256；单个符号表最多 1,000,000 个本地/导入槽位。
- decimal 指数使用有符号 32 位整数；timestamp 本地年份为 1–9999，小数秒最多 4096 位。
- 不提供共享表版本替代策略、未知 SID 值模型、Ion 1.1、Ion Schema、Ion Hash、AWS 客户端或网络目录。
- `values_equal` 是文本表示比较，不是完整的 Ion 语义等价算法。

## 源码结构

- `value.mbt`、`bigint.mbt`、`decimal.mbt`、`timestamp.mbt`：值模型与精度。
- `text_reader.mbt` / `text_writer.mbt`：文本语法与输出。
- `binary_reader.mbt` / `binary_writer.mbt`：类型描述符、长度边界及数值编码。
- `symbol.mbt` / `catalog.mbt`：符号槽和共享表导入。
- `regression_wbtest.mbt` / `interop_wbtest.mbt`：错误路径回归与外部固定输入。

## 许可证

Apache-2.0，见 `LICENSE`。行为参考 Amazon Ion 1.0 规范及 ion-python，使用范围和原项目许可证见 `THIRD_PARTY.md`。未将 Python 源码移入核心库。
