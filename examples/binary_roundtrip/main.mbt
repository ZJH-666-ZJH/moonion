///|
fn main {
  let product = @ion.catalog_sample()
  let binary = @ion.dumps_bytes(product)
  println("bytes=" + binary.length().to_string())
  println("hex=" + @ion.hex_encode(binary))
  match @ion.load_bytes(binary) {
    Ok(v) => println("text=" + @ion.dumps(v))
    Err(e) => println("error=" + e.message())
  }
}
