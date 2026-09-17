///|
priv struct TextCursor {
  src : String
  mut i : Int
}

///|
fn cursor_eof(c : TextCursor) -> Bool {
  c.i >= c.src.length()
}

///|
fn cursor_peek(c : TextCursor) -> Int {
  if cursor_eof(c) {
    -1
  } else {
    c.src[c.i].to_int()
  }
}

///|
fn cursor_peek_at(c : TextCursor, n : Int) -> Int {
  let j = c.i + n
  if j >= c.src.length() {
    -1
  } else {
    c.src[j].to_int()
  }
}

///|
fn cursor_bump(c : TextCursor) -> Unit {
  if !cursor_eof(c) {
    c.i += 1
  }
}

///|
fn skip_ws_comments(c : TextCursor) -> Result[Unit, IonError] {
  let mut running = true
  while running {
    let ch = cursor_peek(c)
    if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
      cursor_bump(c)
    } else if ch == 47 && cursor_peek_at(c, 1) == 47 {
      cursor_bump(c)
      cursor_bump(c)
      while !cursor_eof(c) && cursor_peek(c) != 10 {
        cursor_bump(c)
      }
    } else if ch == 47 && cursor_peek_at(c, 1) == 42 {
      cursor_bump(c)
      cursor_bump(c)
      let mut closed = false
      while !cursor_eof(c) {
        if cursor_peek(c) == 42 && cursor_peek_at(c, 1) == 47 {
          cursor_bump(c)
          cursor_bump(c)
          closed = true
          break
        }
        cursor_bump(c)
      }
      if !closed {
        return Err(InvalidText("unterminated block comment"))
      }
    } else {
      running = false
    }
  }
  Ok(())
}

///|
fn read_ident(c : TextCursor) -> String {
  let start = c.i
  while is_ident_part(cursor_peek(c)) {
    cursor_bump(c)
  }
  slice_text(c.src, start, c.i)
}

///|
fn read_operator(c : TextCursor) -> String {
  let start = c.i
  while is_operator_char(cursor_peek(c)) {
    cursor_bump(c)
  }
  slice_text(c.src, start, c.i)
}

///|
fn read_quoted_symbol(c : TextCursor) -> Result[String, IonError] {
  if cursor_peek(c) != 39 {
    return Err(InvalidText("expected quoted symbol"))
  }
  cursor_bump(c)
  let out = StringBuilder()
  while !cursor_eof(c) {
    let ch = cursor_peek(c)
    if ch == 39 {
      cursor_bump(c)
      return Ok(out.to_string())
    }
    if ch == 92 {
      cursor_bump(c)
      match read_escape(c) {
        Ok(v) => out.write_char(v)
        Err(e) => return Err(e)
      }
    } else {
      out.write_char(ch.unsafe_to_char())
      cursor_bump(c)
    }
  }
  Err(InvalidText("unterminated quoted symbol"))
}

///|
fn read_escape(c : TextCursor) -> Result[Char, IonError] {
  let ch = cursor_peek(c)
  if ch < 0 {
    return Err(InvalidText("unterminated escape"))
  }
  cursor_bump(c)
  if ch == 110 {
    Ok('\n')
  } else if ch == 114 {
    Ok('\r')
  } else if ch == 116 {
    Ok('\t')
  } else if ch == 34 || ch == 39 || ch == 92 || ch == 47 {
    Ok(ch.unsafe_to_char())
  } else if ch == 120 {
    let h1 = nibble_value_int(cursor_peek(c))
    cursor_bump(c)
    let h2 = nibble_value_int(cursor_peek(c))
    cursor_bump(c)
    match (h1, h2) {
      (Some(a), Some(b)) => Ok(((a << 4) | b).unsafe_to_char())
      _ => Err(InvalidText("bad hex escape"))
    }
  } else {
    Ok(ch.unsafe_to_char())
  }
}

