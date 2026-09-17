///|
fn ldexp2(value : Double, exp : Int) -> Double {
  let mut v = value
  let mut n = exp
  while n > 0 {
    v = v * 2.0
    n -= 1
  }
  while n < 0 {
    v = v / 2.0
    n += 1
  }
  v
}

///|
fn is_nan(value : Double) -> Bool {
  value != value
}

///|
fn is_inf(value : Double) -> Bool {
  value != 0.0 && value * 0.5 == value
}

///|
pub fn f64_from_be_bytes(
  b0 : Int,
  b1 : Int,
  b2 : Int,
  b3 : Int,
  b4 : Int,
  b5 : Int,
  b6 : Int,
  b7 : Int,
) -> Double {
  let hi = (b0.to_int64() << 56) |
    (b1.to_int64() << 48) |
    (b2.to_int64() << 40) |
    (b3.to_int64() << 32)
  let lo = (b4.to_int64() << 24) |
    (b5.to_int64() << 16) |
    (b6.to_int64() << 8) |
    b7.to_int64()
  let bits = hi | lo
  f64_from_bits(bits)
}

///|
pub fn f64_from_be4(b0 : Int, b1 : Int, b2 : Int, b3 : Int) -> Double {
  let bits32 = (b0.reinterpret_as_uint() << 24) |
    (b1.reinterpret_as_uint() << 16) |
    (b2.reinterpret_as_uint() << 8) |
    b3.reinterpret_as_uint()
  let sign = bits32 >> 31 != 0U
  let exp = ((bits32 >> 23) & 255U).reinterpret_as_int()
  let frac = (bits32 & 0x7FFFFFU).reinterpret_as_int()
  if exp == 0 {
    if frac == 0 {
      if sign {
        -0.0
      } else {
        0.0
      }
    } else {
      let mag = ldexp2(frac.to_double() / 8388608.0, -126)
      if sign {
        0.0 - mag
      } else {
        mag
      }
    }
  } else if exp == 255 {
    let inf = 1.0 / 0.0
    if frac != 0 {
      inf - inf
    } else if sign {
      0.0 - inf
    } else {
      inf
    }
  } else {
    let mag = ldexp2(1.0 + frac.to_double() / 8388608.0, exp - 127)
    if sign {
      0.0 - mag
    } else {
      mag
    }
  }
}

///|
fn f64_from_bits(bits : Int64) -> Double {
  let sign = bits < 0L
  let exp = ((bits >> 52) & 2047L).to_int()
  let frac = bits & 4503599627370495L
  if exp == 0 {
    if frac == 0L {
      if sign {
        -0.0
      } else {
        0.0
      }
    } else {
      let mag = ldexp2(frac.to_double() / 4503599627370496.0, -1022)
      if sign {
        0.0 - mag
      } else {
        mag
      }
    }
  } else if exp == 2047 {
    let inf = 1.0 / 0.0
    if frac != 0L {
      inf - inf
    } else if sign {
      0.0 - inf
    } else {
      inf
    }
  } else {
    let mag = ldexp2(1.0 + frac.to_double() / 4503599627370496.0, exp - 1023)
    if sign {
      0.0 - mag
    } else {
      mag
    }
  }
}

///|
pub fn f64_to_be_bytes(value : Double) -> Bytes {
  let bits = f64_to_bits(value)
  let out : Array[Byte] = []
  let mut shift = 56
  while shift >= 0 {
    let part = ((bits >> shift) & 255L).to_int()
    out.push(part.to_byte())
    shift -= 8
  }
  array_to_bytes(out)
}

///|
fn f64_to_bits(value : Double) -> Int64 {
  if is_nan(value) {
    0x7FF8000000000000L
  } else if is_inf(value) {
    if value < 0.0 {
      0xFFF0000000000000L
    } else {
      0x7FF0000000000000L
    }
  } else if value == 0.0 {
    if 1.0 / value < 0.0 {
      0x8000000000000000L
    } else {
      0L
    }
  } else {
    let mut sign = 0L
    let mut mag = value
    if mag < 0.0 {
      sign = 1L << 63
      mag = 0.0 - mag
    }
    let mut exp = 0
    while mag >= 2.0 && exp < 1023 {
      mag = mag / 2.0
      exp += 1
    }
    while mag < 1.0 && exp > -1022 {
      mag = mag * 2.0
      exp -= 1
    }
    if mag < 1.0 {
      let frac = (mag * 4503599627370496.0).to_int64()
      sign | (frac & 4503599627370495L)
    } else {
      let biased = exp + 1023
      let frac = ((mag - 1.0) * 4503599627370496.0).to_int64()
      sign | (biased.to_int64() << 52) | (frac & 4503599627370495L)
    }
  }
}
