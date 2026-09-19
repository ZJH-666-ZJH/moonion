# MoonIon

MoonIon 是一个用 MoonBit 编写的 Amazon Ion 1.0 文本/二进制编解码库，面向日志、配置、离线校验，以及需要读写 AWS 风格 Ion payload 的工具。JSON 表达不了 decimal、timestamp、annotation 和 sexp；现有 CBOR、MessagePack、protobuf 包走的是另一套编码，不能直接读 `$ion_1_0` 文本或带本地符号表的 Ion 二进制。

MoonIon 把 Ion 1.0 的值模型、文本编码和二进制编码做成纯库。调用方可以在没有 Python / Java 运行时的情况下完成往返，并把字段定义留在自己的业务层。

## 主要能力

- 文本 `load` / `loads` / `dumps`：null、bool、int、float、decimal、timestamp、symbol、string、clob、blob、list、sexp、struct。
- 二进制 `load_bytes` / `dumps_bytes`：BVM、type nibble、VarUInt / VarInt。
- annotation 与 `$ion_1_0` 版本标记。
- 写出/读入二进制时维护本地 `$ion_symbol_table`。
- 十进制系数与指数、带精度的 timestamp、blob/clob。
- 稳定错误码 `ION001`–`ION013`，截断二进制、空文档、非法 timestamp 会返回诊断。
- 不绑定 HTTP、AWS SDK 或共享符号表网络目录。

## 处理流程

```text
Ion text  ──►  词法 / 容器解析  ──►  IonValue
Ion binary ─►  BVM + type descriptor ─►  IonValue
                 │
                 ▼
           dumps / dumps_bytes
                 │
        Ion text 或 Ion binary
```

解码按相反方向进行。传输层、文件 IO 和云服务客户端都不在本库范围内。

## 快速开始

调用方包的 `moon.pkg`：

```text
import {
  "ZJH-666-ZJH/moonion" @ion,
}
```

### 1. 解析文本并写成二进制

```moonbit
fn main {
  match @ion.load("Product::{ id: \"sku-42\", count: 3 }") {
    Ok(v) => {
      println(@ion.dumps(v))
      let binary = @ion.dumps_bytes(v)
      match @ion.load_bytes(binary) {
        Ok(again) => println(again.annotations[0])
        Err(e) => println(e.message())
      }
    }
    Err(e) => println(e.message())
  }
}
```

### 2. 构造 catalog 样例

```moonbit
fn main {
  let product = @ion.catalog_sample()
  println(@ion.dumps_all([product, @ion.sexp_sample()]))
}
```

## 安装

```text
moon add ZJH-666-ZJH/moonion@0.1.1
```

## 示例

```text
moon run examples/catalog_record
moon run examples/binary_roundtrip
moon run examples/sexp_filter
moon run cmd/main
```

## 当前不做

- Ion 1.1
- Ion Schema
- Ion Hash
- 共享符号表网络目录
- AWS 服务客户端

## 许可证

Apache-2.0。行为参考 [ion-python](https://github.com/amazon-ion/ion-python) 与 Amazon Ion 1.0 规范；源码为 MoonBit 重写，见 `LICENSE` 和 `THIRD_PARTY.md`。