///|
fn read_quoted_string(c : TextCursor) -> Result[String, IonError] {
  if cursor_peek(c) != 34 {
    return Err(InvalidText("expected string"))
  }
  cursor_bump(c)
  let out = StringBuilder()
  while !cursor_eof(c) {
    let ch = cursor_peek(c)
    if ch == 34 {
      cursor_bump(c)
      return Ok(out.to_string())
    }
    if ch == 92 {
      cursor_bump(c)
      match read_escape(c) {
        Ok(v) => out.write_char(v)
        Err(e) => return Err(e)
      }
    } else {
      out.write_char(ch.unsafe_to_char())
      cursor_bump(c)
    }
  }
  Err(InvalidText("unterminated string"))
}

///|
fn parse_blob_or_clob(c : TextCursor) -> Result[IonValue, IonError] {
  if cursor_peek(c) != 123 || cursor_peek_at(c, 1) != 123 {
    return Err(InvalidText("expected blob"))
  }
  cursor_bump(c)
  cursor_bump(c)
  match skip_ws_comments(c) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  if cursor_peek(c) == 34 {
    let s = match read_quoted_string(c) {
      Ok(v) => v
      Err(e) => return Err(e)
    }
    match skip_ws_comments(c) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    if cursor_peek(c) != 125 || cursor_peek_at(c, 1) != 125 {
      return Err(InvalidText("unterminated clob"))
    }
    cursor_bump(c)
    cursor_bump(c)
    Ok(ion_clob(utf8_encode(s)))
  } else {
    let body = StringBuilder()
    while !cursor_eof(c) &&
          !(cursor_peek(c) == 125 && cursor_peek_at(c, 1) == 125) {
      let ch = cursor_peek(c)
      if ch != 32 && ch != 10 && ch != 13 && ch != 9 {
        body.write_char(ch.unsafe_to_char())
      }
      cursor_bump(c)
    }
    if cursor_eof(c) {
      return Err(InvalidText("unterminated blob"))
    }
    cursor_bump(c)
    cursor_bump(c)
    match base64_decode(body.to_string()) {
      Ok(b) => Ok(ion_blob(b))
      Err(e) => Err(e)
    }
  }
}

///|
fn parse_container(
  c : TextCursor,
  close : Int,
  sexp : Bool,
) -> Result[Array[IonValue], IonError] {
  let items : Array[IonValue] = []
  let mut running = true
  while running {
    match skip_ws_comments(c) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    if cursor_peek(c) == close {
      cursor_bump(c)
      running = false
    } else if cursor_eof(c) {
      return Err(InvalidText("unterminated container"))
    } else {
      match parse_annotated_value(c, sexp) {
        Ok(v) => items.push(v)
        Err(e) => return Err(e)
      }
      match skip_ws_comments(c) {
        Err(e) => return Err(e)
        Ok(_) => ()
      }
      if cursor_peek(c) == 44 {
        cursor_bump(c)
      }
    }
  }
  Ok(items)
}

///|
fn parse_struct_fields(c : TextCursor) -> Result[Array[IonField], IonError] {
  let fields : Array[IonField] = []
  let mut running = true
  while running {
    match skip_ws_comments(c) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    if cursor_peek(c) == 125 {
      cursor_bump(c)
      running = false
    } else if cursor_eof(c) {
      return Err(InvalidText("unterminated struct"))
    } else {
      let name = match parse_field_name(c) {
        Ok(v) => v
        Err(e) => return Err(e)
      }
      match skip_ws_comments(c) {
        Err(e) => return Err(e)
        Ok(_) => ()
      }
      if cursor_peek(c) != 58 {
        return Err(InvalidText("expected ':' in struct"))
      }
      cursor_bump(c)
      match parse_annotated_value(c, false) {
        Ok(v) => fields.push(ion_field(name, v))
        Err(e) => return Err(e)
      }
      match skip_ws_comments(c) {
        Err(e) => return Err(e)
        Ok(_) => ()
      }
      if cursor_peek(c) == 44 {
        cursor_bump(c)
      }
    }
  }
  Ok(fields)
}

///|
fn parse_field_name(c : TextCursor) -> Result[String, IonError] {
  match skip_ws_comments(c) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let ch = cursor_peek(c)
  if is_ident_start(ch) {
    Ok(read_ident(c))
  } else if ch == 39 {
    read_quoted_symbol(c)
  } else if ch == 34 {
    read_quoted_string(c)
  } else {
    Err(InvalidText("invalid field name"))
  }
}

