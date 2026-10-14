///|
const TID_NULL : Int32 = 0

///|
const TID_BOOL : Int32 = 1

///|
const TID_POSINT : Int32 = 2

///|
const TID_NEGINT : Int32 = 3

///|
const TID_FLOAT : Int32 = 4

///|
const TID_DECIMAL : Int32 = 5

///|
const TID_TIMESTAMP : Int32 = 6

///|
const TID_SYMBOL : Int32 = 7

///|
const TID_STRING : Int32 = 8

///|
const TID_CLOB : Int32 = 9

///|
const TID_BLOB : Int32 = 10

///|
const TID_LIST : Int32 = 11

///|
const TID_SEXP : Int32 = 12

///|
const TID_STRUCT : Int32 = 13

///|
const TID_ANNOT : Int32 = 14

///|
priv struct BinCursor {
  data : Array[Byte]
  mut i : Int32
  mut limit : Int32
  mut depth : Int32
  catalog : Array[SharedSymbolTable]
  table : SymbolTable
}

///|
fn bin_eof(c : BinCursor) -> Bool {
  c.i >= c.limit
}

///|
fn bin_need(c : BinCursor, n : Int32) -> Result[Unit, IonError] {
  if n < 0 || n > c.limit - c.i {
    Err(UnexpectedEof)
  } else {
    Ok(())
  }
}

///|
fn read_varuint_at(c : BinCursor) -> Result[Int64, IonError] {
  let mut n = 0L
  let mut count = 0
  let mut done = false
  while !done {
    match bin_need(c, 1) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    let b = c.data[c.i].to_int()
    c.i += 1
    count += 1
    if count > 10 {
      return Err(InvalidBinary("VarUInt too long"))
    }
    if n > 0x7FFFFFFFFFFFFFFFL >> 7 {
      return Err(InvalidBinary("variable integer overflow"))
    }
    n = (n << 7) | (b & 0x7F).to_int64()
    if (b & 0x80) != 0 {
      done = true
    }
  }
  Ok(n)
}

///|
fn read_varint_at(c : BinCursor) -> Result[Int64, IonError] {
  match bin_need(c, 1) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let b0 = c.data[c.i].to_int()
  c.i += 1
  let negative = (b0 & 0x40) != 0
  let mut n = (b0 & 0x3F).to_int64()
  let mut more = (b0 & 0x80) == 0
  let mut count = 1
  while more {
    match bin_need(c, 1) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    let b = c.data[c.i].to_int()
    c.i += 1
    count += 1
    if count > 10 {
      return Err(InvalidBinary("VarInt too long"))
    }
    if n > 0x7FFFFFFFFFFFFFFFL >> 7 {
      return Err(InvalidBinary("variable integer overflow"))
    }
    n = (n << 7) | (b & 0x7F).to_int64()
    more = (b & 0x80) == 0
  }
  if negative {
    Ok(0L - n)
  } else {
    Ok(n)
  }
}

///|
fn read_exact(c : BinCursor, n : Int32) -> Result[Bytes, IonError] {
  match bin_need(c, n) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let out = slice_bytes(c.data, c.i, c.i + n)
  c.i += n
  Ok(out)
}

///|
fn parse_type_desc(c : BinCursor) -> Result[(Int32, Int32, Bool), IonError] {
  match bin_need(c, 1) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let td = c.data[c.i].to_int()
  c.i += 1
  let tid = (td >> 4) & 0x0F
  let low = td & 0x0F
  if tid == TID_BOOL && low != 0 && low != 1 && low != 15 {
    return Err(InvalidBinary("boolean descriptor"))
  }
  if low == 15 {
    Ok((tid, 0, true))
  } else if low == 14 {
    match read_varuint_at(c) {
      Ok(n) =>
        if n > 2147483647L {
          Err(InvalidBinary("length overflow"))
        } else {
          Ok((tid, n.to_int(), false))
        }
      Err(e) => Err(e)
    }
  } else {
    Ok((tid, low, false))
  }
}

