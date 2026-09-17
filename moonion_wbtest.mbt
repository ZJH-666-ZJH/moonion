///|
test "ion version" {
  assert_eq(ion_version(), "1.0")
}

///|
test "text scalars" {
  match load_text("null") {
    Ok(v) => assert_eq(v.is_null(), true)
    Err(e) => fail(e.message())
  }
  match load_text("true") {
    Ok(v) => assert_eq(v.as_bool(), Some(true))
    Err(e) => fail(e.message())
  }
  match load_text("false") {
    Ok(v) => assert_eq(v.as_bool(), Some(false))
    Err(e) => fail(e.message())
  }
  match load_text("42") {
    Ok(v) =>
      match v.as_int() {
        Some(n) => assert_eq(n.to_decimal_string(), "42")
        None => fail("not int")
      }
    Err(e) => fail(e.message())
  }
  match load_text("-17") {
    Ok(v) =>
      match v.as_int() {
        Some(n) => assert_eq(n.to_decimal_string(), "-17")
        None => fail("not int")
      }
    Err(e) => fail(e.message())
  }
  match load_text("\"hello\"") {
    Ok(v) => assert_eq(v.as_string(), Some("hello"))
    Err(e) => fail(e.message())
  }
  match load_text("home") {
    Ok(v) => assert_eq(v.as_symbol(), Some("home"))
    Err(e) => fail(e.message())
  }
}

///|
test "text containers and annotations" {
  match
    load_text("Product::{ id: \"sku-42\", count: 3, tags: [home, kitchen] }") {
    Ok(v) => {
      assert_eq(v.annotations.length(), 1)
      assert_eq(v.annotations[0], "Product")
      match v.field("count") {
        Some(c) =>
          match c.as_int() {
            Some(n) => assert_eq(n.to_decimal_string(), "3")
            None => fail("count")
          }
        None => fail("missing count")
      }
    }
    Err(e) => fail(e.message())
  }
  match load_text("(+ 1 (* 2 3))") {
    Ok(v) =>
      match v.datum {
        SexpD(items) => assert_eq(items.length(), 3)
        _ => fail("not sexp")
      }
    Err(e) => fail(e.message())
  }
}

///|
test "decimal timestamp blob hex" {
  match load_text("12.50d-1") {
    Ok(v) =>
      match v.datum {
        DecimalD(d) => assert_eq(d.coefficient.to_decimal_string(), "1250")
        _ => fail("not decimal")
      }
    Err(e) => fail(e.message())
  }
  match load_text("2026-09-17T08:30:00Z") {
    Ok(v) =>
      match v.datum {
        TimestampD(ts) => {
          assert_eq(ts.year, 2026)
          assert_eq(ts.minute, 30)
        }
        _ => fail("not ts")
      }
    Err(e) => fail(e.message())
  }
  match load_text("0x2A") {
    Ok(v) =>
      match v.as_int() {
        Some(n) => assert_eq(n.to_decimal_string(), "42")
        None => fail("hex")
      }
    Err(e) => fail(e.message())
  }
  match load_text("{{aGVsbG8=}}") {
    Ok(v) =>
      match v.datum {
        BlobD(b) => assert_eq(hex_encode(b), "68656c6c6f")
        _ => fail("not blob")
      }
    Err(e) => fail(e.message())
  }
}

///|
test "text dumps roundtrip" {
  let original = catalog_sample()
  let text = dumps_text(original)
  match load_text(text) {
    Ok(again) => {
      assert_eq(again.annotations[0], "Product")
      match again.field("id") {
        Some(id) => assert_eq(id.as_string(), Some("sku-42"))
        None => fail("id")
      }
    }
    Err(e) => fail(e.message())
  }
}

///|
test "binary roundtrip struct" {
  let original = catalog_sample()
  let bytes = dumps_binary(original)
  match load_binary(bytes) {
    Ok(again) => {
      assert_eq(again.annotations[0], "Product")
      match again.field("active") {
        Some(v) => assert_eq(v.as_bool(), Some(true))
        None => fail("active")
      }
      match again.field("count") {
        Some(v) =>
          match v.as_int() {
            Some(n) => assert_eq(n.to_decimal_string(), "3")
            None => fail("count")
          }
        None => fail("count")
      }
    }
    Err(e) => fail(e.message())
  }
}

///|
test "binary rejects truncated" {
  match load_binary(Bytes::from_array([(224).to_byte()])) {
    Ok(_) => fail("expected error")
    Err(_) => ()
  }
}

///|
test "empty document" {
  match load_text("   ") {
    Ok(_) => fail("expected empty")
    Err(e) => assert_eq(e.code(), "ION013")
  }
}

///|
test "typed null and comments" {
  match load_text("// c\nnull.int") {
    Ok(v) =>
      match v.datum {
        NullD(t) => assert_eq(t, IntT)
        _ => fail("not null.int")
      }
    Err(e) => fail(e.message())
  }
}

///|
test "list and string escape" {
  match load_text("[1, 2, 3]") {
    Ok(v) =>
      match v.as_list() {
        Some(xs) => assert_eq(xs.length(), 3)
        None => fail("list")
      }
    Err(e) => fail(e.message())
  }
  match load_text("\"a\\nb\"") {
    Ok(v) => assert_eq(v.as_string(), Some("a\nb"))
    Err(e) => fail(e.message())
  }
}

///|
test "text to binary conversion" {
  match text_to_binary("{a: 1, b: false}") {
    Ok(bin) =>
      match load_binary(bin) {
        Ok(v) =>
          match v.field("a") {
            Some(n) =>
              match n.as_int() {
                Some(i) => assert_eq(i.to_decimal_string(), "1")
                None => fail("a")
              }
            None => fail("missing a")
          }
        Err(e) => fail(e.message())
      }
    Err(e) => fail(e.message())
  }
}

///|
test "bigint helpers" {
  let n = bigint_from_int64(255L)
  assert_eq(n.to_decimal_string(), "255")
  match bigint_from_decimal_string("1001") {
    Ok(v) => assert_eq(v.to_decimal_string(), "1001")
    Err(e) => fail(e.message())
  }
}

///|
test "error codes" {
  assert_eq(UnexpectedEof.code(), "ION001")
  assert_eq(InvalidUtf8.message().length() > 0, true)
}
