///|
fn nibble_value(c : UInt16) -> Int? {
  if c >= '0' && c <= '9' {
    Some(c.to_int() - 48)
  } else if c >= 'A' && c <= 'F' {
    Some(c.to_int() - 55)
  } else if c >= 'a' && c <= 'f' {
    Some(c.to_int() - 87)
  } else {
    None
  }
}

///|
fn nibble_char(value : Int, upper : Bool) -> Char {
  if value < 10 {
    (48 + value).unsafe_to_char()
  } else if upper {
    (55 + value).unsafe_to_char()
  } else {
    (87 + value).unsafe_to_char()
  }
}

///|
pub fn hex_encode(data : Bytes, upper? : Bool = false) -> String {
  let out = StringBuilder()
  for byte in data {
    let value = byte.to_int()
    out.write_char(nibble_char((value >> 4) & 15, upper))
    out.write_char(nibble_char(value & 15, upper))
  }
  out.to_string()
}

///|
pub fn hex_decode(text : String) -> Result[Bytes, IonError] {
  if text.length() % 2 != 0 {
    return Err(InvalidBlob(text))
  }
  let out : Array[Byte] = []
  let mut i = 0
  while i < text.length() {
    match (nibble_value(text[i]), nibble_value(text[i + 1])) {
      (Some(high), Some(low)) => out.push(((high << 4) | low).to_byte())
      _ => return Err(InvalidBlob(text))
    }
    i += 2
  }
  Ok(Bytes::from_array(out))
}

///|
fn slice_text(text : String, start : Int, end : Int) -> String {
  let out = StringBuilder()
  let mut i = start
  while i < end && i < text.length() {
    out.write_char(text[i].to_int().unsafe_to_char())
    i += 1
  }
  out.to_string()
}

///|
fn utf8_encode(text : String) -> Bytes {
  let out : Array[Byte] = []
  let mut i = 0
  while i < text.length() {
    let unit = text[i].to_int()
    let mut code = unit
    if unit >= 0xD800 && unit <= 0xDBFF && i + 1 < text.length() {
      let next = text[i + 1].to_int()
      if next >= 0xDC00 && next <= 0xDFFF {
        code = 0x10000 + ((unit - 0xD800) << 10) + (next - 0xDC00)
        i += 1
      }
    }
    if code <= 0x7F {
      out.push(code.to_byte())
    } else if code <= 0x7FF {
      out.push((0xC0 | (code >> 6)).to_byte())
      out.push((0x80 | (code & 0x3F)).to_byte())
    } else if code <= 0xFFFF {
      out.push((0xE0 | (code >> 12)).to_byte())
      out.push((0x80 | ((code >> 6) & 0x3F)).to_byte())
      out.push((0x80 | (code & 0x3F)).to_byte())
    } else {
      out.push((0xF0 | (code >> 18)).to_byte())
      out.push((0x80 | ((code >> 12) & 0x3F)).to_byte())
      out.push((0x80 | ((code >> 6) & 0x3F)).to_byte())
      out.push((0x80 | (code & 0x3F)).to_byte())
    }
    i += 1
  }
  Bytes::from_array(out)
}

///|
fn utf8_decode(data : Bytes) -> Result[String, IonError] {
  let out = StringBuilder()
  let arr = bytes_to_array(data)
  let mut i = 0
  while i < arr.length() {
    let b0 = arr[i].to_int()
    if b0 <= 0x7F {
      out.write_char(b0.unsafe_to_char())
      i += 1
    } else if b0 >= 0xC2 && b0 <= 0xDF {
      if i + 1 >= arr.length() {
        return Err(InvalidUtf8)
      }
      let b1 = arr[i + 1].to_int()
      if b1 < 0x80 || b1 > 0xBF {
        return Err(InvalidUtf8)
      }
      let code = ((b0 & 0x1F) << 6) | (b1 & 0x3F)
      out.write_char(code.unsafe_to_char())
      i += 2
    } else if b0 >= 0xE0 && b0 <= 0xEF {
      if i + 2 >= arr.length() {
        return Err(InvalidUtf8)
      }
      let b1 = arr[i + 1].to_int()
      let b2 = arr[i + 2].to_int()
      if b1 < 0x80 || b1 > 0xBF || b2 < 0x80 || b2 > 0xBF {
        return Err(InvalidUtf8)
      }
      let code = ((b0 & 0x0F) << 12) | ((b1 & 0x3F) << 6) | (b2 & 0x3F)
      if code >= 0xD800 && code <= 0xDFFF {
        return Err(InvalidUtf8)
      }
      out.write_char(code.unsafe_to_char())
      i += 3
    } else if b0 >= 0xF0 && b0 <= 0xF4 {
      if i + 3 >= arr.length() {
        return Err(InvalidUtf8)
      }
      let b1 = arr[i + 1].to_int()
      let b2 = arr[i + 2].to_int()
      let b3 = arr[i + 3].to_int()
      if b1 < 0x80 ||
        b1 > 0xBF ||
        b2 < 0x80 ||
        b2 > 0xBF ||
        b3 < 0x80 ||
        b3 > 0xBF {
        return Err(InvalidUtf8)
      }
      let code = ((b0 & 0x07) << 18) |
        ((b1 & 0x3F) << 12) |
        ((b2 & 0x3F) << 6) |
        (b3 & 0x3F)
      if code < 0x10000 || code > 0x10FFFF {
        return Err(InvalidUtf8)
      }
      let cp = code - 0x10000
      out.write_char((0xD800 + (cp >> 10)).unsafe_to_char())
      out.write_char((0xDC00 + (cp & 0x3FF)).unsafe_to_char())
      i += 4
    } else {
      return Err(InvalidUtf8)
    }
  }
  Ok(out.to_string())
}