///|
fn parse_null_or_typed(
  c : TextCursor,
  ident : String,
) -> Result[IonValue, IonError] {
  if ident != "null" {
    return Err(InvalidText(ident))
  }
  match skip_ws_comments(c) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  if cursor_peek(c) == 46 {
    cursor_bump(c)
    let typ = read_ident(c)
    let ion_t = match typ {
      "null" => NullT
      "bool" => BoolT
      "int" => IntT
      "float" => FloatT
      "decimal" => DecimalT
      "timestamp" => TimestampT
      "symbol" => SymbolT
      "string" => StringT
      "clob" => ClobT
      "blob" => BlobT
      "list" => ListT
      "sexp" => SexpT
      "struct" => StructT
      _ => return Err(InvalidText("null." + typ))
    }
    Ok(ion_null(ion_t))
  } else {
    Ok(ion_null(NullT))
  }
}

///|
fn parse_number_or_timestamp(c : TextCursor) -> Result[IonValue, IonError] {
  let start = c.i
  if cursor_peek(c) == 45 || cursor_peek(c) == 43 {
    cursor_bump(c)
  }
  if cursor_peek(c) == 105 &&
    cursor_peek_at(c, 1) == 110 &&
    cursor_peek_at(c, 2) == 102 {
    cursor_bump(c)
    cursor_bump(c)
    cursor_bump(c)
    let tok = slice_text(c.src, start, c.i)
    if tok == "+inf" || tok == "inf" {
      return Ok(ion_float(1.0 / 0.0))
    } else if tok == "-inf" {
      return Ok(ion_float(0.0 - 1.0 / 0.0))
    }
  }
  if starts_with_at(c.src, c.i, "0x") || starts_with_at(c.src, c.i, "0X") {
    c.i += 2
    if cursor_peek(c) == 45 || cursor_peek(c) == 43 {
      cursor_bump(c)
    }
    while is_hex_char(cursor_peek(c)) || cursor_peek(c) == 95 {
      cursor_bump(c)
    }
    let tok = slice_text(c.src, start, c.i)
    let digits = strip_underscores(slice_text(c.src, start + 2, c.i))
    match bigint_from_radix_string(digits, 16) {
      Ok(v) => Ok(ion_bigint(v))
      Err(_) => Err(InvalidNumber(tok))
    }
  } else if starts_with_at(c.src, c.i, "0b") || starts_with_at(c.src, c.i, "0B") {
    c.i += 2
    while cursor_peek(c) == 48 || cursor_peek(c) == 49 || cursor_peek(c) == 95 {
      cursor_bump(c)
    }
    let tok = slice_text(c.src, start, c.i)
    let digits = strip_underscores(slice_text(c.src, start + 2, c.i))
    match bigint_from_radix_string(digits, 2) {
      Ok(v) => Ok(ion_bigint(v))
      Err(_) => Err(InvalidNumber(tok))
    }
  } else {
    while is_digit(cursor_peek(c)) || cursor_peek(c) == 95 {
      cursor_bump(c)
    }
    if cursor_peek(c) == 45 && is_digit(cursor_peek_at(c, 1)) {
      while !cursor_eof(c) &&
            (
              is_digit(cursor_peek(c)) ||
              cursor_peek(c) == 45 ||
              cursor_peek(c) == 84 ||
              cursor_peek(c) == 116 ||
              cursor_peek(c) == 58 ||
              cursor_peek(c) == 46 ||
              cursor_peek(c) == 43 ||
              cursor_peek(c) == 90 ||
              cursor_peek(c) == 122
            ) {
        cursor_bump(c)
      }
      let tok = slice_text(c.src, start, c.i)
      match parse_timestamp_text(tok) {
        Ok(ts) => Ok(ion_timestamp(ts))
        Err(e) => Err(e)
      }
    } else {
      let mut seen_dot = false
      let mut seen_exp = false
      let mut seen_dec = false
      if cursor_peek(c) == 46 {
        seen_dot = true
        cursor_bump(c)
        while is_digit(cursor_peek(c)) || cursor_peek(c) == 95 {
          cursor_bump(c)
        }
      }
      let ch = cursor_peek(c)
      if ch == 100 || ch == 68 {
        seen_dec = true
        cursor_bump(c)
        if cursor_peek(c) == 43 || cursor_peek(c) == 45 {
          cursor_bump(c)
        }
        while is_digit(cursor_peek(c)) || cursor_peek(c) == 95 {
          cursor_bump(c)
        }
      } else if ch == 101 || ch == 69 {
        seen_exp = true
        cursor_bump(c)
        if cursor_peek(c) == 43 || cursor_peek(c) == 45 {
          cursor_bump(c)
        }
        while is_digit(cursor_peek(c)) || cursor_peek(c) == 95 {
          cursor_bump(c)
        }
      }
      let tok = strip_underscores(slice_text(c.src, start, c.i))
      if seen_dec {
        match parse_decimal_text(tok) {
          Ok(d) => Ok(ion_decimal(d))
          Err(e) => Err(e)
        }
      } else if seen_dot || seen_exp {
        match parse_float_text(tok) {
          Ok(v) => Ok(ion_float(v))
          Err(e) => Err(e)
        }
      } else if tok.length() == 5 && tok[4].to_int() == 84 {
        match parse_timestamp_text(tok) {
          Ok(ts) => Ok(ion_timestamp(ts))
          Err(e) => Err(e)
        }
      } else {
        match bigint_from_decimal_string(tok) {
          Ok(v) => Ok(ion_bigint(v))
          Err(e) => Err(e)
        }
      }
    }
  }
}

