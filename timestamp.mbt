///|
pub(all) enum TimestampPrecision {
  Year
  Month
  Day
  Minute
  Second
  Fractional
} derive(Eq, Debug)

///|
pub(all) struct IonTimestamp {
  year : Int32
  month : Int32
  day : Int32
  hour : Int32
  minute : Int32
  second : Int32
  fraction : IonDecimal
  offset_minutes : Int32
  offset_unknown : Bool
  precision : TimestampPrecision
} derive(Eq, Debug)

///|
pub fn timestamp_year(year : Int32) -> Result[IonTimestamp, IonError] {
  if year < 1 || year > 9999 {
    Err(InvalidTimestamp(year.to_string()))
  } else {
    Ok({
      year,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0,
      fraction: decimal_from_int(0),
      offset_minutes: 0,
      offset_unknown: true,
      precision: Year,
    })
  }
}

///|
fn days_in_month(year : Int32, month : Int32) -> Int32 {
  if month == 1 ||
    month == 3 ||
    month == 5 ||
    month == 7 ||
    month == 8 ||
    month == 10 ||
    month == 12 {
    31
  } else if month == 4 || month == 6 || month == 9 || month == 11 {
    30
  } else if month == 2 {
    if year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) {
      29
    } else {
      28
    }
  } else {
    0
  }
}

///|
pub fn timestamp_of(
  year : Int32,
  month : Int32,
  day : Int32,
  hour : Int32,
  minute : Int32,
  second : Int32,
  fraction : IonDecimal,
  offset_minutes : Int32,
  offset_unknown : Bool,
  precision : TimestampPrecision,
) -> Result[IonTimestamp, IonError] {
  if year < 1 || year > 9999 {
    return Err(InvalidTimestamp("year"))
  }
  match precision {
    Year => ()
    Month =>
      if month < 1 || month > 12 {
        return Err(InvalidTimestamp("month"))
      }
    Day => {
      if month < 1 || month > 12 {
        return Err(InvalidTimestamp("month"))
      }
      if day < 1 || day > days_in_month(year, month) {
        return Err(InvalidTimestamp("day"))
      }
    }
    Minute => {
      if month < 1 || month > 12 {
        return Err(InvalidTimestamp("month"))
      }
      if day < 1 || day > days_in_month(year, month) {
        return Err(InvalidTimestamp("day"))
      }
      if hour < 0 || hour > 23 {
        return Err(InvalidTimestamp("hour"))
      }
      if minute < 0 || minute > 59 {
        return Err(InvalidTimestamp("minute"))
      }
    }
    Second => {
      if month < 1 || month > 12 {
        return Err(InvalidTimestamp("month"))
      }
      if day < 1 || day > days_in_month(year, month) {
        return Err(InvalidTimestamp("day"))
      }
      if hour < 0 || hour > 23 {
        return Err(InvalidTimestamp("hour"))
      }
      if minute < 0 || minute > 59 {
        return Err(InvalidTimestamp("minute"))
      }
      if second < 0 || second > 59 {
        return Err(InvalidTimestamp("second"))
      }
    }
    Fractional => {
      if month < 1 || month > 12 {
        return Err(InvalidTimestamp("month"))
      }
      if day < 1 || day > days_in_month(year, month) {
        return Err(InvalidTimestamp("day"))
      }
      if hour < 0 || hour > 23 {
        return Err(InvalidTimestamp("hour"))
      }
      if minute < 0 || minute > 59 {
        return Err(InvalidTimestamp("minute"))
      }
      if (match precision {
          Second => true
          Fractional => true
          _ => false
        }) {
        if second < 0 || second > 59 {
          return Err(InvalidTimestamp("second"))
        }
      }
    }
  }
  if !offset_unknown &&
    (offset_minutes < -23 * 60 - 59 || offset_minutes > 23 * 60 + 59) {
    return Err(InvalidTimestamp("offset"))
  }
  if precision == Fractional &&
    (
      fraction.coefficient.negative ||
      fraction.exponent >= 0 ||
      fraction.exponent < -4096 ||
      fraction.coefficient.to_decimal_string().length() > -fraction.exponent
    ) {
    return Err(
      InvalidTimestamp("fraction must be in [0,1) with negative exponent"),
    )
  }
  let offset_unknown = offset_unknown ||
    precision == Year ||
    precision == Month ||
    precision == Day
  Ok({
    year,
    month,
    day,
    hour,
    minute,
    second,
    fraction,
    offset_minutes,
    offset_unknown,
    precision,
  })
}