///|
fn skip_binary_nop(c : BinCursor) -> Result[Bool, IonError] {
  if bin_eof(c) || c.data[c.i].to_int() >> 4 != 0 || c.data[c.i].to_int() == 15 {
    return Ok(false)
  }
  match parse_type_desc(c) {
    Err(e) => Err(e)
    Ok((_, len, _)) =>
      match read_exact(c, len) {
        Ok(_) => Ok(true)
        Err(e) => Err(e)
      }
  }
}

///|
fn parse_binary_value(c : BinCursor) -> Result[IonValue, IonError] {
  if c.depth >= 256 {
    return Err(InvalidBinary("nesting limit exceeded"))
  }
  let (tid, raw_len, is_null) = match parse_type_desc(c) {
    Ok(v) => v
    Err(e) => return Err(e)
  }
  if tid == 15 || (tid == TID_ANNOT && is_null) {
    return Err(InvalidBinary("reserved type descriptor"))
  }
  let len = if tid == TID_STRUCT && raw_len == 1 && !is_null {
    match read_varuint_at(c) {
      Ok(n) =>
        if n > 2147483647L {
          return Err(InvalidBinary("length overflow"))
        } else {
          n.to_int()
        }
      Err(e) => return Err(e)
    }
  } else {
    raw_len
  }
  let payload_len = if tid == TID_BOOL || is_null { 0 } else { len }
  match bin_need(c, payload_len) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let outer_limit = c.limit
  let end = c.i + payload_len
  c.limit = end
  c.depth += 1
  let result = if tid == TID_NULL && is_null {
    Ok(ion_null(NullT))
  } else if tid == TID_NULL {
    Err(InvalidBinary("NOP cannot be a value"))
  } else if tid == TID_ANNOT {
    parse_annotation_wrapper(c, len)
  } else {
    parse_typed_payload(c, tid, len, is_null)
  }
  c.limit = outer_limit
  c.depth -= 1
  match result {
    Ok(v) =>
      if c.i == end {
        Ok(v)
      } else {
        Err(InvalidBinary("payload length mismatch"))
      }
    Err(e) => Err(e)
  }
}

///|
fn parse_annotation_wrapper(
  c : BinCursor,
  len : Int32,
) -> Result[IonValue, IonError] {
  let end = c.i + len
  let annot_len = match read_varuint_at(c) {
    Ok(n) =>
      if n > 2147483647L {
        return Err(InvalidBinary("integer overflow"))
      } else {
        n.to_int()
      }
    Err(e) => return Err(e)
  }
  let annot_end = c.i + annot_len
  if annot_len <= 0 || annot_len > end - c.i {
    return Err(InvalidBinary("annotation length"))
  }
  let outer_limit = c.limit
  c.limit = annot_end
  let anns : Array[String] = []
  while c.i < annot_end {
    let sid = match read_varuint_at(c) {
      Ok(n) =>
        if n > 2147483647L {
          return Err(InvalidBinary("integer overflow"))
        } else {
          n.to_int()
        }
      Err(e) => return Err(e)
    }
    match c.table.name_of(sid) {
      Ok(name) => anns.push(name)
      Err(e) => return Err(e)
    }
  }
  c.limit = outer_limit
  if c.i >= end ||
    c.data[c.i].to_int() >> 4 == TID_ANNOT ||
    (c.data[c.i].to_int() >> 4 == TID_NULL && c.data[c.i].to_int() != 15) {
    return Err(InvalidBinary("invalid annotation value"))
  }
  match parse_binary_value(c) {
    Ok(v) => {
      if c.i != end {
        return Err(InvalidBinary("annotation payload length"))
      }
      Ok({ annotations: anns, datum: v.datum, })
    }
    Err(e) => Err(e)
  }
}

