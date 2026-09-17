///|
fn main {
  let product = @ion.catalog_sample()
  let text = @ion.dumps_all([product, @ion.sexp_sample()])
  println(text)
  let binary = @ion.dumps_bytes_all([product])
  println("binary_hex=" + @ion.hex_encode(binary))
  match @ion.load(text) {
    Ok(v) => println("reload_type=" + v.ion_type().name())
    Err(e) => println("reload_error=" + e.message())
  }
}
