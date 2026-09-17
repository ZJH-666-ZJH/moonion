///|
pub const ION_VERSION : String = "1.0"

///|
pub fn ion_version() -> String {
  ION_VERSION
}

///|
pub fn loads(input : String) -> Result[Array[IonValue], IonError] {
  loads_text(input)
}

///|
pub fn load(input : String) -> Result[IonValue, IonError] {
  load_text(input)
}

///|
pub fn dumps(value : IonValue) -> String {
  dumps_text(value)
}

///|
pub fn dumps_all(values : Array[IonValue]) -> String {
  dumps_text_all(values)
}

///|
pub fn loads_bytes(data : Bytes) -> Result[Array[IonValue], IonError] {
  loads_binary(data)
}

///|
pub fn load_bytes(data : Bytes) -> Result[IonValue, IonError] {
  load_binary(data)
}

///|
pub fn dumps_bytes(value : IonValue) -> Bytes {
  dumps_binary(value)
}

///|
pub fn dumps_bytes_all(values : Array[IonValue]) -> Bytes {
  dumps_binary_all(values)
}

///|
pub fn text_to_binary(text : String) -> Result[Bytes, IonError] {
  match loads_text(text) {
    Ok(vs) => Ok(dumps_binary_all(vs))
    Err(e) => Err(e)
  }
}

///|
pub fn binary_to_text(data : Bytes) -> Result[String, IonError] {
  match loads_binary(data) {
    Ok(vs) => Ok(dumps_text_all(vs))
    Err(e) => Err(e)
  }
}

///|
pub fn roundtrip_text(text : String) -> Result[String, IonError] {
  match loads_text(text) {
    Ok(vs) => Ok(dumps_text_all(vs))
    Err(e) => Err(e)
  }
}

///|
pub fn roundtrip_binary(data : Bytes) -> Result[Bytes, IonError] {
  match loads_binary(data) {
    Ok(vs) => Ok(dumps_binary_all(vs))
    Err(e) => Err(e)
  }
}

///|
pub fn values_equal(a : IonValue, b : IonValue) -> Bool {
  dumps_text(a) == dumps_text(b)
}

///|
pub fn catalog_sample() -> IonValue {
  ion_struct([
    ion_field("id", ion_string("sku-42")),
    ion_field("name", ion_string("MoonBit mug")),
    ion_field(
      "price",
      ion_decimal(decimal_from_parts(bigint_from_int(1299), -2)),
    ),
    ion_field("tags", ion_list([ion_symbol("home"), ion_symbol("kitchen")])),
    ion_field(
      "created",
      match parse_timestamp_text("2026-09-17T08:30:00Z") {
        Ok(ts) => ion_timestamp(ts)
        Err(_) => ion_null(TimestampT)
      },
    ),
    ion_field("active", ion_bool(true)),
    ion_field("count", ion_int(3)),
  ]).with_annotation("Product")
}

///|
pub fn sexp_sample() -> IonValue {
  ion_sexp([
    ion_symbol("+"),
    ion_int(1),
    ion_sexp([ion_symbol("*"), ion_int(2), ion_int(3)]),
  ])
}