///|
fn pad2(n : Int32) -> String {
  if n < 10 {
    "0" + n.to_string()
  } else {
    n.to_string()
  }
}

///|
fn pad4(n : Int32) -> String {
  if n < 10 {
    "000" + n.to_string()
  } else if n < 100 {
    "00" + n.to_string()
  } else if n < 1000 {
    "0" + n.to_string()
  } else {
    n.to_string()
  }
}

///|
fn offset_text(ts : IonTimestamp) -> String {
  if ts.offset_unknown {
    "-00:00"
  } else if ts.offset_minutes == 0 {
    "Z"
  } else {
    let mut m = ts.offset_minutes
    let mut sign = "+"
    if m < 0 {
      sign = "-"
      m = 0 - m
    }
    sign + pad2(m / 60) + ":" + pad2(m % 60)
  }
}

///|
pub fn IonTimestamp::to_ion_text(self : IonTimestamp) -> String {
  match self.precision {
    Year => pad4(self.year) + "T"
    Month => pad4(self.year) + "-" + pad2(self.month) + "T"
    Day => pad4(self.year) + "-" + pad2(self.month) + "-" + pad2(self.day) + "T"
    Minute =>
      pad4(self.year) +
      "-" +
      pad2(self.month) +
      "-" +
      pad2(self.day) +
      "T" +
      pad2(self.hour) +
      ":" +
      pad2(self.minute) +
      offset_text(self)
    Second =>
      pad4(self.year) +
      "-" +
      pad2(self.month) +
      "-" +
      pad2(self.day) +
      "T" +
      pad2(self.hour) +
      ":" +
      pad2(self.minute) +
      ":" +
      pad2(self.second) +
      offset_text(self)
    Fractional =>
      pad4(self.year) +
      "-" +
      pad2(self.month) +
      "-" +
      pad2(self.day) +
      "T" +
      pad2(self.hour) +
      ":" +
      pad2(self.minute) +
      ":" +
      pad2(self.second) +
      "." +
      fraction_digits(self.fraction) +
      offset_text(self)
  }
}

///|
fn fraction_digits(frac : IonDecimal) -> String {
  let s = frac.coefficient.to_decimal_string()
  let out = StringBuilder()
  for i = s.length(); i < -frac.exponent; i = i + 1 {
    out.write_char('0')
  }
  out.write_string(s)
  out.to_string()
}

///|
// Ion binary stores the date/time fields in UTC; the public model uses local time.
fn shift_timestamp(ts : IonTimestamp, minutes : Int32) -> IonTimestamp {
  if ts.precision == Year || ts.precision == Month || ts.precision == Day {
    return ts
  }
  let mut total = ts.hour * 60 + ts.minute + minutes
  let mut year = ts.year
  let mut month = ts.month
  let mut day = ts.day
  while total < 0 {
    total += 1440
    day -= 1
    if day == 0 {
      month -= 1
      if month == 0 {
        month = 12
        year -= 1
      }
      day = days_in_month(year, month)
    }
  }
  while total >= 1440 {
    total -= 1440
    day += 1
    if day > days_in_month(year, month) {
      day = 1
      month += 1
      if month == 13 {
        month = 1
        year += 1
      }
    }
  }
  { ..ts, year, month, day, hour: total / 60, minute: total % 60, }
}

