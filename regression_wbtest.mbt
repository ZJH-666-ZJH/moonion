///|
test "mail regression decimal standard bytes and signed coefficient" {
  for
    (hex, expected) in [
      ("e00100ea528001", "1d0"),
      ("e00100ea538000c8", "200d0"),
      ("e00100ea538080c8", "-200d0"),
    ] {
    let data = match hex_decode(hex) {
      Ok(v) => v
      Err(e) => fail(e.message())
    }
    let value = match load_binary(data) {
      Ok(v) => v
      Err(e) => fail(e.message())
    }
    assert_eq(dumps_text(value), expected)
    let restored = match load_binary(dumps_binary(value)) {
      Ok(v) => v
      Err(e) => fail(e.message())
    }
    assert_eq(dumps_text(restored), expected)
  }
}

///|
test "mail regression timestamp fractional digits offsets and UTC rollover" {
  for
    text in [
      "2026-01-01T00:15:00.001+08:00", "2024-03-01T00:00:00.0100+01:00", "2026-12-31T23:30:00.000-02:00",
      "2026-10-14T08:30-00:00",
    ] {
    let v = match load_text(text) {
      Ok(v) => v
      Err(e) => fail(e.message())
    }
    assert_eq(dumps_text(v), text)
    let restored = match load_binary(dumps_binary(v)) {
      Ok(v) => v
      Err(e) => fail(e.message())
    }
    assert_eq(dumps_text(restored), text)
  }
  for
    text in [
      "2026-10-14T08:30+00:99", "2026-10-14T08:30+24:00", "2026-02-29T08:30Z", "2026-10-14T08:30:60Z",
    ] {
    assert_true(load_text(text) is Err(_))
  }
}

///|
test "mail regression clob all byte values stay byte values" {
  let bytes : Array[Byte] = []
  for i = 0; i < 256; i = i + 1 {
    bytes.push(i.to_byte())
  }
  let original = ion_clob(Bytes::from_array(bytes))
  assert_eq(load_text(dumps_text(original)), Ok(original))
  assert_eq(load_binary(dumps_binary(original)), Ok(original))
  assert_true(load_text("{{\"é\"}}") is Err(_))
  assert_true(load_text("{{\"\\u00ff\"}}") is Err(_))
  assert_true(load_text("{{\"a\" \"b\"}}") is Err(_))
}

///|
test "mail regression sexp separators" {
  assert_eq(dumps_text(sexp_sample()), "('+' 1 ('*' 2 3))")
  assert_true(load_text("(1,2)") is Err(_))
  assert_true(load_text("[1 2]") is Err(_))
  assert_true(load_text("{a:1 b:2}") is Err(_))
}

///|
test "mail regression local symbol table append reset null slots" {
  assert_eq(
    roundtrip_text("$ion_symbol_table::{symbols:[\"a\",null,\"b\"]} $12"),
    Ok("$ion_1_0\nb\n"),
  )
  assert_true(
    load_text("$ion_symbol_table::{symbols:[\"a\",null,\"b\"]} $11") is Err(_),
  )
  assert_eq(
    roundtrip_text(
      "$ion_symbol_table::{symbols:[\"a\"]} $ion_symbol_table::{imports:$ion_symbol_table,symbols:[\"b\"]} {$10:$11}",
    ),
    Ok("$ion_1_0\n{a: b}\n"),
  )
  assert_true(
    load_text("$ion_symbol_table::{symbols:[\"a\"]} $ion_1_0 $10") is Err(_),
  )
  assert_eq(
    roundtrip_text("other::$ion_symbol_table::1"),
    Ok("$ion_1_0\nother::$ion_symbol_table::1\n"),
  )
  assert_eq(
    roundtrip_text("$ion_symbol_table::1"),
    Ok("$ion_1_0\n$ion_symbol_table::1\n"),
  )
}

///|
test "caller provided shared symbol catalog" {
  let catalog : Array[SharedSymbolTable] = [
    { name: "shared", version: 1, symbols: [Some("a"), None, Some("b")], },
  ]
  let text = "$ion_symbol_table::{imports:[{name:\"shared\",version:1,max_id:3}],symbols:[\"local\"]} {$10:$12, $13:1}"
  let v = match load_text(text, catalog~) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(v), "{a: b, local: 1}")
  assert_eq(load_binary(dumps_binary(v)), Ok(v))
  assert_true(load_text(text) is Err(_))
}

