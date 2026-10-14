///|
priv struct TextCursor {
  src : String
  mut i : Int
  mut depth : Int
  table : SymbolTable
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
      if skip_escaped_newline(c) {
        continue
      }
      match read_escape(c) {
        Ok(v) => out.write_char(v)
        Err(e) => return Err(e)
      }
    } else {
      if ch < 32 || ch == 127 {
        return Err(InvalidText("raw control character"))
      }
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
  match ch {
    48 => Ok('\u0000')
    97 => Ok('\u0007')
    98 => Ok('\b')
    102 => Ok('\u000c')
    110 => Ok('\n')
    114 => Ok('\r')
    116 => Ok('\t')
    118 => Ok('\u000b')
    34 | 39 | 92 | 47 | 63 => Ok(ch.unsafe_to_char())
    120 | 117 | 85 => {
      let count = if ch == 120 { 2 } else if ch == 117 { 4 } else { 8 }
      let mut n = 0L
      for j = 0; j < count; j = j + 1 {
        let v = match nibble_value_int(cursor_peek(c)) {
          Some(v) => v
          None => return Err(InvalidText("invalid Unicode escape"))
        }
        cursor_bump(c)
        n = (n << 4) | v.to_int64()
      }
      if n > 0x10FFFFL || (n >= 0xD800L && n <= 0xDFFFL) {
        return Err(InvalidText("invalid Unicode scalar"))
      }
      Ok(n.to_int().unsafe_to_char())
    }
    _ => Err(InvalidText("unknown escape"))
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
      if skip_escaped_newline(c) {
        continue
      }
      match read_escape(c) {
        Ok(v) => out.write_char(v)
        Err(e) => return Err(e)
      }
    } else {
      if ch < 32 || ch == 127 {
        return Err(InvalidText("raw control character"))
      }
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
  if is_long_quote(c) {
    let text = match read_long_strings(c, true) {
      Ok(v) => v
      Err(e) => return Err(e)
    }
    match skip_ws_comments(c) {
      Ok(_) => ()
      Err(e) => return Err(e)
    }
    if cursor_peek(c) != 125 || cursor_peek_at(c, 1) != 125 {
      return Err(InvalidText("unterminated clob"))
    }
    cursor_bump(c)
    cursor_bump(c)
    let bytes : Array[Byte] = []
    for unit in text {
      bytes.push(unit.to_int().to_byte())
    }
    Ok(ion_clob(Bytes::from_array(bytes)))
  } else if cursor_peek(c) == 34 {
    let bytes : Array[Byte] = []
    while cursor_peek(c) == 34 {
      cursor_bump(c)
      while !cursor_eof(c) && cursor_peek(c) != 34 {
        let n = if cursor_peek(c) == 92 {
          cursor_bump(c)
          if skip_escaped_newline(c) {
            continue
          }
          if cursor_peek(c) == 117 || cursor_peek(c) == 85 {
            return Err(InvalidText("Unicode escape in clob"))
          }
          match read_escape(c) {
            Ok(ch) => ch.to_int()
            Err(e) => return Err(e)
          }
        } else {
          let n = cursor_peek(c)
          if n < 32 || n > 126 {
            return Err(InvalidText("non-ASCII clob character"))
          }
          cursor_bump(c)
          n
        }
        bytes.push(n.to_byte())
      }
      if cursor_eof(c) {
        return Err(InvalidText("unterminated clob"))
      }
      cursor_bump(c)
      match skip_ws_comments(c) {
        Ok(_) => ()
        Err(e) => return Err(e)
      }
      break
    }
    if cursor_peek(c) != 125 || cursor_peek_at(c, 1) != 125 {
      return Err(InvalidText("unterminated clob"))
    }
    cursor_bump(c)
    cursor_bump(c)
    Ok(ion_clob(Bytes::from_array(bytes)))
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
        if sexp {
          return Err(InvalidText("comma in sexp"))
        }
        cursor_bump(c)
      } else if !sexp && cursor_peek(c) != close {
        return Err(InvalidText("expected comma in list"))
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
      } else if cursor_peek(c) != 125 {
        return Err(InvalidText("expected comma in struct"))
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
    let text = read_ident(c)
    if is_reserved_word(text) {
      return Err(InvalidText("keyword used as field name"))
    }
    resolve_text_symbol(c, text)
  } else if is_long_quote(c) {
    read_long_strings(c, false)
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
  if cursor_peek(c) == 43 && is_digit(cursor_peek_at(c, 1)) {
    return Err(InvalidNumber("plus-signed number"))
  }
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
    let digits_start = if c.src[start].to_int() == 45 ||
      c.src[start].to_int() == 43 {
      start + 3
    } else {
      start + 2
    }
    let raw_digits = slice_text(c.src, digits_start, c.i)
    if raw_digits.length() == 0 ||
      raw_digits[0].to_int() == 95 ||
      raw_digits[raw_digits.length() - 1].to_int() == 95 ||
      str_has(raw_digits, 43) ||
      str_has(raw_digits, 45) {
      return Err(InvalidNumber(tok))
    }
    if str_contains_double_underscore(raw_digits) {
      return Err(InvalidNumber(tok))
    }
    let digits = (if c.src[start].to_int() == 45 { "-" } else { "" }) +
      strip_underscores(raw_digits)
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
    let digits_start = if c.src[start].to_int() == 45 ||
      c.src[start].to_int() == 43 {
      start + 3
    } else {
      start + 2
    }
    let raw_digits = slice_text(c.src, digits_start, c.i)
    if raw_digits.length() == 0 ||
      raw_digits[0].to_int() == 95 ||
      raw_digits[raw_digits.length() - 1].to_int() == 95 ||
      str_has(raw_digits, 43) ||
      str_has(raw_digits, 45) {
      return Err(InvalidNumber(tok))
    }
    if str_contains_double_underscore(raw_digits) {
      return Err(InvalidNumber(tok))
    }
    let digits = (if c.src[start].to_int() == 45 { "-" } else { "" }) +
      strip_underscores(raw_digits)
    match bigint_from_radix_string(digits, 2) {
      Ok(v) => Ok(ion_bigint(v))
      Err(_) => Err(InvalidNumber(tok))
    }
  } else {
    while is_digit(cursor_peek(c)) || cursor_peek(c) == 95 {
      cursor_bump(c)
    }
    if cursor_peek(c) == 84 && c.i - start == 4 {
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
      let raw_tok = slice_text(c.src, start, c.i)
      match validate_numeric_token(raw_tok) {
        Err(e) => return Err(e)
        Ok(_) => ()
      }
      let tok = strip_underscores(raw_tok)
      let begin = if tok[0].to_int() == 45 { 1 } else { 0 }
      if begin + 1 < tok.length() &&
        tok[begin].to_int() == 48 &&
        is_digit(tok[begin + 1].to_int()) {
        return Err(InvalidNumber(tok))
      }
      if seen_dec {
        match parse_decimal_text(tok) {
          Ok(d) => Ok(ion_decimal(d))
          Err(e) => Err(e)
        }
      } else if seen_dot && !seen_exp {
        match parse_decimal_text(tok) {
          Ok(d) => Ok(ion_decimal(d))
          Err(e) => Err(e)
        }
      } else if seen_exp {
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
  Ok(@string.parse_double(text[:])) catch {
    _ => Err(InvalidNumber(text))
  }
}

///|
fn parse_atom(c : TextCursor, sexp : Bool) -> Result[IonValue, IonError] {
  if c.depth >= 256 {
    return Err(InvalidText("nesting limit exceeded"))
  }
  match skip_ws_comments(c) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let start = cursor_peek(c)
  c.depth += 1
  let result = parse_atom_inner(c, sexp)
  c.depth -= 1
  if (is_ident_start(start) || is_digit(start) || start == 43 || start == 45) &&
    is_ident_part(cursor_peek(c)) {
    return Err(InvalidText("invalid token boundary"))
  }
  result
}

///|
fn parse_atom_inner(c : TextCursor, sexp : Bool) -> Result[IonValue, IonError] {
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
  } else if is_long_quote(c) {
    match read_long_strings(c, false) {
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
    } else {
      match resolve_text_symbol(c, ident) {
        Ok(s) => Ok(ion_symbol(s))
        Err(e) => Err(e)
      }
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
    } else if cursor_peek(c) == 39 && !is_long_quote(c) {
      match read_quoted_symbol(c) {
        Ok(v) => Some(v)
        Err(e) => return Err(e)
      }
    } else {
      None
    }
    match name {
      Some(sym) => {
        let quoted = c.src[save].to_int() == 39
        match skip_ws_comments(c) {
          Err(e) => return Err(e)
          Ok(_) => ()
        }
        if cursor_peek(c) == 58 && cursor_peek_at(c, 1) == 58 {
          if !quoted && is_reserved_word(sym) {
            return Err(InvalidAnnotation("keyword used as annotation"))
          }
          cursor_bump(c)
          cursor_bump(c)
          let sym = if quoted {
            sym
          } else {
            match resolve_text_symbol(c, sym) {
              Ok(v) => v
              Err(e) => return Err(e)
            }
          }
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
pub fn loads_text(
  text : String,
  catalog? : Array[SharedSymbolTable] = [],
) -> Result[Array[IonValue], IonError] {
  let c : TextCursor = { src: text, i: 0, depth: 0, table: symbol_table_new(), }
  let values : Array[IonValue] = []
  while true {
    match skip_ws_comments(c) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    if cursor_eof(c) {
      break
    }
    let start = c.i
    let v = match parse_annotated_value(c, false) {
      Ok(v) => v
      Err(e) => return Err(e)
    }
    let token = slice_text(text, start, c.i)
    if v.annotations.is_empty() &&
      (token == "$ion_1_0" || token == "'$ion_1_0'") {
      c.table.reset_locals()
    } else if v.annotations.is_empty() && is_text_version_marker(token) {
      return Err(InvalidText("unsupported Ion version"))
    } else if v.is_symbol_table() {
      match apply_local_table(c.table, v, catalog) {
        Ok(_) => ()
        Err(e) => return Err(e)
      }
    } else {
      values.push(v)
    }
  }
  Ok(values)
}

///|
pub fn load_text(
  text : String,
  catalog? : Array[SharedSymbolTable] = [],
) -> Result[IonValue, IonError] {
  match loads_text(text, catalog~) {
    Ok(vs) => if vs.length() == 0 { Err(EmptyDocument) } else { Ok(vs[0]) }
    Err(e) => Err(e)
  }
}

///|
fn resolve_text_symbol(
  c : TextCursor,
  text : String,
) -> Result[String, IonError] {
  if !is_sid_text(text) {
    return Ok(text)
  }
  match parse_signed_int(slice_text(text, 1, text.length())) {
    Ok(sid) => c.table.name_of(sid)
    Err(_) => Err(InvalidSymbol(text))
  }
}

///|
fn validate_numeric_token(text : String) -> Result[Unit, IonError] {
  for i = 0; i < text.length(); i = i + 1 {
    if text[i].to_int() == 95 &&
      (
        i == 0 ||
        i + 1 == text.length() ||
        !is_digit(text[i - 1].to_int()) ||
        !is_digit(text[i + 1].to_int())
      ) {
      return Err(InvalidNumber(text))
    }
  }
  Ok(())
}

///|
fn str_contains_double_underscore(s : String) -> Bool {
  for i = 1; i < s.length(); i = i + 1 {
    if s[i - 1].to_int() == 95 && s[i].to_int() == 95 {
      return true
    }
  }
  false
}

///|
fn skip_escaped_newline(c : TextCursor) -> Bool {
  let ch = cursor_peek(c)
  if ch != 10 && ch != 13 {
    return false
  }
  cursor_bump(c)
  if ch == 13 && cursor_peek(c) == 10 {
    cursor_bump(c)
  }
  true
}

///|
fn is_long_quote(c : TextCursor) -> Bool {
  cursor_peek(c) == 39 &&
  cursor_peek_at(c, 1) == 39 &&
  cursor_peek_at(c, 2) == 39
}

///|
fn read_long_strings(c : TextCursor, clob : Bool) -> Result[String, IonError] {
  let out = StringBuilder()
  while is_long_quote(c) {
    c.i += 3
    let mut closed = false
    while !cursor_eof(c) {
      if is_long_quote(c) {
        c.i += 3
        closed = true
        break
      }
      let ch = cursor_peek(c)
      if ch == 92 {
        cursor_bump(c)
        if skip_escaped_newline(c) {
          continue
        }
        if clob && (cursor_peek(c) == 117 || cursor_peek(c) == 85) {
          return Err(InvalidText("Unicode escape in clob"))
        }
        match read_escape(c) {
          Ok(v) => out.write_char(v)
          Err(e) => return Err(e)
        }
      } else {
        if (ch < 32 && ch != 9 && ch != 10 && ch != 13) ||
          ch == 127 ||
          (clob && ch > 127) {
          return Err(InvalidText("invalid long string character"))
        }
        cursor_bump(c)
        if ch == 13 {
          if cursor_peek(c) == 10 {
            cursor_bump(c)
          }
          out.write_char('\n')
        } else {
          out.write_char(ch.unsafe_to_char())
        }
      }
    }
    if !closed {
      return Err(InvalidText("unterminated long string"))
    }
    match skip_ws_comments(c) {
      Ok(_) => ()
      Err(e) => return Err(e)
    }
  }
  Ok(out.to_string())
}

///|
fn is_reserved_word(s : String) -> Bool {
  s == "true" || s == "false" || s == "null" || s == "nan"
}

///|
fn is_text_version_marker(s : String) -> Bool {
  if !starts_with_at(s, 0, "$ion_") {
    return false
  }
  let mut i = 5
  let first = i
  while i < s.length() && is_digit(s[i].to_int()) {
    i += 1
  }
  if i == first || i >= s.length() || s[i].to_int() != 95 {
    return false
  }
  i += 1
  let second = i
  while i < s.length() && is_digit(s[i].to_int()) {
    i += 1
  }
  i > second && i == s.length()
}
