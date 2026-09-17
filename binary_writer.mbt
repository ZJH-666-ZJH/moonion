///|
fn write_varuint(out : Array[Byte], value : Int) -> Unit {
  let mut n = value
  if n < 0 {
    n = 0
  }
  let tmp : Array[Int] = []
  if n == 0 {
    tmp.push(0)
  } else {
    while n > 0 {
      tmp.push(n & 0x7F)
      n = n >> 7
    }
  }
  let mut i = tmp.length() - 1
  while i >= 0 {
    if i == 0 {
      push_u8(out, tmp[i])
    } else {
      push_u8(out, tmp[i] | 0x80)
    }
    i -= 1
  }
}

///|
fn write_varint(out : Array[Byte], value : Int) -> Unit {
  let negative = value < 0
  let mut n = if negative { 0 - value } else { value }
  if n == 0 {
    push_u8(out, 0)
  } else {
    let low = n & 0x3F
    n = n >> 6
    if n == 0 {
      if negative {
        push_u8(out, low | 0x40)
      } else {
        push_u8(out, low)
      }
    } else {
      let first = if negative { low | 0xC0 } else { low | 0x80 }
      push_u8(out, first)
      write_varuint(out, n)
    }
  }
}

///|
fn write_type_desc(out : Array[Byte], tid : Int, len : Int) -> Unit {
  if len < 14 {
    push_u8(out, (tid << 4) | len)
  } else {
    push_u8(out, (tid << 4) | 14)
    write_varuint(out, len)
  }
}

///|
fn write_null(out : Array[Byte], tid : Int) -> Unit {
  push_u8(out, (tid << 4) | 15)
}

///|
fn magnitude_bytes(value : BigInt) -> Array[Byte] {
  bytes_to_array(value.digits)
}

///|
fn encode_int(out : Array[Byte], value : BigInt) -> Unit {
  if value.is_zero() {
    write_type_desc(out, TID_POSINT, 0)
  } else {
    let mag = magnitude_bytes(value)
    let tid = if value.negative { TID_NEGINT } else { TID_POSINT }
    write_type_desc(out, tid, mag.length())
    for b in mag {
      out.push(b)
    }
  }
}

///|
fn encode_string_bytes(out : Array[Byte], tid : Int, raw : Bytes) -> Unit {
  let arr = bytes_to_array(raw)
  write_type_desc(out, tid, arr.length())
  for b in arr {
    out.push(b)
  }
}

///|
fn encode_value_body(
  out : Array[Byte],
  table : SymbolTable,
  value : IonValue,
) -> Unit {
  if value.annotations.length() > 0 {
    encode_annotated(out, table, value)
  } else {
    encode_datum(out, table, value.datum)
  }
}

///|
fn encode_annotated(
  out : Array[Byte],
  table : SymbolTable,
  value : IonValue,
) -> Unit {
  let inner : Array[Byte] = []
  let annots : Array[Byte] = []
  for a in value.annotations {
    write_varuint(annots, table.intern(a))
  }
  write_varuint(inner, annots.length())
  for b in annots {
    inner.push(b)
  }
  encode_datum(inner, table, value.datum)
  write_type_desc(out, TID_ANNOT, inner.length())
  for b in inner {
    out.push(b)
  }
}

///|
fn encode_datum(
  out : Array[Byte],
  table : SymbolTable,
  datum : IonDatum,
) -> Unit {
  match datum {
    NullD(t) => {
      let tid = match t {
        NullT => TID_NULL
        BoolT => TID_BOOL
        IntT => TID_POSINT
        FloatT => TID_FLOAT
        DecimalT => TID_DECIMAL
        TimestampT => TID_TIMESTAMP
        SymbolT => TID_SYMBOL
        StringT => TID_STRING
        ClobT => TID_CLOB
        BlobT => TID_BLOB
        ListT => TID_LIST
        SexpT => TID_SEXP
        StructT => TID_STRUCT
      }
      write_null(out, tid)
    }
    BoolD(v) => write_type_desc(out, TID_BOOL, if v { 1 } else { 0 })
    IntD(v) => encode_int(out, v)
    FloatD(v) =>
      if v == 0.0 && !is_nan(v) && !is_inf(v) {
        write_type_desc(out, TID_FLOAT, 0)
      } else {
        let raw = bytes_to_array(f64_to_be_bytes(v))
        write_type_desc(out, TID_FLOAT, 8)
        for b in raw {
          out.push(b)
        }
      }
    DecimalD(v) => encode_decimal(out, v)
    TimestampD(v) => encode_timestamp(out, v)
    SymbolD(v) => encode_symbol(out, table, v)
    StringD(v) => encode_string_bytes(out, TID_STRING, utf8_encode(v))
    ClobD(v) => encode_string_bytes(out, TID_CLOB, v)
    BlobD(v) => encode_string_bytes(out, TID_BLOB, v)
    ListD(v) => encode_seq(out, table, TID_LIST, v)
    SexpD(v) => encode_seq(out, table, TID_SEXP, v)
    StructD(v) => encode_struct(out, table, v)
  }
}

///|
fn encode_symbol(out : Array[Byte], table : SymbolTable, name : String) -> Unit {
  let sid = table.intern(name)
  if sid == 0 {
    write_type_desc(out, TID_SYMBOL, 0)
  } else {
    let tmp : Array[Byte] = []
    let mut n = sid
    if n == 0 {
      tmp.push((0).to_byte())
    } else {
      let stack : Array[Byte] = []
      while n > 0 {
        stack.push((n & 255).to_byte())
        n = n >> 8
      }
      let mut i = stack.length() - 1
      while i >= 0 {
        tmp.push(stack[i])
        i -= 1
      }
    }
    write_type_desc(out, TID_SYMBOL, tmp.length())
    for b in tmp {
      out.push(b)
    }
  }
}