///|
fn parse_typed_payload(
  c : BinCursor,
  tid : Int32,
  len : Int32,
  is_null : Bool,
) -> Result[IonValue, IonError] {
  if is_null {
    let t = match tid {
      1 => BoolT
      2 => IntT
      3 => IntT
      4 => FloatT
      5 => DecimalT
      6 => TimestampT
      7 => SymbolT
      8 => StringT
      9 => ClobT
      10 => BlobT
      11 => ListT
      12 => SexpT
      13 => StructT
      _ => NullT
    }
    Ok(ion_null(t))
  } else if tid == TID_BOOL {
    if len == 0 {
      Ok(ion_bool(false))
    } else if len == 1 {
      Ok(ion_bool(true))
    } else {
      Err(InvalidBinary("bool"))
    }
  } else if tid == TID_POSINT || tid == TID_NEGINT {
    if tid == TID_NEGINT && len == 0 {
      return Err(InvalidBinary("negative integer zero"))
    }
    if len == 0 {
      Ok(ion_int(0))
    } else {
      match read_exact(c, len) {
        Ok(mag) => {
          let n = bigint_from_magnitude(tid == TID_NEGINT, mag)
          if tid == TID_NEGINT && n.is_zero() {
            Err(InvalidBinary("negative integer zero"))
          } else {
            Ok(ion_bigint(n))
          }
        }
        Err(e) => Err(e)
      }
    }
  } else if tid == TID_FLOAT {
    if len == 0 {
      Ok(ion_float(0.0))
    } else if len == 4 {
      match read_exact(c, 4) {
        Ok(b) => {
          let a = bytes_to_array(b)
          Ok(
            ion_float(
              f64_from_be4(
                a[0].to_int(),
                a[1].to_int(),
                a[2].to_int(),
                a[3].to_int(),
              ),
            ),
          )
        }
        Err(e) => Err(e)
      }
    } else if len == 8 {
      match read_exact(c, 8) {
        Ok(b) => {
          let a = bytes_to_array(b)
          Ok(
            ion_float(
              f64_from_be_bytes(
                a[0].to_int(),
                a[1].to_int(),
                a[2].to_int(),
                a[3].to_int(),
                a[4].to_int(),
                a[5].to_int(),
                a[6].to_int(),
                a[7].to_int(),
              ),
            ),
          )
        }
        Err(e) => Err(e)
      }
    } else {
      Err(InvalidBinary("float length"))
    }
  } else if tid == TID_DECIMAL {
    parse_decimal_payload(c, len)
  } else if tid == TID_TIMESTAMP {
    parse_timestamp_payload(c, len)
  } else if tid == TID_SYMBOL {
    if len == 0 {
      Err(InvalidSymbol("unresolved SID 0"))
    } else {
      match read_exact(c, len) {
        Ok(raw) => {
          if raw.length() > 4 ||
            (raw.length() == 4 && bytes_to_array(raw)[0].to_int() > 127) {
            return Err(InvalidSymbol("SID overflow"))
          }
          let sid = bytes_to_int(raw)
          match c.table.name_of(sid) {
            Ok(name) => Ok(ion_symbol(name))
            Err(e) => Err(e)
          }
        }
        Err(e) => Err(e)
      }
    }
  } else if tid == TID_STRING {
    match read_exact(c, len) {
      Ok(raw) =>
        match utf8_decode(raw) {
          Ok(s) => Ok(ion_string(s))
          Err(e) => Err(e)
        }
      Err(e) => Err(e)
    }
  } else if tid == TID_CLOB {
    match read_exact(c, len) {
      Ok(raw) => Ok(ion_clob(raw))
      Err(e) => Err(e)
    }
  } else if tid == TID_BLOB {
    match read_exact(c, len) {
      Ok(raw) => Ok(ion_blob(raw))
      Err(e) => Err(e)
    }
  } else if tid == TID_LIST || tid == TID_SEXP {
    let end = c.i + len
    let items : Array[IonValue] = []
    while c.i < end {
      match skip_binary_nop(c) {
        Ok(true) => continue
        Ok(false) => ()
        Err(e) => return Err(e)
      }
      match parse_binary_value(c) {
        Ok(v) => items.push(v)
        Err(e) => return Err(e)
      }
    }
    if c.i != end {
      Err(InvalidBinary("container length"))
    } else if tid == TID_LIST {
      Ok(ion_list(items))
    } else {
      Ok(ion_sexp(items))
    }
  } else if tid == TID_STRUCT {
    parse_struct_payload(c, len)
  } else {
    Err(InvalidBinary("unknown type " + tid.to_string()))
  }
}

