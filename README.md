# MoonIon

Amazon Ion 1.0 text and binary codec for MoonBit.

MoonBit programs can load and dump Ion values without a Python or Java runtime. The library understands annotations, local symbol tables, decimals, timestamps, sexp, and both Ion encodings.

## Install

```text
moon add ZJH-666-ZJH/moonion@0.1.0
```

Package publication to mooncakes.io is optional and not part of this repository's default workflow.

## Quick start

```moonbit
fn main {
  match @moonion.load("Product::{ id: \"sku-42\", count: 3 }") {
    Ok(v) => {
      println(@moonion.dumps(v))
      let binary = @moonion.dumps_bytes(v)
      match @moonion.load_bytes(binary) {
        Ok(again) => println(again.annotations[0])
        Err(e) => println(e.message())
      }
    }
    Err(e) => println(e.message())
  }
}
```

## Scope

Supported:

- Ion 1.0 values: null, bool, int, float, decimal, timestamp, symbol, string, clob, blob, list, sexp, struct
- annotations and `$ion_1_0`
- local `$ion_symbol_table` when writing/reading binary
- text `load` / `loads` / `dumps`
- binary `load_bytes` / `dumps_bytes`

Not in this version:

- Ion 1.1
- Ion Schema
- Ion Hash
- shared symbol table catalogs over the network
- AWS service clients

## Examples

```text
moon run examples/catalog_record
moon run examples/binary_roundtrip
moon run examples/sexp_filter
moon run cmd/main
```

## Tests

```text
moon check --target wasm-gc --deny-warn
moon test --target wasm-gc
moon test --target js
```

## License

Apache-2.0. See `LICENSE` and `THIRD_PARTY.md`.
