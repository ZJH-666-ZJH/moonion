# Changelog

## 0.1.3 — unreleased

- Correct Ion binary VarUInt/VarInt terminal bits and signed decimal coefficients.
- Preserve decimal/float negative zero and timestamp fractional precision; apply UTC offsets on binary read/write.
- Decode text and binary local symbol tables, null slots, append/reset, and caller-supplied shared symbol catalogs.
- Preserve clob bytes; correct S-expression separators and float text types.
- Bound binary payloads, nesting, lengths and SIDs; reject truncated values, invalid offsets, UTF-8, escapes and Base64 padding.
- Add long strings/clobs, Unicode escapes and line continuations; tighten numeric and keyword grammar.
- Adapt to MoonBit 0.10.15 canonical `Int32` type names; require compiler 0.10.15 or newer.
- Add independently generated ion-python fixtures and bidirectional interoperability checks to CI.
- Breaking low-level API change: `SymbolTable.locals` now contains optional symbol texts (`Array[String?]`).

MoonCakes publication is deferred. Existing 0.1.2 packages do not include these fixes.
