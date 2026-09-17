///|
const TID_NULL : Int = 0

///|
const TID_BOOL : Int = 1

///|
const TID_POSINT : Int = 2

///|
const TID_NEGINT : Int = 3

///|
const TID_FLOAT : Int = 4

///|
const TID_DECIMAL : Int = 5

///|
const TID_TIMESTAMP : Int = 6

///|
const TID_SYMBOL : Int = 7

///|
const TID_STRING : Int = 8

///|
const TID_CLOB : Int = 9

///|
const TID_BLOB : Int = 10

///|
const TID_LIST : Int = 11

///|
const TID_SEXP : Int = 12

///|
const TID_STRUCT : Int = 13

///|
const TID_ANNOT : Int = 14

///|
priv struct BinCursor {
  data : Array[Byte]
  mut i : Int
  table : SymbolTable
}

///|
fn bin_eof(c : BinCursor) -> Bool {
  c.i >= c.data.length()
}

///|
fn bin_need(c : BinCursor, n : Int) -> Result[Unit, IonError] {
  if c.i + n > c.data.length() {
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
    n = (n << 7) | (b & 0x7F).to_int64()
    if (b & 0x80) == 0 {
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
  let mut more = (b0 & 0x80) != 0
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
    n = (n << 7) | (b & 0x7F).to_int64()
    more = (b & 0x80) != 0
  }
  if negative {
    Ok(0L - n)
  } else {
    Ok(n)
  }
}

///|
fn read_exact(c : BinCursor, n : Int) -> Result[Bytes, IonError] {
  match bin_need(c, n) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let out = slice_bytes(c.data, c.i, c.i + n)
  c.i += n
  Ok(out)
}

///|
fn parse_type_desc(c : BinCursor) -> Result[(Int, Int, Bool), IonError] {
  match bin_need(c, 1) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let td = c.data[c.i].to_int()
  c.i += 1
  let tid = (td >> 4) & 0x0F
  let low = td & 0x0F
  if low == 15 {
    Ok((tid, 0, true))
  } else if low == 14 {
    match read_varuint_at(c) {
      Ok(n) => Ok((tid, n.to_int(), false))
      Err(e) => Err(e)
    }
  } else {
    Ok((tid, low, false))
  }
}

///|
fn parse_binary_value(c : BinCursor) -> Result[IonValue, IonError] {
  match parse_type_desc(c) {
    Err(e) => Err(e)
    Ok((tid, len, is_null)) =>
      if tid == TID_NULL && is_null {
        Ok(ion_null(NullT))
      } else if tid == TID_NULL {
        c.i += len
        Ok(ion_null(NullT))
      } else if tid == TID_ANNOT {
        parse_annotation_wrapper(c, len)
      } else {
        parse_typed_payload(c, tid, len, is_null)
      }
  }
}

///|
fn parse_annotation_wrapper(
  c : BinCursor,
  len : Int,
) -> Result[IonValue, IonError] {
  let end = c.i + len
  let annot_len = match read_varuint_at(c) {
    Ok(n) => n.to_int()
    Err(e) => return Err(e)
  }
  let annot_end = c.i + annot_len
  if annot_end > end {
    return Err(InvalidBinary("annotation length"))
  }
  let anns : Array[String] = []
  while c.i < annot_end {
    let sid = match read_varuint_at(c) {
      Ok(n) => n.to_int()
      Err(e) => return Err(e)
    }
    match c.table.name_of(sid) {
      Ok(name) => anns.push(name)
      Err(e) => return Err(e)
    }
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
  tid : Int,
  len : Int,
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
    if len == 0 {
      Ok(ion_int(0))
    } else {
      match read_exact(c, len) {
        Ok(mag) => Ok(ion_bigint(bigint_from_magnitude(tid == TID_NEGINT, mag)))
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
      Ok(ion_symbol(""))
    } else {
      match read_exact(c, len) {
        Ok(raw) => {
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
fn bytes_to_int(raw : Bytes) -> Int {
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
  len : Int,
) -> Result[IonValue, IonError] {
  if len == 0 {
    Ok(ion_decimal(decimal_from_int(0)))
  } else {
    let end = c.i + len
    let exp = match read_varint_at(c) {
      Ok(v) => v.to_int()
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
          bigint_from_magnitude(negative, array_to_bytes(arr)),
          exp,
        ),
      ),
    )
  }
}

///|
fn parse_timestamp_payload(
  c : BinCursor,
  len : Int,
) -> Result[IonValue, IonError] {
  let end = c.i + len
  let off = match read_varint_at(c) {
    Ok(v) => v.to_int()
    Err(e) => return Err(e)
  }
  let offset_unknown = false
  let year = match read_varuint_at(c) {
    Ok(v) => v.to_int()
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
      Ok(v) => v.to_int()
      Err(e) => return Err(e)
    }
    precision = Month
  }
  if c.i < end {
    day = match read_varuint_at(c) {
      Ok(v) => v.to_int()
      Err(e) => return Err(e)
    }
    precision = Day
  }
  if c.i < end {
    hour = match read_varuint_at(c) {
      Ok(v) => v.to_int()
      Err(e) => return Err(e)
    }
    minute = match read_varuint_at(c) {
      Ok(v) => v.to_int()
      Err(e) => return Err(e)
    }
    precision = Minute
  }
  if c.i < end {
    second = match read_varuint_at(c) {
      Ok(v) => v.to_int()
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
    Ok(ts) => Ok(ion_timestamp(ts))
    Err(e) => Err(e)
  }
}

///|
fn parse_struct_payload(c : BinCursor, len : Int) -> Result[IonValue, IonError] {
  let end = c.i + len
  let fields : Array[IonField] = []
  while c.i < end {
    let sid = match read_varuint_at(c) {
      Ok(v) => v.to_int()
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
pub fn loads_binary(data : Bytes) -> Result[Array[IonValue], IonError] {
  let c : BinCursor = {
    data: bytes_to_array(data),
    i: 0,
    table: symbol_table_new(),
  }
  match expect_bvm(c) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let values : Array[IonValue] = []
  while !bin_eof(c) {
    match parse_binary_value(c) {
      Ok(v) =>
        if v.is_symbol_table() {
          apply_local_table(c.table, v)
        } else {
          values.push(v)
        }
      Err(e) => return Err(e)
    }
  }
  Ok(values)
}

///|
fn apply_local_table(table : SymbolTable, value : IonValue) -> Unit {
  table.reset_locals()
  match value.field("symbols") {
    Some(list) =>
      match list.datum {
        ListD(items) =>
          for item in items {
            match item.datum {
              StringD(s) => table.define_local(s)
              SymbolD(s) => table.define_local(s)
              _ => ()
            }
          }
        _ => ()
      }
    None => ()
  }
}

///|
pub fn load_binary(data : Bytes) -> Result[IonValue, IonError] {
  match loads_binary(data) {
    Ok(vs) => if vs.length() == 0 { Err(EmptyDocument) } else { Ok(vs[0]) }
    Err(e) => Err(e)
  }
}