///|
fn bytes_to_array(data : Bytes) -> Array[Byte] {
  let out : Array[Byte] = []
  for b in data {
    out.push(b)
  }
  out
}

///|
fn array_to_bytes(data : Array[Byte]) -> Bytes {
  Bytes::from_array(data)
}

///|
fn is_digit(c : Int) -> Bool {
  c >= 48 && c <= 57
}

///|
fn is_alpha(c : Int) -> Bool {
  (c >= 65 && c <= 90) || (c >= 97 && c <= 122)
}

///|
fn is_hex_char(c : Int) -> Bool {
  is_digit(c) || (c >= 65 && c <= 70) || (c >= 97 && c <= 102)
}

///|
fn is_ident_start(c : Int) -> Bool {
  is_alpha(c) || c == 36 || c == 95
}

///|
fn is_ident_part(c : Int) -> Bool {
  is_ident_start(c) || is_digit(c)
}

///|
fn is_operator_char(c : Int) -> Bool {
  c == 33 ||
  c == 35 ||
  c == 37 ||
  c == 38 ||
  c == 42 ||
  c == 43 ||
  c == 45 ||
  c == 46 ||
  c == 47 ||
  c == 59 ||
  c == 60 ||
  c == 61 ||
  c == 62 ||
  c == 63 ||
  c == 64 ||
  c == 94 ||
  c == 96 ||
  c == 124 ||
  c == 126
}

///|
fn push_u8(out : Array[Byte], value : Int) -> Unit {
  out.push((value & 255).to_byte())
}

///|
fn slice_bytes(data : Array[Byte], start : Int, end : Int) -> Bytes {
  let out : Array[Byte] = []
  let mut i = start
  while i < end && i < data.length() {
    out.push(data[i])
    i += 1
  }
  array_to_bytes(out)
}

///|
fn base64_encode(data : Bytes) -> String {
  let table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  let arr = bytes_to_array(data)
  let out = StringBuilder()
  let mut i = 0
  while i < arr.length() {
    let b0 = arr[i].to_int()
    let b1 = if i + 1 < arr.length() { arr[i + 1].to_int() } else { 0 }
    let b2 = if i + 2 < arr.length() { arr[i + 2].to_int() } else { 0 }
    let n = (b0 << 16) | (b1 << 8) | b2
    out.write_char(table[(n >> 18) & 63].to_int().unsafe_to_char())
    out.write_char(table[(n >> 12) & 63].to_int().unsafe_to_char())
    if i + 1 < arr.length() {
      out.write_char(table[(n >> 6) & 63].to_int().unsafe_to_char())
    } else {
      out.write_char('=')
    }
    if i + 2 < arr.length() {
      out.write_char(table[n & 63].to_int().unsafe_to_char())
    } else {
      out.write_char('=')
    }
    i += 3
  }
  out.to_string()
}

///|
fn base64_decode(text : String) -> Result[Bytes, IonError] {
  let cleaned = StringBuilder()
  let mut i = 0
  while i < text.length() {
    let c = text[i].to_int()
    if c != 32 && c != 10 && c != 13 && c != 9 {
      cleaned.write_char(c.unsafe_to_char())
    }
    i += 1
  }
  let src = cleaned.to_string()
  if src.length() % 4 != 0 {
    return Err(InvalidBlob(text))
  }
  let out : Array[Byte] = []
  let mut j = 0
  while j < src.length() {
    let mut n = 0
    let mut pads = 0
    let mut k = 0
    while k < 4 {
      let c = src[j + k].to_int()
      let v = if c >= 65 && c <= 90 {
        c - 65
      } else if c >= 97 && c <= 122 {
        c - 71
      } else if c >= 48 && c <= 57 {
        c + 4
      } else if c == 43 {
        62
      } else if c == 47 {
        63
      } else if c == 61 {
        pads += 1
        0
      } else {
        return Err(InvalidBlob(text))
      }
      n = (n << 6) | v
      k += 1
    }
    out.push(((n >> 16) & 255).to_byte())
    if pads < 2 {
      out.push(((n >> 8) & 255).to_byte())
    }
    if pads < 1 {
      out.push((n & 255).to_byte())
    }
    j += 4
  }
  Ok(array_to_bytes(out))
}

///|
fn nibble_value_int(c : Int) -> Int? {
  if c >= 48 && c <= 57 {
    Some(c - 48)
  } else if c >= 65 && c <= 70 {
    Some(c - 55)
  } else if c >= 97 && c <= 102 {
    Some(c - 87)
  } else {
    None
  }
}

///|
fn starts_with_at(text : String, start : Int, prefix : String) -> Bool {
  if start + prefix.length() > text.length() {
    false
  } else {
    slice_text(text, start, start + prefix.length()) == prefix
  }
}