///|
test "malformed binary cannot consume next value as its payload" {
  for
    hex in [
      "e00100ea52", "e00100ea520101", "e00100eab1528101", "e00100eae3808320", "e00100eae481ff20",
      "e00100eaf0", "e00100eaef", "e00100ea6e81808080808080808080", "e00100ea8e7fffffffffffffffffff",
      "e00100ea41ff", "e00100ea82c080", "e00100ea83eda080",
    ] {
    let data = match hex_decode(hex) {
      Ok(v) => v
      Err(e) => fail(e.message())
    }
    assert_true(loads_binary(data) is Err(_), msg=hex)
  }
}

///|
test "NOP padding is ignored at stream and container boundaries" {
  let data = match hex_decode("e00100ea010020b3000020d487008720") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(binary_to_text(data), Ok("$ion_1_0\n0\n[0]\n{symbols: 0}\n"))
}

///|
test "VarUInt and VarInt boundary bytes" {
  for
    (n, hex) in [
      (0, "80"),
      (1, "81"),
      (127, "ff"),
      (128, "0180"),
      (16383, "7fff"),
      (16384, "010080"),
    ] {
    let out : Array[Byte] = []
    write_varuint(out, n)
    assert_eq(hex_encode(Bytes::from_array(out)), hex)
  }
  for
    (n, hex) in [
      (0, "80"),
      (1, "81"),
      (-1, "c1"),
      (63, "bf"),
      (64, "00c0"),
      (-64, "40c0"),
      (2147483647, "077f7f7fff"),
      (-2147483648, "4800000080"),
    ] {
    let out : Array[Byte] = []
    write_varint(out, n)
    assert_eq(hex_encode(Bytes::from_array(out)), hex)
  }
}

///|
test "negative float zero and Int64 minimum survive binary" {
  let n = bigint_from_int64(-9223372036854775808L)
  assert_eq(n.to_decimal_string(), "-9223372036854775808")
  assert_eq(n.to_int64(), Some(-9223372036854775808L))
  let original = ion_float(-0.0)
  let restored = match load_binary(dumps_binary(original)) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  match restored.datum {
    FloatD(v) => assert_eq(hex_encode(f64_to_be_bytes(v)), "8000000000000000")
    _ => fail("float type lost")
  }
}

///|
test "invalid base64 padding and numeric grammar" {
  for
    text in [
      "{{=AAA}}", "{{A=AA}}", "{{AA=A}}", "{{A===}}", "{{AA==AAAA}}", "{{AB==}}",
      "{{AAB=}}", "1d", "1d+", "1__2", "1_", "0x1__2", "0b1__0", "+1", "01", "1foo",
      "[1foo]", "[0x1g]", "2026-10-14T08:30z", "2026-10-14t08:30Z", "\"\\q\"", "\"\\uD800\"",
      "\"\\U00110000\"",
    ] {
    assert_true(load_text(text) is Err(_), msg=text)
  }
}

///|
test "nesting limit returns error instead of unbounded recursion" {
  let s = StringBuilder()
  for i = 0; i < 260; i = i + 1 {
    s.write_string("[")
  }
  s.write_string("0")
  for i = 0; i < 260; i = i + 1 {
    s.write_string("]")
  }
  assert_true(load_text(s.to_string()) is Err(_))
}

///|
test "short binary input exhaustive panic smoke check" {
  // Includes malformed descriptors and short payloads. Results may be Ok or Err,
  // but neither public reader is allowed to panic on these 65,536 byte pairs.
  for a = 0; a < 256; a = a + 1 {
    for b = 0; b < 256; b = b + 1 {
      let _ = loads_binary(
        Bytes::from_array([0xe0, 1, 0, 0xea, a.to_byte(), b.to_byte()]),
      )
    }
  }
}

///|
test "official shared symbol table binary import" {
  let catalog : Array[SharedSymbolTable] = [
    { name: "shared", version: 1, symbols: [Some("a"), None, Some("b")], },
  ]
  let data = match
    hex_decode(
      "e00100eaee9f8183de9b86be90de8e848673686172656485210188210387b6856c6f63616cde868a710c8d2101",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let v = match load_binary(data, catalog~) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(v), "{a: b, local: 1}")
  assert_true(load_binary(data) is Err(_))
  assert_eq(load_bytes(data, catalog~), Ok(v))
}

