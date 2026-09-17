///|
fn escape_ion_string(text : String) -> String {
  let out = StringBuilder()
  out.write_char('"')
  let mut i = 0
  while i < text.length() {
    let c = text[i].to_int()
    if c == 92 {
      out.write_string("\\\\")
    } else if c == 34 {
      out.write_string("\\\"")
    } else if c == 10 {
      out.write_string("\\n")
    } else if c == 13 {
      out.write_string("\\r")
    } else if c == 9 {
      out.write_string("\\t")
    } else if c < 32 {
      out.write_string("\\x")
      out.write_char(nibble_char((c >> 4) & 15, false))
      out.write_char(nibble_char(c & 15, false))
    } else {
      out.write_char(c.unsafe_to_char())
    }
    i += 1
  }
  out.write_char('"')
  out.to_string()
}

///|
fn write_annotations(anns : Array[String]) -> String {
  let out = StringBuilder()
  for a in anns {
    out.write_string(quote_symbol(a))
    out.write_string("::")
  }
  out.to_string()
}

///|
pub fn dumps_text(value : IonValue) -> String {
  write_annotations(value.annotations) + dumps_datum(value.datum)
}

///|
pub fn dumps_text_all(values : Array[IonValue]) -> String {
  let out = StringBuilder()
  out.write_string("$ion_1_0\n")
  for v in values {
    out.write_string(dumps_text(v))
    out.write_char('\n')
  }
  out.to_string()
}

///|
fn dumps_datum(datum : IonDatum) -> String {
  match datum {
    NullD(t) =>
      match t {
        NullT => "null"
        _ => "null." + t.name()
      }
    BoolD(v) => if v { "true" } else { "false" }
    IntD(v) => v.to_decimal_string()
    FloatD(v) => float_to_ion_text(v)
    DecimalD(v) => v.to_ion_text()
    TimestampD(v) => v.to_ion_text()
    SymbolD(v) => quote_symbol(v)
    StringD(v) => escape_ion_string(v)
    ClobD(v) => clob_to_text(v)
    BlobD(v) => "{{" + base64_encode(v) + "}}"
    ListD(v) => list_to_text("[", "]", v)
    SexpD(v) => list_to_text("(", ")", v)
    StructD(v) => struct_to_text(v)
  }
}

///|
fn float_to_ion_text(value : Double) -> String {
  if is_nan(value) {
    "nan"
  } else if is_inf(value) {
    if value < 0.0 {
      "-inf"
    } else {
      "+inf"
    }
  } else {
    let s = value.to_string()
    if str_has(s, 101) || str_has(s, 69) || str_has(s, 46) {
      s
    } else {
      s + "e0"
    }
  }
}

///|
fn clob_to_text(data : Bytes) -> String {
  let arr = bytes_to_array(data)
  let inner = StringBuilder()
  for b in arr {
    let c = b.to_int()
    if c == 92 {
      inner.write_string("\\\\")
    } else if c == 34 {
      inner.write_string("\\\"")
    } else if c >= 32 && c <= 126 {
      inner.write_char(c.unsafe_to_char())
    } else {
      inner.write_string("\\x")
      inner.write_char(nibble_char((c >> 4) & 15, false))
      inner.write_char(nibble_char(c & 15, false))
    }
  }
  "{{" + "\"" + inner.to_string() + "\"" + "}}"
}

///|
fn list_to_text(
  open : String,
  close : String,
  values : Array[IonValue],
) -> String {
  let out = StringBuilder()
  out.write_string(open)
  let mut i = 0
  while i < values.length() {
    if i > 0 {
      out.write_string(", ")
    }
    out.write_string(dumps_text(values[i]))
    i += 1
  }
  out.write_string(close)
  out.to_string()
}

///|
fn struct_to_text(fields : Array[IonField]) -> String {
  let out = StringBuilder()
  out.write_char('{')
  let mut i = 0
  while i < fields.length() {
    if i > 0 {
      out.write_string(", ")
    }
    out.write_string(quote_symbol(fields[i].name))
    out.write_string(": ")
    out.write_string(dumps_text(fields[i].value))
    i += 1
  }
  out.write_char('}')
  out.to_string()
}

///|
fn str_has(text : String, code : Int) -> Bool {
  let mut i = 0
  let mut found = false
  while i < text.length() {
    if text[i].to_int() == code {
      found = true
    }
    i += 1
  }
  found
}
