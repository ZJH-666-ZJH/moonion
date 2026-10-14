///|
pub(all) struct IonDecimal {
  coefficient : BigInt
  exponent : Int32
} derive(Eq, Debug)

///|
pub fn decimal_from_int(value : Int32) -> IonDecimal {
  { coefficient: bigint_from_int(value), exponent: 0, }
}

///|
pub fn decimal_from_parts(coefficient : BigInt, exponent : Int32) -> IonDecimal {
  { coefficient, exponent, }
}

///|
pub fn IonDecimal::is_zero(self : IonDecimal) -> Bool {
  self.coefficient.is_zero()
}

///|
pub fn IonDecimal::to_ion_text(self : IonDecimal) -> String {
  let coeff = self.coefficient.to_decimal_string()
  if self.exponent == 0 {
    (if self.coefficient.negative && self.coefficient.is_zero() {
      "-0"
    } else {
      coeff
    }) +
    "d0"
  } else {
    (if self.coefficient.negative && self.coefficient.is_zero() {
      "-0"
    } else {
      coeff
    }) +
    "d" +
    self.exponent.to_string()
  }
}

///|
pub fn parse_decimal_text(text : String) -> Result[IonDecimal, IonError] {
  if text.length() == 0 {
    return Err(InvalidDecimal(text))
  }
  let begin = if text[0].to_int() == 45 { 1 } else { 0 }
  if begin >= text.length() || !is_digit(text[begin].to_int()) {
    return Err(InvalidDecimal(text))
  }
  if begin + 1 < text.length() &&
    text[begin].to_int() == 48 &&
    is_digit(text[begin + 1].to_int()) {
    return Err(InvalidDecimal(text))
  }
  let mut exp_digits = 0
  let mut exp_started = false
  for idx = 0; idx < text.length(); idx = idx + 1 {
    let ch = text[idx].to_int()
    if ch == 95 &&
      (
        idx == 0 ||
        idx + 1 == text.length() ||
        !is_digit(text[idx - 1].to_int()) ||
        !is_digit(text[idx + 1].to_int())
      ) {
      return Err(InvalidDecimal(text))
    }
    if exp_started && is_digit(ch) {
      exp_digits += 1
    }
    if ch == 100 || ch == 68 {
      exp_started = true
    }
  }
  if exp_started && exp_digits == 0 {
    return Err(InvalidDecimal(text))
  }
  let mut i = 0
  if i < text.length() && (text[i].to_int() == 43 || text[i].to_int() == 45) {
    i += 1
  }
  let mut seen_digit = false
  let mut seen_dot = false
  let mut seen_d = false
  let mut j = i
  while j < text.length() {
    let c = text[j].to_int()
    if c == 95 {
      j += 1
    } else if is_digit(c) {
      seen_digit = true
      j += 1
    } else if c == 46 && !seen_dot && !seen_d {
      seen_dot = true
      j += 1
    } else if (c == 100 || c == 68) && !seen_d {
      seen_d = true
      j += 1
      if j < text.length() && (text[j].to_int() == 43 || text[j].to_int() == 45) {
        j += 1
      }
    } else {
      return Err(InvalidDecimal(text))
    }
  }
  if !seen_digit {
    return Err(InvalidDecimal(text))
  }
  let mut sign = ""
  let mut k = 0
  if text[0].to_int() == 45 {
    sign = "-"
    k = 1
  } else if text[0].to_int() == 43 {
    k = 1
  }
  let digits = StringBuilder()
  let mut frac = 0
  let exp_part = StringBuilder()
  let mut in_exp = false
  let mut after_dot = false
  while k < text.length() {
    let c = text[k].to_int()
    if c == 95 {
      k += 1
    } else if c == 46 && !in_exp {
      after_dot = true
      k += 1
    } else if c == 100 || c == 68 {
      in_exp = true
      k += 1
    } else if in_exp {
      exp_part.write_char(c.unsafe_to_char())
      k += 1
    } else {
      digits.write_char(c.unsafe_to_char())
      if after_dot {
        frac += 1
      }
      k += 1
    }
  }
  let coeff_text = sign + digits.to_string()
  let coeff = match bigint_from_decimal_string(coeff_text) {
    Ok(v) => v
    Err(_) => return Err(InvalidDecimal(text))
  }
  let mut exp = 0
  let exp_text = exp_part.to_string()
  if exp_text.length() > 0 {
    match parse_signed_int(exp_text) {
      Ok(v) => exp = v
      Err(_) => return Err(InvalidDecimal(text))
    }
  }
  if exp < -2147483648 + frac {
    return Err(InvalidDecimal(text))
  }
  let coeff = if sign == "-" && coeff.is_zero() {
    { ..coeff, negative: true, }
  } else {
    coeff
  }
  Ok({ coefficient: coeff, exponent: exp - frac, })
}

///|
fn parse_signed_int(text : String) -> Result[Int32, IonError] {
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
  let mut n = 0
  while i < text.length() {
    let c = text[i].to_int()
    if c == 95 {
      i += 1
      continue
    }
    if !is_digit(c) {
      return Err(InvalidNumber(text))
    }
    let digit = c - 48
    // Accumulate negative to represent Int::min_value without overflow.
    let limit = if negative { -2147483648 } else { -2147483647 }
    if n < limit / 10 || (n == limit / 10 && digit > -(limit % 10)) {
      return Err(InvalidNumber(text))
    }
    n = n * 10 - digit
    i += 1
  }
  if negative {
    Ok(n)
  } else {
    Ok(0 - n)
  }
}