///|
test "truncation of every official single value fixture" {
  let fixtures : Array[String] = [
    "e00100ea0f", "e00100ea1f", "e00100ea11", "e00100ea10", "e00100ea2f", "e00100ea4f",
    "e00100ea5f", "e00100ea6f", "e00100ea7f", "e00100ea8f", "e00100ea9f", "e00100eaaf",
    "e00100eabf", "e00100eacf", "e00100eadf", "e00100ea20", "e00100ea3101", "e00100ea217f",
    "e00100ea2180", "e00100ea21ff", "e00100ea220100", "e00100ea388000000000000000",
    "e00100ea287fffffffffffffff", "e00100ea2d018ee90ff6c373e0ee4e3f0ad2", "e00100ea3d018ee90ff6c373e0ee4e3f0ad2",
    "e00100ea528001", "e00100ea538000c8", "e00100ea538080c8", "e00100ea53800080",
    "e00100ea53808080", "e00100ea51c2", "e00100ea52c280", "e00100ea54c412d644", "e00100ea5300c001",
    "e00100ea5340c001", "e00100ea5300ff01", "e00100ea5340ff01", "e00100ea53018001",
    "e00100ea53418001", "e00100ea483ff0000000000000", "e00100ea488000000000000000",
    "e00100ea483ff4000000000000", "e00100ea487ff8000000000000", "e00100ea487ff0000000000000",
    "e00100ea48fff0000000000000", "e00100ea63c00fea", "e00100ea64c00fea8a", "e00100ea65c00fea8a8e",
    "e00100ea67800fea8a8e889e", "e00100ea67c00fea8a8e889e", "e00100ea6a800fea8a8e889e80c301",
    "e00100ea6a800fea8a8e889e80c464", "e00100ea69800fea8a8e889e80c3", "e00100ea6903e00fe98c9f908f80",
    "e00100ea68bc0fe8829d978080", "e00100ea6940f80feb8181819e80", "e00100ea8568656c6c6f",
    "e00100ea8ce4b8ade69687e6b58be8af95", "e00100ea86cebbf09f9880", "e00100eaeb8183de8787b58474727565710a",
    "e00100eaec8183de8887b68566616c7365710a", "e00100eaeb8183de8787b5846e756c6c710a",
    "e00100eaea8183de8687b4836e616e710a", "e00100eaea8183de8687b483243130710a", "e00100eaee908183de8c87ba89686173207370616365710a",
    "e00100eaee8e8183de8a87b887636174616c6f67710a", "e00100eaee908183de8c87ba83616e6e8576616c7565e4818a710b",
    "e00100eaeea98183dea587bea2856669727374867365636f6e6483666f6f8362617284686f6d65876b69746368656eee91828a8bde8c8c21018c21028db4710e710f",
    "e00100eab0", "e00100ead0", "e00100eac0", "e00100eae88183de8487b28178b92101110fde838a2102",
    "e00100eaea8183de8687b4812b812acb710a2101c6710b21022103", "e00100ea93ff0080",
    "e00100eaa200ff", "e00100eaa0", "e00100eaec8183de8887b6856f74686572e5828a832101",
    "e00100ea8e02ac787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878",
    "e00100eabe028320210121022103210421052106210721082109210a210b210c210d210e210f2110211121122113211421152116211721182119211a211b211c211d211e211f2120212121222123212421252126212721282129212a212b212c212d212e212f2130213121322133213421352136213721382139213a213b213c213d213e213f2140214121422143214421452146214721482149214a214b214c214d214e214f2150215121522153215421552156215721582159215a215b215c215d215e215f2160216121622163216421652166216721682169216a216b216c216d216e216f2170217121722173217421752176217721782179217a217b217c217d217e217f21802181",
    "e00100eaee08ad8183de08a887be08a4866669656c6430866669656c6431866669656c6432866669656c6433866669656c6434866669656c6435866669656c6436866669656c6437866669656c6438866669656c6439876669656c643130876669656c643131876669656c643132876669656c643133876669656c643134876669656c643135876669656c643136876669656c643137876669656c643138876669656c643139876669656c643230876669656c643231876669656c643232876669656c643233876669656c643234876669656c643235876669656c643236876669656c643237876669656c643238876669656c643239876669656c643330876669656c643331876669656c643332876669656c643333876669656c643334876669656c643335876669656c643336876669656c643337876669656c643338876669656c643339876669656c643430876669656c643431876669656c643432876669656c643433876669656c643434876669656c643435876669656c643436876669656c643437876669656c643438876669656c643439876669656c643530876669656c643531876669656c643532876669656c643533876669656c643534876669656c643535876669656c643536876669656c643537876669656c643538876669656c643539876669656c643630876669656c643631876669656c643632876669656c643633876669656c643634876669656c643635876669656c643636876669656c643637876669656c643638876669656c643639876669656c643730876669656c643731876669656c643732876669656c643733876669656c643734876669656c643735876669656c643736876669656c643737876669656c643738876669656c643739876669656c643830876669656c643831876669656c643832876669656c643833876669656c643834876669656c643835876669656c643836876669656c643837876669656c643838876669656c643839876669656c643930876669656c643931876669656c643932876669656c643933876669656c643934876669656c643935876669656c643936876669656c643937876669656c643938876669656c643939886669656c64313030886669656c64313031886669656c64313032886669656c64313033886669656c64313034886669656c64313035886669656c64313036886669656c64313037886669656c64313038886669656c64313039886669656c64313130886669656c64313131886669656c64313132886669656c64313133886669656c64313134886669656c64313135886669656c64313136886669656c64313137886669656c64313138886669656c64313139886669656c64313230886669656c64313231886669656c64313232886669656c64313233886669656c64313234886669656c64313235886669656c64313236886669656c64313237886669656c64313238886669656c64313239de03918a208b21018c21028d21038e21048f210590210691210792210893210994210a95210b96210c97210d98210e99210f9a21109b21119c21129d21139e21149f2115a02116a12117a22118a32119a4211aa5211ba6211ca7211da8211ea9211faa2120ab2121ac2122ad2123ae2124af2125b02126b12127b22128b32129b4212ab5212bb6212cb7212db8212eb9212fba2130bb2131bc2132bd2133be2134bf2135c02136c12137c22138c32139c4213ac5213bc6213cc7213dc8213ec9213fca2140cb2141cc2142cd2143ce2144cf2145d02146d12147d22148d32149d4214ad5214bd6214cd7214dd8214ed9214fda2150db2151dc2152dd2153de2154df2155e02156e12157e22158e32159e4215ae5215be6215ce7215de8215ee9215fea2160eb2161ec2162ed2163ee2164ef2165f02166f12167f22168f32169f4216af5216bf6216cf7216df8216ef9216ffa2170fb2171fc2172fd2173fe2174ff2175018021760181217701822178018321790184217a0185217b0186217c0187217d0188217e0189217f018a2180018b2181",
    "e00100ea9e0280000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff",
    "e00100ea483fb999999999999a", "e00100ea483ff3c0ca428c59fb", "e00100ea487fefffffffffffff",
    "e00100ea480000000000000001", "e00100ea480010000000000000", "e00100ea48966e3d71f622be94",
    "e00100ea8e916c696e65206f6e650a6c696e652074776f", "e00100ea826162", "e00100ea9261ff",
    "e00100ea826162", "e00100eaea8183de8687b483696e66710a", "e00100eae78183de8387b180e4818a2101",
    "e00100eaeb8183de8787b58474727565de838a2101", "e00100eaec8183de8887b6856669656c64de838a2101",
    "e00100ea926162", "e00100ea6e8f800fea8a8e889e80cd011f71fb04cb",
  ]
  for hex in fixtures {
    let data = match hex_decode(hex) {
      Ok(v) => bytes_to_array(v)
      Err(e) => fail(e.message())
    }
    for end = 0; end < data.length(); end = end + 1 {
      // A complete BVM or LST alone is a legal empty stream, not a value.
      match loads_binary(slice_bytes(data, 0, end)) {
        Ok(values) => assert_eq(values.length(), 0)
        Err(_) => ()
      }
    }
  }
}

