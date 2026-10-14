///|
fn main {
  match @ion.load_text("null") {
    Ok(v) =>
      println(
        "0" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("0" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.bool") {
    Ok(v) =>
      println(
        "1" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("1" + "|ERROR|" + e.message())
  }
  match @ion.load_text("true") {
    Ok(v) =>
      println(
        "2" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("2" + "|ERROR|" + e.message())
  }
  match @ion.load_text("false") {
    Ok(v) =>
      println(
        "3" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("3" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.int") {
    Ok(v) =>
      println(
        "4" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("4" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.float") {
    Ok(v) =>
      println(
        "5" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("5" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.decimal") {
    Ok(v) =>
      println(
        "6" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("6" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.timestamp") {
    Ok(v) =>
      println(
        "7" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("7" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.symbol") {
    Ok(v) =>
      println(
        "8" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("8" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.string") {
    Ok(v) =>
      println(
        "9" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("9" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.clob") {
    Ok(v) =>
      println(
        "10" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("10" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.blob") {
    Ok(v) =>
      println(
        "11" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("11" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.list") {
    Ok(v) =>
      println(
        "12" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("12" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.sexp") {
    Ok(v) =>
      println(
        "13" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("13" + "|ERROR|" + e.message())
  }
  match @ion.load_text("null.struct") {
    Ok(v) =>
      println(
        "14" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("14" + "|ERROR|" + e.message())
  }
  match @ion.load_text("0") {
    Ok(v) =>
      println(
        "15" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("15" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-1") {
    Ok(v) =>
      println(
        "16" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("16" + "|ERROR|" + e.message())
  }
  match @ion.load_text("127") {
    Ok(v) =>
      println(
        "17" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("17" + "|ERROR|" + e.message())
  }
  match @ion.load_text("128") {
    Ok(v) =>
      println(
        "18" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("18" + "|ERROR|" + e.message())
  }
  match @ion.load_text("255") {
    Ok(v) =>
      println(
        "19" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("19" + "|ERROR|" + e.message())
  }
  match @ion.load_text("256") {
    Ok(v) =>
      println(
        "20" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("20" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-9223372036854775808") {
    Ok(v) =>
      println(
        "21" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("21" + "|ERROR|" + e.message())
  }
  match @ion.load_text("9223372036854775807") {
    Ok(v) =>
      println(
        "22" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("22" + "|ERROR|" + e.message())
  }
  match @ion.load_text("123456789012345678901234567890") {
    Ok(v) =>
      println(
        "23" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("23" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-123456789012345678901234567890") {
    Ok(v) =>
      println(
        "24" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("24" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1d0") {
    Ok(v) =>
      println(
        "25" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("25" + "|ERROR|" + e.message())
  }
  match @ion.load_text("200d0") {
    Ok(v) =>
      println(
        "26" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("26" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-200d0") {
    Ok(v) =>
      println(
        "27" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("27" + "|ERROR|" + e.message())
  }
  match @ion.load_text("128d0") {
    Ok(v) =>
      println(
        "28" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("28" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-128d0") {
    Ok(v) =>
      println(
        "29" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("29" + "|ERROR|" + e.message())
  }
  match @ion.load_text("0d-2") {
    Ok(v) =>
      println(
        "30" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("30" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-0d-2") {
    Ok(v) =>
      println(
        "31" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("31" + "|ERROR|" + e.message())
  }
  match @ion.load_text("123.4500") {
    Ok(v) =>
      println(
        "32" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("32" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1d64") {
    Ok(v) =>
      println(
        "33" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("33" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1d-64") {
    Ok(v) =>
      println(
        "34" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("34" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1d127") {
    Ok(v) =>
      println(
        "35" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("35" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1d-127") {
    Ok(v) =>
      println(
        "36" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("36" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1d128") {
    Ok(v) =>
      println(
        "37" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("37" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1d-128") {
    Ok(v) =>
      println(
        "38" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("38" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1e0") {
    Ok(v) =>
      println(
        "39" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("39" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-0e0") {
    Ok(v) =>
      println(
        "40" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("40" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1.25e0") {
    Ok(v) =>
      println(
        "41" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("41" + "|ERROR|" + e.message())
  }
  match @ion.load_text("nan") {
    Ok(v) =>
      println(
        "42" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("42" + "|ERROR|" + e.message())
  }
  match @ion.load_text("+inf") {
    Ok(v) =>
      println(
        "43" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("43" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-inf") {
    Ok(v) =>
      println(
        "44" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("44" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026T") {
    Ok(v) =>
      println(
        "45" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("45" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-10T") {
    Ok(v) =>
      println(
        "46" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("46" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-10-14") {
    Ok(v) =>
      println(
        "47" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("47" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-10-14T08:30Z") {
    Ok(v) =>
      println(
        "48" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("48" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-10-14T08:30-00:00") {
    Ok(v) =>
      println(
        "49" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("49" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-10-14T08:30:00.001Z") {
    Ok(v) =>
      println(
        "50" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("50" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-10-14T08:30:00.0100Z") {
    Ok(v) =>
      println(
        "51" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("51" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-10-14T08:30:00.000Z") {
    Ok(v) =>
      println(
        "52" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("52" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-01-01T00:15:00+08:00") {
    Ok(v) =>
      println(
        "53" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("53" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2024-03-01T00:00:00+01:00") {
    Ok(v) =>
      println(
        "54" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("54" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-12-31T23:30:00-02:00") {
    Ok(v) =>
      println(
        "55" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("55" + "|ERROR|" + e.message())
  }
  match @ion.load_text("\"hello\"") {
    Ok(v) =>
      println(
        "56" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("56" + "|ERROR|" + e.message())
  }
  match @ion.load_text("\"中文测试\"") {
    Ok(v) =>
      println(
        "57" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("57" + "|ERROR|" + e.message())
  }
  match @ion.load_text("\"\\u03bb\\U0001f600\"") {
    Ok(v) =>
      println(
        "58" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("58" + "|ERROR|" + e.message())
  }
  match @ion.load_text("'true'") {
    Ok(v) =>
      println(
        "59" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("59" + "|ERROR|" + e.message())
  }
  match @ion.load_text("'false'") {
    Ok(v) =>
      println(
        "60" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("60" + "|ERROR|" + e.message())
  }
  match @ion.load_text("'null'") {
    Ok(v) =>
      println(
        "61" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("61" + "|ERROR|" + e.message())
  }
  match @ion.load_text("'nan'") {
    Ok(v) =>
      println(
        "62" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("62" + "|ERROR|" + e.message())
  }
  match @ion.load_text("'$10'") {
    Ok(v) =>
      println(
        "63" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("63" + "|ERROR|" + e.message())
  }
  match @ion.load_text("'has space'") {
    Ok(v) =>
      println(
        "64" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("64" + "|ERROR|" + e.message())
  }
  match @ion.load_text("catalog") {
    Ok(v) =>
      println(
        "65" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("65" + "|ERROR|" + e.message())
  }
  match @ion.load_text("ann::value") {
    Ok(v) =>
      println(
        "66" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("66" + "|ERROR|" + e.message())
  }
  match @ion.load_text("first::second::{foo:1,foo:2,bar: [home,kitchen]}") {
    Ok(v) =>
      println(
        "67" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("67" + "|ERROR|" + e.message())
  }
  match @ion.load_text("[]") {
    Ok(v) =>
      println(
        "68" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("68" + "|ERROR|" + e.message())
  }
  match @ion.load_text("{}") {
    Ok(v) =>
      println(
        "69" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("69" + "|ERROR|" + e.message())
  }
  match @ion.load_text("()") {
    Ok(v) =>
      println(
        "70" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("70" + "|ERROR|" + e.message())
  }
  match @ion.load_text("[1, true, null, {x:2}]") {
    Ok(v) =>
      println(
        "71" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("71" + "|ERROR|" + e.message())
  }
  match @ion.load_text("(+ 1 (* 2 3))") {
    Ok(v) =>
      println(
        "72" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("72" + "|ERROR|" + e.message())
  }
  match @ion.load_text("{{\"\\xFF\\x00\\x80\"}}") {
    Ok(v) =>
      println(
        "73" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("73" + "|ERROR|" + e.message())
  }
  match @ion.load_text("{{AP8=}}") {
    Ok(v) =>
      println(
        "74" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("74" + "|ERROR|" + e.message())
  }
  match @ion.load_text("{{}}") {
    Ok(v) =>
      println(
        "75" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("75" + "|ERROR|" + e.message())
  }
  match @ion.load_text("other::$ion_symbol_table::1") {
    Ok(v) =>
      println(
        "76" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("76" + "|ERROR|" + e.message())
  }
  match
    @ion.load_text(
      "\"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\"",
    ) {
    Ok(v) =>
      println(
        "77" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("77" + "|ERROR|" + e.message())
  }
  match
    @ion.load_text(
      "[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129]",
    ) {
    Ok(v) =>
      println(
        "78" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("78" + "|ERROR|" + e.message())
  }
  match
    @ion.load_text(
      "{field0:0,field1:1,field2:2,field3:3,field4:4,field5:5,field6:6,field7:7,field8:8,field9:9,field10:10,field11:11,field12:12,field13:13,field14:14,field15:15,field16:16,field17:17,field18:18,field19:19,field20:20,field21:21,field22:22,field23:23,field24:24,field25:25,field26:26,field27:27,field28:28,field29:29,field30:30,field31:31,field32:32,field33:33,field34:34,field35:35,field36:36,field37:37,field38:38,field39:39,field40:40,field41:41,field42:42,field43:43,field44:44,field45:45,field46:46,field47:47,field48:48,field49:49,field50:50,field51:51,field52:52,field53:53,field54:54,field55:55,field56:56,field57:57,field58:58,field59:59,field60:60,field61:61,field62:62,field63:63,field64:64,field65:65,field66:66,field67:67,field68:68,field69:69,field70:70,field71:71,field72:72,field73:73,field74:74,field75:75,field76:76,field77:77,field78:78,field79:79,field80:80,field81:81,field82:82,field83:83,field84:84,field85:85,field86:86,field87:87,field88:88,field89:89,field90:90,field91:91,field92:92,field93:93,field94:94,field95:95,field96:96,field97:97,field98:98,field99:99,field100:100,field101:101,field102:102,field103:103,field104:104,field105:105,field106:106,field107:107,field108:108,field109:109,field110:110,field111:111,field112:112,field113:113,field114:114,field115:115,field116:116,field117:117,field118:118,field119:119,field120:120,field121:121,field122:122,field123:123,field124:124,field125:125,field126:126,field127:127,field128:128,field129:129}",
    ) {
    Ok(v) =>
      println(
        "79" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("79" + "|ERROR|" + e.message())
  }
  match
    @ion.load_text(
      "{{\"\\x00\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0a\\x0b\\x0c\\x0d\\x0e\\x0f\\x10\\x11\\x12\\x13\\x14\\x15\\x16\\x17\\x18\\x19\\x1a\\x1b\\x1c\\x1d\\x1e\\x1f\\x20\\x21\\x22\\x23\\x24\\x25\\x26\\x27\\x28\\x29\\x2a\\x2b\\x2c\\x2d\\x2e\\x2f\\x30\\x31\\x32\\x33\\x34\\x35\\x36\\x37\\x38\\x39\\x3a\\x3b\\x3c\\x3d\\x3e\\x3f\\x40\\x41\\x42\\x43\\x44\\x45\\x46\\x47\\x48\\x49\\x4a\\x4b\\x4c\\x4d\\x4e\\x4f\\x50\\x51\\x52\\x53\\x54\\x55\\x56\\x57\\x58\\x59\\x5a\\x5b\\x5c\\x5d\\x5e\\x5f\\x60\\x61\\x62\\x63\\x64\\x65\\x66\\x67\\x68\\x69\\x6a\\x6b\\x6c\\x6d\\x6e\\x6f\\x70\\x71\\x72\\x73\\x74\\x75\\x76\\x77\\x78\\x79\\x7a\\x7b\\x7c\\x7d\\x7e\\x7f\\x80\\x81\\x82\\x83\\x84\\x85\\x86\\x87\\x88\\x89\\x8a\\x8b\\x8c\\x8d\\x8e\\x8f\\x90\\x91\\x92\\x93\\x94\\x95\\x96\\x97\\x98\\x99\\x9a\\x9b\\x9c\\x9d\\x9e\\x9f\\xa0\\xa1\\xa2\\xa3\\xa4\\xa5\\xa6\\xa7\\xa8\\xa9\\xaa\\xab\\xac\\xad\\xae\\xaf\\xb0\\xb1\\xb2\\xb3\\xb4\\xb5\\xb6\\xb7\\xb8\\xb9\\xba\\xbb\\xbc\\xbd\\xbe\\xbf\\xc0\\xc1\\xc2\\xc3\\xc4\\xc5\\xc6\\xc7\\xc8\\xc9\\xca\\xcb\\xcc\\xcd\\xce\\xcf\\xd0\\xd1\\xd2\\xd3\\xd4\\xd5\\xd6\\xd7\\xd8\\xd9\\xda\\xdb\\xdc\\xdd\\xde\\xdf\\xe0\\xe1\\xe2\\xe3\\xe4\\xe5\\xe6\\xe7\\xe8\\xe9\\xea\\xeb\\xec\\xed\\xee\\xef\\xf0\\xf1\\xf2\\xf3\\xf4\\xf5\\xf6\\xf7\\xf8\\xf9\\xfa\\xfb\\xfc\\xfd\\xfe\\xff\"}}",
    ) {
    Ok(v) =>
      println(
        "80" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("80" + "|ERROR|" + e.message())
  }
  match @ion.load_text("0.1e0") {
    Ok(v) =>
      println(
        "81" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("81" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1.2345678901234567e0") {
    Ok(v) =>
      println(
        "82" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("82" + "|ERROR|" + e.message())
  }
  match @ion.load_text("1.7976931348623157e308") {
    Ok(v) =>
      println(
        "83" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("83" + "|ERROR|" + e.message())
  }
  match @ion.load_text("5e-324") {
    Ok(v) =>
      println(
        "84" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("84" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2.2250738585072014e-308") {
    Ok(v) =>
      println(
        "85" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("85" + "|ERROR|" + e.message())
  }
  match @ion.load_text("-1.2345678901234567e-200") {
    Ok(v) =>
      println(
        "86" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("86" + "|ERROR|" + e.message())
  }
  match @ion.load_text("'''line one\nline two'''") {
    Ok(v) =>
      println(
        "87" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("87" + "|ERROR|" + e.message())
  }
  match @ion.load_text("'''a''' /* joined */ '''b'''") {
    Ok(v) =>
      println(
        "88" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("88" + "|ERROR|" + e.message())
  }
  match @ion.load_text("{{'''a\\xFF'''}}") {
    Ok(v) =>
      println(
        "89" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("89" + "|ERROR|" + e.message())
  }
  match @ion.load_text("\"a\\\nb\"") {
    Ok(v) =>
      println(
        "90" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("90" + "|ERROR|" + e.message())
  }
  match @ion.load_text("inf") {
    Ok(v) =>
      println(
        "91" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("91" + "|ERROR|" + e.message())
  }
  match @ion.load_text("''::1") {
    Ok(v) =>
      println(
        "92" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("92" + "|ERROR|" + e.message())
  }
  match @ion.load_text("{'true':1}") {
    Ok(v) =>
      println(
        "93" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("93" + "|ERROR|" + e.message())
  }
  match @ion.load_text("{'''field''':1}") {
    Ok(v) =>
      println(
        "94" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("94" + "|ERROR|" + e.message())
  }
  match @ion.load_text("{{'''a''' '''b'''}}") {
    Ok(v) =>
      println(
        "95" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("95" + "|ERROR|" + e.message())
  }
  match @ion.load_text("2026-10-14T08:30:00.1234567890123Z") {
    Ok(v) =>
      println(
        "96" +
        "|" +
        @ion.hex_encode(@ion.dumps_binary(v)) +
        "|" +
        @ion.dumps_text(v),
      )
    Err(e) => println("96" + "|ERROR|" + e.message())
  }
  let v = @ion.catalog_sample()
  println(
    "catalog_sample|" +
    @ion.hex_encode(@ion.dumps_binary(v)) +
    "|" +
    @ion.dumps_text(v),
  )
  let expr = @ion.sexp_sample()
  println(
    "sexp_sample|" +
    @ion.hex_encode(@ion.dumps_binary(expr)) +
    "|" +
    @ion.dumps_text(expr),
  )
  let catalog : Array[@ion.SharedSymbolTable] = [
    { name: "shared", version: 1, symbols: [Some("a"), None, Some("b")], },
  ]
  match
    @ion.hex_decode(
      "e00100eaee9f8183de9b86be90de8e848673686172656485210188210387b6856c6f63616cde868a710c8d2101",
    ) {
    Ok(data) =>
      match @ion.load_bytes(data, catalog~) {
        Ok(v) =>
          println(
            "shared_catalog|" +
            @ion.hex_encode(@ion.dumps_bytes(v)) +
            "|" +
            @ion.dumps(v),
          )
        Err(e) => println("shared_catalog|ERROR|" + e.message())
      }
    Err(e) => println("shared_catalog|ERROR|" + e.message())
  }
}