///|
fn encode_decimal(out : Array[Byte], value : IonDecimal) -> Unit {
  if value.coefficient.is_zero() && value.exponent == 0 {
    write_type_desc(out, TID_DECIMAL, 0)
  } else {
    let inner : Array[Byte] = []
    write_varint(inner, value.exponent)
    let mag = magnitude_bytes(value.coefficient)
    if mag.length() == 0 {
      if value.coefficient.negative {
        push_u8(inner, 0x80)
      } else {
        push_u8(inner, 0)
      }
    } else {
      for b in mag {
        inner.push(b)
      }
      if value.coefficient.negative {
        inner[inner.length() - mag.length()] = (inner[inner.length() -
        mag.length()].to_int() |
        0x80).to_byte()
      }
    }
    write_type_desc(out, TID_DECIMAL, inner.length())
    for b in inner {
      out.push(b)
    }
  }
}

///|
fn encode_timestamp(out : Array[Byte], ts : IonTimestamp) -> Unit {
  let inner : Array[Byte] = []
  if ts.offset_unknown {
    write_varint(inner, -0)
  } else {
    write_varint(inner, ts.offset_minutes)
  }
  write_varuint(inner, ts.year)
  match ts.precision {
    Year => ()
    Month => write_varuint(inner, ts.month)
    Day => {
      write_varuint(inner, ts.month)
      write_varuint(inner, ts.day)
    }
    Minute => {
      write_varuint(inner, ts.month)
      write_varuint(inner, ts.day)
      write_varuint(inner, ts.hour)
      write_varuint(inner, ts.minute)
    }
    Second => {
      write_varuint(inner, ts.month)
      write_varuint(inner, ts.day)
      write_varuint(inner, ts.hour)
      write_varuint(inner, ts.minute)
      write_varuint(inner, ts.second)
    }
    Fractional => {
      write_varuint(inner, ts.month)
      write_varuint(inner, ts.day)
      write_varuint(inner, ts.hour)
      write_varuint(inner, ts.minute)
      write_varuint(inner, ts.second)
      write_decimal_payload(inner, ts.fraction)
    }
  }
  write_type_desc(out, TID_TIMESTAMP, inner.length())
  for b in inner {
    out.push(b)
  }
}

///|
fn encode_seq(
  out : Array[Byte],
  table : SymbolTable,
  tid : Int,
  values : Array[IonValue],
) -> Unit {
  let inner : Array[Byte] = []
  for v in values {
    encode_value_body(inner, table, v)
  }
  write_type_desc(out, tid, inner.length())
  for b in inner {
    out.push(b)
  }
}

///|
fn encode_struct(
  out : Array[Byte],
  table : SymbolTable,
  fields : Array[IonField],
) -> Unit {
  let inner : Array[Byte] = []
  for f in fields {
    write_varuint(inner, table.intern(f.name))
    encode_value_body(inner, table, f.value)
  }
  write_type_desc(out, TID_STRUCT, inner.length())
  for b in inner {
    out.push(b)
  }
}

///|
fn encode_local_table(out : Array[Byte], table : SymbolTable) -> Unit {
  let names = table.local_names()
  if names.length() == 0 {
    ()
  } else {
    let symbols : Array[IonValue] = []
    for name in names {
      symbols.push(ion_string(name))
    }
    let st = ion_struct([ion_field("symbols", ion_list(symbols))]).with_annotation(
      "$ion_symbol_table",
    )
    let scratch = symbol_table_new()
    encode_value_body(out, scratch, st)
  }
}

///|
pub fn dumps_binary_all(values : Array[IonValue]) -> Bytes {
  let table = symbol_table_new()
  collect_symbols(table, values)
  let out : Array[Byte] = []
  push_u8(out, 0xE0)
  push_u8(out, 0x01)
  push_u8(out, 0x00)
  push_u8(out, 0xEA)
  encode_local_table(out, table)
  for v in values {
    encode_value_body(out, table, v)
  }
  array_to_bytes(out)
}

///|
pub fn dumps_binary(value : IonValue) -> Bytes {
  dumps_binary_all([value])
}

///|
fn collect_symbols(table : SymbolTable, values : Array[IonValue]) -> Unit {
  for v in values {
    collect_value_symbols(table, v)
  }
}

///|
fn collect_value_symbols(table : SymbolTable, value : IonValue) -> Unit {
  for a in value.annotations {
    let _ = table.intern(a)
  }
  match value.datum {
    SymbolD(s) => {
      let _ = table.intern(s)
    }
    ListD(xs) => collect_symbols(table, xs)
    SexpD(xs) => collect_symbols(table, xs)
    StructD(fs) =>
      for f in fs {
        let _ = table.intern(f.name)
        collect_value_symbols(table, f.value)
      }
    _ => ()
  }
}

///|
fn write_decimal_payload(out : Array[Byte], value : IonDecimal) -> Unit {
  write_varint(out, value.exponent)
  let mag = magnitude_bytes(value.coefficient)
  if mag.length() == 0 {
    push_u8(out, if value.coefficient.negative { 0x80 } else { 0 })
  } else {
    for b in mag {
      out.push(b)
    }
    if value.coefficient.negative {
      let idx = out.length() - mag.length()
      out[idx] = (out[idx].to_int() | 0x80).to_byte()
    }
  }
}