///|
test "self delimiting stream values and quoted version marker" {
  assert_eq(
    loads_text("\"a\"\"b\"[]{}"),
    Ok([ion_string("a"), ion_string("b"), ion_list([]), ion_struct([])]),
  )
  assert_eq(loads_text("'$ion_1_0' 1 $ion_1_0 2"), Ok([ion_int(1), ion_int(2)]))
  assert_true(load_text("$0") is Err(_))
}

///|
test "direct decimal API rejects non-Ion number spelling" {
  for
    text in [
      ".1", "+1d0", "01d0", "1d", "1d+", "1d2147483648", "1.0d-2147483648",
    ] {
    assert_true(parse_decimal_text(text) is Err(_), msg=text)
  }
  assert_true(load_text("null .int") is Err(_))
  assert_true(load_text("null /* gap */ .int") is Err(_))
}

///|
test "Ion keywords are not bare field names or annotations" {
  for
    text in [
      "true::1", "false::1", "null::1", "nan::1", "{true:1}", "{nan:1}", "$ion_1_1",
    ] {
    assert_true(load_text(text) is Err(_), msg=text)
  }
  assert_eq(load_text("inf"), Ok(ion_symbol("inf")))
  assert_eq(load_text("''::1"), Ok(ion_int(1).with_annotation("")))
}

///|
test "unknown SID in padded struct is ignored and overflows fail" {
  let data = match hex_decode("e00100ead28000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(load_binary(data), Ok(ion_struct([])))
  for
    hex in [
      "e00100ea8e1000000080", "e00100ea75ff00000001", "e00100ea7480000000", "e00100eae781100000008020",
      "e00100ea70", "e00100ea6b808fffffffffffffffffff",
    ] {
    let raw = match hex_decode(hex) {
      Ok(v) => v
      Err(e) => fail(e.message())
    }
    assert_true(loads_binary(raw) is Err(_), msg=hex)
  }
}