///|
fn strip_underscores(text : String) -> String {
  let out = StringBuilder()
  let mut i = 0
  while i < text.length() {
    if text[i].to_int() != 95 {
      out.write_char(text[i].to_int().unsafe_to_char())
    }
    i += 1
  }
  out.to_string()
}

///|
fn parse_float_text(text : String) -> Result[Double, IonError] {
  if text == "nan" {
    Ok(1.0 / 0.0 - 1.0 / 0.0)
  } else if text == "+inf" || text == "inf" {
    Ok(1.0 / 0.0)
  } else if text == "-inf" {
    Ok(0.0 - 1.0 / 0.0)
  } else {
    parse_float_manual(text)
  }
}

///|
fn parse_float_manual(text : String) -> Result[Double, IonError] {
  let mut i = 0
  let mut sign = 1.0
  if i < text.length() && text[i].to_int() == 45 {
    sign = -1.0
    i += 1
  } else if i < text.length() && text[i].to_int() == 43 {
    i += 1
  }
  let mut int_part = 0.0
  let mut seen = false
  while i < text.length() && is_digit(text[i].to_int()) {
    seen = true
    int_part = int_part * 10.0 + (text[i].to_int() - 48).to_double()
    i += 1
  }
  let mut frac = 0.0
  let mut scale = 1.0
  if i < text.length() && text[i].to_int() == 46 {
    i += 1
    while i < text.length() && is_digit(text[i].to_int()) {
      seen = true
      scale = scale * 10.0
      frac = frac * 10.0 + (text[i].to_int() - 48).to_double()
      i += 1
    }
  }
  let mut exp = 0
  if i < text.length() && (text[i].to_int() == 101 || text[i].to_int() == 69) {
    i += 1
    match parse_signed_int(slice_text(text, i, text.length())) {
      Ok(v) => {
        exp = v
        i = text.length()
      }
      Err(_) => return Err(InvalidNumber(text))
    }
  }
  if !seen || i != text.length() {
    return Err(InvalidNumber(text))
  }
  Ok(ldexp10(sign * (int_part + frac / scale), exp))
}

///|
fn ldexp10(value : Double, exp : Int) -> Double {
  let mut v = value
  let mut n = exp
  while n > 0 {
    v = v * 10.0
    n -= 1
  }
  while n < 0 {
    v = v / 10.0
    n += 1
  }
  v
}

