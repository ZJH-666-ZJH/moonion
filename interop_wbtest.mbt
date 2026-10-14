///|
test "official ion-python fixture 0" {
  let data = match hex_decode("e00100ea0f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 1" {
  let data = match hex_decode("e00100ea1f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.bool") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 2" {
  let data = match hex_decode("e00100ea11") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("true") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 3" {
  let data = match hex_decode("e00100ea10") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("false") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 4" {
  let data = match hex_decode("e00100ea2f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.int") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 5" {
  let data = match hex_decode("e00100ea4f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.float") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 6" {
  let data = match hex_decode("e00100ea5f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.decimal") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 7" {
  let data = match hex_decode("e00100ea6f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.timestamp") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 8" {
  let data = match hex_decode("e00100ea7f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.symbol") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 9" {
  let data = match hex_decode("e00100ea8f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.string") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 10" {
  let data = match hex_decode("e00100ea9f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.clob") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 11" {
  let data = match hex_decode("e00100eaaf") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.blob") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 12" {
  let data = match hex_decode("e00100eabf") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.list") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 13" {
  let data = match hex_decode("e00100eacf") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.sexp") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 14" {
  let data = match hex_decode("e00100eadf") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("null.struct") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 15" {
  let data = match hex_decode("e00100ea20") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 16" {
  let data = match hex_decode("e00100ea3101") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-1") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 17" {
  let data = match hex_decode("e00100ea217f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("127") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 18" {
  let data = match hex_decode("e00100ea2180") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("128") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 19" {
  let data = match hex_decode("e00100ea21ff") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("255") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 20" {
  let data = match hex_decode("e00100ea220100") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("256") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 21" {
  let data = match hex_decode("e00100ea388000000000000000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-9223372036854775808") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 22" {
  let data = match hex_decode("e00100ea287fffffffffffffff") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("9223372036854775807") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 23" {
  let data = match hex_decode("e00100ea2d018ee90ff6c373e0ee4e3f0ad2") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("123456789012345678901234567890") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 24" {
  let data = match hex_decode("e00100ea3d018ee90ff6c373e0ee4e3f0ad2") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-123456789012345678901234567890") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 25" {
  let data = match hex_decode("e00100ea528001") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1d0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 26" {
  let data = match hex_decode("e00100ea538000c8") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("200d0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 27" {
  let data = match hex_decode("e00100ea538080c8") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-200d0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 28" {
  let data = match hex_decode("e00100ea53800080") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("128d0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 29" {
  let data = match hex_decode("e00100ea53808080") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-128d0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 30" {
  let data = match hex_decode("e00100ea51c2") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("0d-2") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 31" {
  let data = match hex_decode("e00100ea52c280") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-0d-2") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 32" {
  let data = match hex_decode("e00100ea54c412d644") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("123.4500") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 33" {
  let data = match hex_decode("e00100ea5300c001") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1d64") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 34" {
  let data = match hex_decode("e00100ea5340c001") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1d-64") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 35" {
  let data = match hex_decode("e00100ea5300ff01") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1d127") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 36" {
  let data = match hex_decode("e00100ea5340ff01") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1d-127") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 37" {
  let data = match hex_decode("e00100ea53018001") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1d128") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 38" {
  let data = match hex_decode("e00100ea53418001") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1d-128") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 39" {
  let data = match hex_decode("e00100ea483ff0000000000000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1e0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 40" {
  let data = match hex_decode("e00100ea488000000000000000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-0e0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 41" {
  let data = match hex_decode("e00100ea483ff4000000000000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1.25e0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 42" {
  let data = match hex_decode("e00100ea487ff8000000000000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("nan") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 43" {
  let data = match hex_decode("e00100ea487ff0000000000000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("+inf") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 44" {
  let data = match hex_decode("e00100ea48fff0000000000000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-inf") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 45" {
  let data = match hex_decode("e00100ea63c00fea") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026T") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 46" {
  let data = match hex_decode("e00100ea64c00fea8a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-10T") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 47" {
  let data = match hex_decode("e00100ea65c00fea8a8e") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-10-14") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 48" {
  let data = match hex_decode("e00100ea67800fea8a8e889e") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-10-14T08:30Z") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 49" {
  let data = match hex_decode("e00100ea67c00fea8a8e889e") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-10-14T08:30-00:00") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 50" {
  let data = match hex_decode("e00100ea6a800fea8a8e889e80c301") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-10-14T08:30:00.001Z") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 51" {
  let data = match hex_decode("e00100ea6a800fea8a8e889e80c464") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-10-14T08:30:00.0100Z") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 52" {
  let data = match hex_decode("e00100ea69800fea8a8e889e80c3") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-10-14T08:30:00.000Z") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 53" {
  let data = match hex_decode("e00100ea6903e00fe98c9f908f80") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-01-01T00:15:00+08:00") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 54" {
  let data = match hex_decode("e00100ea68bc0fe8829d978080") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2024-03-01T00:00:00+01:00") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 55" {
  let data = match hex_decode("e00100ea6940f80feb8181819e80") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-12-31T23:30:00-02:00") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 56" {
  let data = match hex_decode("e00100ea8568656c6c6f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("\"hello\"") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 57" {
  let data = match hex_decode("e00100ea8ce4b8ade69687e6b58be8af95") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("\"中文测试\"") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 58" {
  let data = match hex_decode("e00100ea86cebbf09f9880") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("\"\\u03bb\\U0001f600\"") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 59" {
  let data = match hex_decode("e00100eaeb8183de8787b58474727565710a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("'true'") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 60" {
  let data = match hex_decode("e00100eaec8183de8887b68566616c7365710a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("'false'") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 61" {
  let data = match hex_decode("e00100eaeb8183de8787b5846e756c6c710a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("'null'") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 62" {
  let data = match hex_decode("e00100eaea8183de8687b4836e616e710a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("'nan'") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 63" {
  let data = match hex_decode("e00100eaea8183de8687b483243130710a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("'$10'") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 64" {
  let data = match
    hex_decode("e00100eaee908183de8c87ba89686173207370616365710a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("'has space'") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 65" {
  let data = match hex_decode("e00100eaee8e8183de8a87b887636174616c6f67710a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("catalog") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 66" {
  let data = match
    hex_decode("e00100eaee908183de8c87ba83616e6e8576616c7565e4818a710b") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("ann::value") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 67" {
  let data = match
    hex_decode(
      "e00100eaeea98183dea587bea2856669727374867365636f6e6483666f6f8362617284686f6d65876b69746368656eee91828a8bde8c8c21018c21028db4710e710f",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match
    load_text("first::second::{foo:1,foo:2,bar: [home,kitchen]}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 68" {
  let data = match hex_decode("e00100eab0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("[]") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 69" {
  let data = match hex_decode("e00100ead0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("{}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 70" {
  let data = match hex_decode("e00100eac0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("()") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 71" {
  let data = match
    hex_decode("e00100eae88183de8487b28178b92101110fde838a2102") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("[1, true, null, {x:2}]") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 72" {
  let data = match
    hex_decode("e00100eaea8183de8687b4812b812acb710a2101c6710b21022103") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("(+ 1 (* 2 3))") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 73" {
  let data = match hex_decode("e00100ea93ff0080") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("{{\"\\xFF\\x00\\x80\"}}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 74" {
  let data = match hex_decode("e00100eaa200ff") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("{{AP8=}}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 75" {
  let data = match hex_decode("e00100eaa0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("{{}}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 76" {
  let data = match
    hex_decode("e00100eaec8183de8887b6856f74686572e5828a832101") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("other::$ion_symbol_table::1") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 77" {
  let data = match
    hex_decode(
      "e00100ea8e02ac787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878787878",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match
    load_text(
      "\"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\"",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 78" {
  let data = match
    hex_decode(
      "e00100eabe028320210121022103210421052106210721082109210a210b210c210d210e210f2110211121122113211421152116211721182119211a211b211c211d211e211f2120212121222123212421252126212721282129212a212b212c212d212e212f2130213121322133213421352136213721382139213a213b213c213d213e213f2140214121422143214421452146214721482149214a214b214c214d214e214f2150215121522153215421552156215721582159215a215b215c215d215e215f2160216121622163216421652166216721682169216a216b216c216d216e216f2170217121722173217421752176217721782179217a217b217c217d217e217f21802181",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match
    load_text(
      "[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129]",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 79" {
  let data = match
    hex_decode(
      "e00100eaee08ad8183de08a887be08a4866669656c6430866669656c6431866669656c6432866669656c6433866669656c6434866669656c6435866669656c6436866669656c6437866669656c6438866669656c6439876669656c643130876669656c643131876669656c643132876669656c643133876669656c643134876669656c643135876669656c643136876669656c643137876669656c643138876669656c643139876669656c643230876669656c643231876669656c643232876669656c643233876669656c643234876669656c643235876669656c643236876669656c643237876669656c643238876669656c643239876669656c643330876669656c643331876669656c643332876669656c643333876669656c643334876669656c643335876669656c643336876669656c643337876669656c643338876669656c643339876669656c643430876669656c643431876669656c643432876669656c643433876669656c643434876669656c643435876669656c643436876669656c643437876669656c643438876669656c643439876669656c643530876669656c643531876669656c643532876669656c643533876669656c643534876669656c643535876669656c643536876669656c643537876669656c643538876669656c643539876669656c643630876669656c643631876669656c643632876669656c643633876669656c643634876669656c643635876669656c643636876669656c643637876669656c643638876669656c643639876669656c643730876669656c643731876669656c643732876669656c643733876669656c643734876669656c643735876669656c643736876669656c643737876669656c643738876669656c643739876669656c643830876669656c643831876669656c643832876669656c643833876669656c643834876669656c643835876669656c643836876669656c643837876669656c643838876669656c643839876669656c643930876669656c643931876669656c643932876669656c643933876669656c643934876669656c643935876669656c643936876669656c643937876669656c643938876669656c643939886669656c64313030886669656c64313031886669656c64313032886669656c64313033886669656c64313034886669656c64313035886669656c64313036886669656c64313037886669656c64313038886669656c64313039886669656c64313130886669656c64313131886669656c64313132886669656c64313133886669656c64313134886669656c64313135886669656c64313136886669656c64313137886669656c64313138886669656c64313139886669656c64313230886669656c64313231886669656c64313232886669656c64313233886669656c64313234886669656c64313235886669656c64313236886669656c64313237886669656c64313238886669656c64313239de03918a208b21018c21028d21038e21048f210590210691210792210893210994210a95210b96210c97210d98210e99210f9a21109b21119c21129d21139e21149f2115a02116a12117a22118a32119a4211aa5211ba6211ca7211da8211ea9211faa2120ab2121ac2122ad2123ae2124af2125b02126b12127b22128b32129b4212ab5212bb6212cb7212db8212eb9212fba2130bb2131bc2132bd2133be2134bf2135c02136c12137c22138c32139c4213ac5213bc6213cc7213dc8213ec9213fca2140cb2141cc2142cd2143ce2144cf2145d02146d12147d22148d32149d4214ad5214bd6214cd7214dd8214ed9214fda2150db2151dc2152dd2153de2154df2155e02156e12157e22158e32159e4215ae5215be6215ce7215de8215ee9215fea2160eb2161ec2162ed2163ee2164ef2165f02166f12167f22168f32169f4216af5216bf6216cf7216df8216ef9216ffa2170fb2171fc2172fd2173fe2174ff2175018021760181217701822178018321790184217a0185217b0186217c0187217d0188217e0189217f018a2180018b2181",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match
    load_text(
      "{field0:0,field1:1,field2:2,field3:3,field4:4,field5:5,field6:6,field7:7,field8:8,field9:9,field10:10,field11:11,field12:12,field13:13,field14:14,field15:15,field16:16,field17:17,field18:18,field19:19,field20:20,field21:21,field22:22,field23:23,field24:24,field25:25,field26:26,field27:27,field28:28,field29:29,field30:30,field31:31,field32:32,field33:33,field34:34,field35:35,field36:36,field37:37,field38:38,field39:39,field40:40,field41:41,field42:42,field43:43,field44:44,field45:45,field46:46,field47:47,field48:48,field49:49,field50:50,field51:51,field52:52,field53:53,field54:54,field55:55,field56:56,field57:57,field58:58,field59:59,field60:60,field61:61,field62:62,field63:63,field64:64,field65:65,field66:66,field67:67,field68:68,field69:69,field70:70,field71:71,field72:72,field73:73,field74:74,field75:75,field76:76,field77:77,field78:78,field79:79,field80:80,field81:81,field82:82,field83:83,field84:84,field85:85,field86:86,field87:87,field88:88,field89:89,field90:90,field91:91,field92:92,field93:93,field94:94,field95:95,field96:96,field97:97,field98:98,field99:99,field100:100,field101:101,field102:102,field103:103,field104:104,field105:105,field106:106,field107:107,field108:108,field109:109,field110:110,field111:111,field112:112,field113:113,field114:114,field115:115,field116:116,field117:117,field118:118,field119:119,field120:120,field121:121,field122:122,field123:123,field124:124,field125:125,field126:126,field127:127,field128:128,field129:129}",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 80" {
  let data = match
    hex_decode(
      "e00100ea9e0280000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match
    load_text(
      "{{\"\\x00\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0a\\x0b\\x0c\\x0d\\x0e\\x0f\\x10\\x11\\x12\\x13\\x14\\x15\\x16\\x17\\x18\\x19\\x1a\\x1b\\x1c\\x1d\\x1e\\x1f\\x20\\x21\\x22\\x23\\x24\\x25\\x26\\x27\\x28\\x29\\x2a\\x2b\\x2c\\x2d\\x2e\\x2f\\x30\\x31\\x32\\x33\\x34\\x35\\x36\\x37\\x38\\x39\\x3a\\x3b\\x3c\\x3d\\x3e\\x3f\\x40\\x41\\x42\\x43\\x44\\x45\\x46\\x47\\x48\\x49\\x4a\\x4b\\x4c\\x4d\\x4e\\x4f\\x50\\x51\\x52\\x53\\x54\\x55\\x56\\x57\\x58\\x59\\x5a\\x5b\\x5c\\x5d\\x5e\\x5f\\x60\\x61\\x62\\x63\\x64\\x65\\x66\\x67\\x68\\x69\\x6a\\x6b\\x6c\\x6d\\x6e\\x6f\\x70\\x71\\x72\\x73\\x74\\x75\\x76\\x77\\x78\\x79\\x7a\\x7b\\x7c\\x7d\\x7e\\x7f\\x80\\x81\\x82\\x83\\x84\\x85\\x86\\x87\\x88\\x89\\x8a\\x8b\\x8c\\x8d\\x8e\\x8f\\x90\\x91\\x92\\x93\\x94\\x95\\x96\\x97\\x98\\x99\\x9a\\x9b\\x9c\\x9d\\x9e\\x9f\\xa0\\xa1\\xa2\\xa3\\xa4\\xa5\\xa6\\xa7\\xa8\\xa9\\xaa\\xab\\xac\\xad\\xae\\xaf\\xb0\\xb1\\xb2\\xb3\\xb4\\xb5\\xb6\\xb7\\xb8\\xb9\\xba\\xbb\\xbc\\xbd\\xbe\\xbf\\xc0\\xc1\\xc2\\xc3\\xc4\\xc5\\xc6\\xc7\\xc8\\xc9\\xca\\xcb\\xcc\\xcd\\xce\\xcf\\xd0\\xd1\\xd2\\xd3\\xd4\\xd5\\xd6\\xd7\\xd8\\xd9\\xda\\xdb\\xdc\\xdd\\xde\\xdf\\xe0\\xe1\\xe2\\xe3\\xe4\\xe5\\xe6\\xe7\\xe8\\xe9\\xea\\xeb\\xec\\xed\\xee\\xef\\xf0\\xf1\\xf2\\xf3\\xf4\\xf5\\xf6\\xf7\\xf8\\xf9\\xfa\\xfb\\xfc\\xfd\\xfe\\xff\"}}",
    ) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 81" {
  let data = match hex_decode("e00100ea483fb999999999999a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("0.1e0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 82" {
  let data = match hex_decode("e00100ea483ff3c0ca428c59fb") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1.2345678901234567e0") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 83" {
  let data = match hex_decode("e00100ea487fefffffffffffff") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("1.7976931348623157e308") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 84" {
  let data = match hex_decode("e00100ea480000000000000001") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("5e-324") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 85" {
  let data = match hex_decode("e00100ea480010000000000000") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2.2250738585072014e-308") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 86" {
  let data = match hex_decode("e00100ea48966e3d71f622be94") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("-1.2345678901234567e-200") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 87" {
  let data = match
    hex_decode("e00100ea8e916c696e65206f6e650a6c696e652074776f") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("'''line one\nline two'''") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 88" {
  let data = match hex_decode("e00100ea826162") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("'''a''' /* joined */ '''b'''") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 89" {
  let data = match hex_decode("e00100ea9261ff") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("{{'''a\\xFF'''}}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 90" {
  let data = match hex_decode("e00100ea826162") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("\"a\\\nb\"") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 91" {
  let data = match hex_decode("e00100eaea8183de8687b483696e66710a") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("inf") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 92" {
  let data = match hex_decode("e00100eae78183de8387b180e4818a2101") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("''::1") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 93" {
  let data = match hex_decode("e00100eaeb8183de8787b58474727565de838a2101") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("{'true':1}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 94" {
  let data = match hex_decode("e00100eaec8183de8887b6856669656c64de838a2101") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("{'''field''':1}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 95" {
  let data = match hex_decode("e00100ea926162") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("{{'''a''' '''b'''}}") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}

///|
test "official ion-python fixture 96" {
  let data = match hex_decode("e00100ea6e8f800fea8a8e889e80cd011f71fb04cb") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let decoded = match load_binary(data) {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  let parsed = match load_text("2026-10-14T08:30:00.1234567890123Z") {
    Ok(v) => v
    Err(e) => fail(e.message())
  }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}