///|
fn bytes_to_int(raw : Bytes) -> Int32 {
  let arr = bytes_to_array(raw)
  let mut n = 0
  for b in arr {
    n = (n << 8) | b.to_int()
  }
  n
}

///|
fn parse_decimal_payload(
  c : BinCursor,
  len : Int32,
) -> Result[IonValue, IonError] {
  if len == 0 {
    Ok(ion_decimal(decimal_from_int(0)))
  } else {
    let end = c.i + len
    let exp = match read_varint_at(c) {
      Ok(v) =>
        if v < -2147483648L || v > 2147483647L {
          return Err(InvalidBinary("decimal exponent overflow"))
        } else {
          v.to_int()
        }
      Err(e) => return Err(e)
    }
    let mag = slice_bytes(c.data, c.i, end)
    c.i = end
    let arr = bytes_to_array(mag)
    let mut negative = false
    if arr.length() > 0 && (arr[0].to_int() & 0x80) != 0 {
      negative = true
      arr[0] = (arr[0].to_int() & 0x7F).to_byte()
    }
    Ok(
      ion_decimal(
        decimal_from_parts(
          {
            negative,
            digits: bigint_from_magnitude(false, array_to_bytes(arr)).digits,
          },
          exp,
        ),
      ),
    )
  }
}

///|
fn parse_timestamp_payload(
  c : BinCursor,
  len : Int32,
) -> Result[IonValue, IonError] {
  let end = c.i + len
  let offset_start = c.i
  let off = match read_varint_at(c) {
    Ok(v) =>
      if v < -2147483648L || v > 2147483647L {
        return Err(InvalidBinary("integer overflow"))
      } else {
        v.to_int()
      }
    Err(e) => return Err(e)
  }
  let offset_unknown = off == 0 && (c.data[offset_start].to_int() & 0x40) != 0
  let year = match read_varuint_at(c) {
    Ok(v) =>
      if v < -2147483648L || v > 2147483647L {
        return Err(InvalidBinary("integer overflow"))
      } else {
        v.to_int()
      }
    Err(e) => return Err(e)
  }
  let mut month = 1
  let mut day = 1
  let mut hour = 0
  let mut minute = 0
  let mut second = 0
  let mut precision = Year
  if c.i < end {
    month = match read_varuint_at(c) {
      Ok(v) =>
        if v < -2147483648L || v > 2147483647L {
          return Err(InvalidBinary("integer overflow"))
        } else {
          v.to_int()
        }
      Err(e) => return Err(e)
    }
    precision = Month
  }
  if c.i < end {
    day = match read_varuint_at(c) {
      Ok(v) =>
        if v < -2147483648L || v > 2147483647L {
          return Err(InvalidBinary("integer overflow"))
        } else {
          v.to_int()
        }
      Err(e) => return Err(e)
    }
    precision = Day
  }
  if c.i < end {
    hour = match read_varuint_at(c) {
      Ok(v) =>
        if v < -2147483648L || v > 2147483647L {
          return Err(InvalidBinary("integer overflow"))
        } else {
          v.to_int()
        }
      Err(e) => return Err(e)
    }
    minute = match read_varuint_at(c) {
      Ok(v) =>
        if v < -2147483648L || v > 2147483647L {
          return Err(InvalidBinary("integer overflow"))
        } else {
          v.to_int()
        }
      Err(e) => return Err(e)
    }
    precision = Minute
  }
  if c.i < end {
    second = match read_varuint_at(c) {
      Ok(v) =>
        if v < -2147483648L || v > 2147483647L {
          return Err(InvalidBinary("integer overflow"))
        } else {
          v.to_int()
        }
      Err(e) => return Err(e)
    }
    precision = Second
  }
  let mut frac = decimal_from_int(0)
  if c.i < end {
    let rest = end - c.i
    match parse_decimal_payload(c, rest) {
      Ok(v) =>
        match v.datum {
          DecimalD(d) => {
            frac = d
            precision = Fractional
          }
          _ => ()
        }
      Err(e) => return Err(e)
    }
  }
  match
    timestamp_of(
      year, month, day, hour, minute, second, frac, off, offset_unknown, precision,
    ) {
    Ok(ts) => {
      if !offset_unknown &&
        (precision == Year || precision == Month || precision == Day) {
        return Err(InvalidBinary("coarse timestamp requires unknown offset"))
      }
      let local_ts = if offset_unknown { ts } else { shift_timestamp(ts, off) }
      if local_ts.year < 1 || local_ts.year > 9999 {
        return Err(InvalidTimestamp("local year"))
      }
      Ok(ion_timestamp(local_ts))
    }
    Err(e) => Err(e)
  }
}