///|
fn parse_atom(c : TextCursor, sexp : Bool) -> Result[IonValue, IonError] {
  match skip_ws_comments(c) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let ch = cursor_peek(c)
  if ch < 0 {
    Err(UnexpectedEof)
  } else if ch == 91 {
    cursor_bump(c)
    match parse_container(c, 93, false) {
      Ok(v) => Ok(ion_list(v))
      Err(e) => Err(e)
    }
  } else if ch == 40 {
    cursor_bump(c)
    match parse_container(c, 41, true) {
      Ok(v) => Ok(ion_sexp(v))
      Err(e) => Err(e)
    }
  } else if ch == 123 && cursor_peek_at(c, 1) == 123 {
    parse_blob_or_clob(c)
  } else if ch == 123 {
    cursor_bump(c)
    match parse_struct_fields(c) {
      Ok(v) => Ok(ion_struct(v))
      Err(e) => Err(e)
    }
  } else if ch == 34 {
    match read_quoted_string(c) {
      Ok(v) => Ok(ion_string(v))
      Err(e) => Err(e)
    }
  } else if ch == 39 {
    match read_quoted_symbol(c) {
      Ok(v) => Ok(ion_symbol(v))
      Err(e) => Err(e)
    }
  } else if is_digit(ch) ||
    (
      (ch == 45 || ch == 43) &&
      (is_digit(cursor_peek_at(c, 1)) || cursor_peek_at(c, 1) == 105)
    ) {
    parse_number_or_timestamp(c)
  } else if is_ident_start(ch) {
    let ident = read_ident(c)
    if ident == "true" {
      Ok(ion_bool(true))
    } else if ident == "false" {
      Ok(ion_bool(false))
    } else if ident == "null" {
      parse_null_or_typed(c, ident)
    } else if ident == "nan" {
      Ok(ion_float(1.0 / 0.0 - 1.0 / 0.0))
    } else if ident == "+inf" || ident == "inf" {
      Ok(ion_float(1.0 / 0.0))
    } else if ident == "-inf" {
      Ok(ion_float(0.0 - 1.0 / 0.0))
    } else {
      Ok(ion_symbol(ident))
    }
  } else if sexp && is_operator_char(ch) {
    Ok(ion_symbol(read_operator(c)))
  } else {
    Err(InvalidText("unexpected character"))
  }
}

///|
fn parse_annotated_value(
  c : TextCursor,
  sexp : Bool,
) -> Result[IonValue, IonError] {
  match skip_ws_comments(c) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  let anns : Array[String] = []
  let mut looping = true
  while looping {
    match skip_ws_comments(c) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    let save = c.i
    let name = if is_ident_start(cursor_peek(c)) {
      Some(read_ident(c))
    } else if cursor_peek(c) == 39 {
      match read_quoted_symbol(c) {
        Ok(v) => Some(v)
        Err(e) => return Err(e)
      }
    } else {
      None
    }
    match name {
      Some(sym) => {
        match skip_ws_comments(c) {
          Err(e) => return Err(e)
          Ok(_) => ()
        }
        if cursor_peek(c) == 58 && cursor_peek_at(c, 1) == 58 {
          if sym.length() == 0 {
            return Err(InvalidAnnotation("empty"))
          }
          cursor_bump(c)
          cursor_bump(c)
          anns.push(sym)
        } else {
          c.i = save
          looping = false
        }
      }
      None => looping = false
    }
  }
  match parse_atom(c, sexp) {
    Ok(v) =>
      if anns.length() == 0 {
        Ok(v)
      } else {
        Ok({ annotations: anns, datum: v.datum, })
      }
    Err(e) => Err(e)
  }
}

///|
pub fn loads_text(text : String) -> Result[Array[IonValue], IonError] {
  let c : TextCursor = { src: text, i: 0, }
  let values : Array[IonValue] = []
  let mut first = true
  let mut running = true
  while running {
    match skip_ws_comments(c) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    if cursor_eof(c) {
      running = false
    } else {
      match parse_annotated_value(c, false) {
        Ok(v) => {
          let is_version = match v.datum {
            SymbolD(s) => s == "$ion_1_0"
            _ => false
          }
          if first && is_version {
            first = false
          } else if v.is_symbol_table() {
            first = false
          } else {
            first = false
            values.push(v)
          }
        }
        Err(e) => return Err(e)
      }
    }
  }
  Ok(values)
}

///|
pub fn load_text(text : String) -> Result[IonValue, IonError] {
  match loads_text(text) {
    Ok(vs) => if vs.length() == 0 { Err(EmptyDocument) } else { Ok(vs[0]) }
    Err(e) => Err(e)
  }
}
