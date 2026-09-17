///|
test "public loads dumps" {
  match @moonion.load("{ok: true, n: 7}") {
    Ok(v) => {
      assert_eq(v.ion_type(), @moonion.StructT)
      let text = @moonion.dumps(v)
      match @moonion.load(text) {
        Ok(again) =>
          match again.field("n") {
            Some(n) =>
              match n.as_int() {
                Some(i) => assert_eq(i.to_decimal_string(), "7")
                None => fail("n")
              }
            None => fail("missing n")
          }
        Err(e) => fail(e.message())
      }
    }
    Err(e) => fail(e.message())
  }
}

///|
test "public binary api" {
  let v = @moonion.ion_list([@moonion.ion_int(1), @moonion.ion_string("x")])
  let b = @moonion.dumps_bytes(v)
  match @moonion.load_bytes(b) {
    Ok(again) =>
      match again.as_list() {
        Some(xs) => assert_eq(xs.length(), 2)
        None => fail("list")
      }
    Err(e) => fail(e.message())
  }
}

///|
test "catalog sample public" {
  let p = @moonion.catalog_sample()
  assert_eq(p.annotations[0], "Product")
  match @moonion.load(@moonion.dumps(p)) {
    Ok(again) => assert_eq(again.annotations[0], "Product")
    Err(e) => fail(e.message())
  }
}