///|
fn parse_struct_payload(
  c : BinCursor,
  len : Int32,
) -> Result[IonValue, IonError] {
  let end = c.i + len
  let fields : Array[IonField] = []
  while c.i < end {
    let sid = match read_varuint_at(c) {
      Ok(v) =>
        if v < -2147483648L || v > 2147483647L {
          return Err(InvalidBinary("integer overflow"))
        } else {
          v.to_int()
        }
      Err(e) => return Err(e)
    }
    match skip_binary_nop(c) {
      Ok(true) => continue
      Ok(false) => ()
      Err(e) => return Err(e)
    }
    let name = match c.table.name_of(sid) {
      Ok(v) => v
      Err(e) => return Err(e)
    }
    match parse_binary_value(c) {
      Ok(v) => fields.push(ion_field(name, v))
      Err(e) => return Err(e)
    }
  }
  if c.i != end {
    Err(InvalidBinary("struct length"))
  } else {
    Ok(ion_struct(fields))
  }
}

///|
fn expect_bvm(c : BinCursor) -> Result[Unit, IonError] {
  match bin_need(c, 4) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  if c.data[c.i].to_int() == 0xE0 &&
    c.data[c.i + 1].to_int() == 0x01 &&
    c.data[c.i + 2].to_int() == 0x00 &&
    c.data[c.i + 3].to_int() == 0xEA {
    c.i += 4
    Ok(())
  } else {
    Err(InvalidBinary("missing binary version marker"))
  }
}

///|
pub fn loads_binary(
  data : Bytes,
  catalog~ : Array[SharedSymbolTable] = [],
) -> Result[Array[IonValue], IonError] {
  let c : BinCursor = {
    data: bytes_to_array(data),
    i: 0,
    limit: data.length(),
    depth: 0,
    catalog,
    table: symbol_table_new(),
  }
  match expect_bvm(c) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let values : Array[IonValue] = []
  while !bin_eof(c) {
    if c.data[c.i].to_int() == 0xE0 {
      match expect_bvm(c) {
        Err(e) => return Err(e)
        Ok(_) => c.table.reset_locals()
      }
      continue
    }
    match skip_binary_nop(c) {
      Ok(true) => continue
      Ok(false) => ()
      Err(e) => return Err(e)
    }
    match parse_binary_value(c) {
      Ok(v) =>
        if v.is_symbol_table() {
          match apply_local_table(c.table, v, c.catalog) {
            Err(e) => return Err(e)
            Ok(_) => ()
          }
        } else {
          values.push(v)
        }
      Err(e) => return Err(e)
    }
  }
  Ok(values)
}

///|
pub fn load_binary(
  data : Bytes,
  catalog~ : Array[SharedSymbolTable] = [],
) -> Result[IonValue, IonError] {
  match loads_binary(data, catalog~) {
    Ok(vs) => if vs.length() == 0 { Err(EmptyDocument) } else { Ok(vs[0]) }
    Err(e) => Err(e)
  }
}