///|
pub fn parse_timestamp_text(text : String) -> Result[IonTimestamp, IonError] {
  if text.length() < 5 {
    ()
  }
  if text.length() < 4 {
    return Err(InvalidTimestamp(text))
  }
  let year = match parse_fixed_digits(text, 0, 4) {
    Ok(v) => v
    Err(_) => return Err(InvalidTimestamp(text))
  }
  if text.length() == 5 && text[4].to_int() == 84 {
    return timestamp_year(year)
  }
  if text.length() == 4 {
    return timestamp_year(year)
  }
  if text.length() < 7 || text[4].to_int() != 45 {
    return Err(InvalidTimestamp(text))
  }
  let month = match parse_fixed_digits(text, 5, 2) {
    Ok(v) => v
    Err(_) => return Err(InvalidTimestamp(text))
  }
  if text.length() == 8 && text[7].to_int() == 84 {
    return timestamp_of(
      year,
      month,
      1,
      0,
      0,
      0,
      decimal_from_int(0),
      0,
      false,
      Month,
    )
  }
  if text.length() < 10 || text[7].to_int() != 45 {
    return Err(InvalidTimestamp(text))
  }
  let day = match parse_fixed_digits(text, 8, 2) {
    Ok(v) => v
    Err(_) => return Err(InvalidTimestamp(text))
  }
  if text.length() == 10 || (text.length() == 11 && text[10].to_int() == 84) {
    return timestamp_of(
      year,
      month,
      day,
      0,
      0,
      0,
      decimal_from_int(0),
      0,
      false,
      Day,
    )
  }
  if text.length() < 16 || text[10].to_int() != 84 {
    return Err(InvalidTimestamp(text))
  }
  let hour = match parse_fixed_digits(text, 11, 2) {
    Ok(v) => v
    Err(_) => return Err(InvalidTimestamp(text))
  }
  if text[13].to_int() != 58 {
    return Err(InvalidTimestamp(text))
  }
  let minute = match parse_fixed_digits(text, 14, 2) {
    Ok(v) => v
    Err(_) => return Err(InvalidTimestamp(text))
  }
  let mut idx = 16
  let mut second = 0
  let mut frac = decimal_from_int(0)
  let mut precision = Minute
  if idx < text.length() && text[idx].to_int() == 58 {
    second = match parse_fixed_digits(text, 17, 2) {
      Ok(v) => v
      Err(_) => return Err(InvalidTimestamp(text))
    }
    idx = 19
    precision = Second
    if idx < text.length() && text[idx].to_int() == 46 {
      idx += 1
      let start = idx
      while idx < text.length() && is_digit(text[idx].to_int()) {
        idx += 1
      }
      if idx == start {
        return Err(InvalidTimestamp(text))
      }
      let digits = slice_text(text, start, idx)
      match parse_decimal_text("0." + digits + "d0") {
        Ok(v) => frac = v
        Err(_) => return Err(InvalidTimestamp(text))
      }
      precision = Fractional
    }
  }
  if idx >= text.length() {
    return Err(InvalidTimestamp(text))
  }
  let rest = slice_text(text, idx, text.length())
  let (offset_minutes, offset_unknown) = match parse_offset(rest) {
    Ok(v) => v
    Err(_) => return Err(InvalidTimestamp(text))
  }
  timestamp_of(
    year, month, day, hour, minute, second, frac, offset_minutes, offset_unknown,
    precision,
  )
}

///|
fn parse_fixed_digits(
  text : String,
  start : Int32,
  len : Int32,
) -> Result[Int32, IonError] {
  if start + len > text.length() {
    return Err(InvalidNumber(text))
  }
  let mut n = 0
  let mut i = 0
  while i < len {
    let c = text[start + i].to_int()
    if !is_digit(c) {
      return Err(InvalidNumber(text))
    }
    n = n * 10 + (c - 48)
    i += 1
  }
  Ok(n)
}

///|
fn parse_offset(text : String) -> Result[(Int32, Bool), IonError] {
  if text == "Z" {
    Ok((0, false))
  } else if text == "-00:00" {
    Ok((0, true))
  } else if text.length() == 6 &&
    (text[0].to_int() == 43 || text[0].to_int() == 45) &&
    text[3].to_int() == 58 {
    let hh = match parse_fixed_digits(text, 1, 2) {
      Ok(v) => v
      Err(_) => return Err(InvalidTimestamp(text))
    }
    let mm = match parse_fixed_digits(text, 4, 2) {
      Ok(v) => v
      Err(_) => return Err(InvalidTimestamp(text))
    }
    if hh > 23 || mm > 59 {
      return Err(InvalidTimestamp(text))
    }
    let mut total = hh * 60 + mm
    if text[0].to_int() == 45 {
      total = 0 - total
    }
    Ok((total, false))
  } else {
    Err(InvalidTimestamp(text))
  }
}
