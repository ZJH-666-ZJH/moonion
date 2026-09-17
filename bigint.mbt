///|
pub(all) struct BigInt {
  negative : Bool
  digits : Bytes
} derive(Eq, Debug)

///|
pub fn bigint_zero() -> BigInt {
  { negative: false, digits: Bytes::from_array([]), }
}

///|
pub fn bigint_from_int(value : Int) -> BigInt {
  bigint_from_int64(value.to_int64())
}

///|
pub fn bigint_from_int64(value : Int64) -> BigInt {
  if value == 0L {
    bigint_zero()
  } else {
    let negative = value < 0L
    let mut mag = if negative { 0L - value } else { value }
    let tmp : Array[Byte] = []
    while mag > 0L {
      tmp.push((mag & 255L).to_int().to_byte())
      mag = mag >> 8
    }
    let digits : Array[Byte] = []
    let mut i = tmp.length() - 1
    while i >= 0 {
      digits.push(tmp[i])
      i -= 1
    }
    { negative, digits: array_to_bytes(digits), }
  }
}

///|
pub fn bigint_from_magnitude(negative : Bool, mag : Bytes) -> BigInt {
  let arr = bytes_to_array(mag)
  let mut start = 0
  while start < arr.length() && arr[start].to_int() == 0 {
    start += 1
  }
  if start >= arr.length() {
    bigint_zero()
  } else {
    { negative, digits: slice_bytes(arr, start, arr.length()), }
  }
}

///|
pub fn BigInt::is_zero(self : BigInt) -> Bool {
  self.digits.length() == 0
}

///|
pub fn BigInt::sign(self : BigInt) -> Int {
  if self.digits.length() == 0 {
    0
  } else if self.negative {
    -1
  } else {
    1
  }
}

///|
pub fn BigInt::to_int64(self : BigInt) -> Int64? {
  if self.digits.length() == 0 {
    Some(0L)
  } else if self.digits.length() > 8 {
    None
  } else {
    let arr = bytes_to_array(self.digits)
    let mut n = 0L
    for b in arr {
      n = (n << 8) | b.to_int().to_int64()
    }
    if self.negative {
      if n < 0L {
        None
      } else {
        Some(0L - n)
      }
    } else if n < 0L {
      None
    } else {
      Some(n)
    }
  }
}

///|
fn divmod10_digits(digits : Array[Byte]) -> (Array[Byte], Int) {
  let q : Array[Byte] = []
  let mut rem = 0
  for b in digits {
    let cur = rem * 256 + b.to_int()
    let d = cur / 10
    rem = cur % 10
    if q.length() > 0 || d != 0 {
      q.push(d.to_byte())
    }
  }
  (q, rem)
}

///|
pub fn BigInt::to_decimal_string(self : BigInt) -> String {
  if self.digits.length() == 0 {
    "0"
  } else {
    let mut digits = bytes_to_array(self.digits)
    let acc : Array[Int] = []
    while digits.length() > 0 {
      let pair = divmod10_digits(digits)
      digits = pair.0
      acc.push(pair.1)
    }
    let out = StringBuilder()
    if self.negative {
      out.write_char('-')
    }
    let mut i = acc.length() - 1
    while i >= 0 {
      out.write_char((48 + acc[i]).unsafe_to_char())
      i -= 1
    }
    out.to_string()
  }
}

///|
pub fn bigint_from_decimal_string(text : String) -> Result[BigInt, IonError] {
  if text.length() == 0 {
    return Err(InvalidNumber(text))
  }
  let mut i = 0
  let mut negative = false
  if text[0].to_int() == 45 {
    negative = true
    i = 1
  } else if text[0].to_int() == 43 {
    i = 1
  }
  if i >= text.length() {
    return Err(InvalidNumber(text))
  }
  let mag : Array[Byte] = []
  let mut seen = false
  while i < text.length() {
    let c = text[i].to_int()
    if c == 95 {
      i += 1
      continue
    }
    if !is_digit(c) {
      return Err(InvalidNumber(text))
    }
    seen = true
    mul_add_radix(mag, 10, c - 48)
    i += 1
  }
  if !seen {
    return Err(InvalidNumber(text))
  }
  Ok(mag_le_to_bigint(negative, mag))
}

///|
pub fn bigint_from_radix_string(
  text : String,
  radix : Int,
) -> Result[BigInt, IonError] {
  if text.length() == 0 {
    return Err(InvalidNumber(text))
  }
  let mut i = 0
  let mut negative = false
  if text[0].to_int() == 45 {
    negative = true
    i = 1
  } else if text[0].to_int() == 43 {
    i = 1
  }
  if i >= text.length() {
    return Err(InvalidNumber(text))
  }
  let mag : Array[Byte] = []
  let mut seen = false
  while i < text.length() {
    let c = text[i].to_int()
    if c == 95 {
      i += 1
      continue
    }
    let digit = if is_digit(c) {
      c - 48
    } else if c >= 65 && c <= 90 {
      c - 55
    } else if c >= 97 && c <= 122 {
      c - 87
    } else {
      return Err(InvalidNumber(text))
    }
    if digit >= radix {
      return Err(InvalidNumber(text))
    }
    seen = true
    mul_add_radix(mag, radix, digit)
    i += 1
  }
  if !seen {
    return Err(InvalidNumber(text))
  }
  Ok(mag_le_to_bigint(negative, mag))
}

///|
pub fn BigInt::compare(self : BigInt, other : BigInt) -> Int {
  if self.sign() != other.sign() {
    if self.sign() < other.sign() {
      -1
    } else {
      1
    }
  } else if self.digits.length() != other.digits.length() {
    let cmp = if self.digits.length() > other.digits.length() { 1 } else { -1 }
    if self.negative {
      0 - cmp
    } else {
      cmp
    }
  } else {
    let a = bytes_to_array(self.digits)
    let b = bytes_to_array(other.digits)
    let mut i = 0
    let mut cmp = 0
    while i < a.length() {
      if a[i].to_int() != b[i].to_int() {
        cmp = if a[i].to_int() > b[i].to_int() { 1 } else { -1 }
        i = a.length()
      } else {
        i += 1
      }
    }
    if self.negative {
      0 - cmp
    } else {
      cmp
    }
  }
}

///|
pub fn BigInt::eq_value(self : BigInt, other : BigInt) -> Bool {
  self.compare(other) == 0
}

///|
fn mul_add_radix(mag : Array[Byte], radix : Int, digit : Int) -> Unit {
  let mut carry = digit
  let mut k = 0
  while k < mag.length() || carry > 0 {
    let cur = if k < mag.length() {
      mag[k].to_int() * radix + carry
    } else {
      carry
    }
    if k < mag.length() {
      mag[k] = (cur & 255).to_byte()
    } else {
      mag.push((cur & 255).to_byte())
    }
    carry = cur >> 8
    k += 1
  }
}

///|
fn mag_le_to_bigint(negative : Bool, mag : Array[Byte]) -> BigInt {
  if mag.length() == 0 {
    bigint_zero()
  } else {
    let be : Array[Byte] = []
    let mut i = mag.length() - 1
    while i >= 0 {
      be.push(mag[i])
      i -= 1
    }
    bigint_from_magnitude(negative, array_to_bytes(be))
  }
}
