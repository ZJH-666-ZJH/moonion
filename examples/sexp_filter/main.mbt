///|
fn main {
  match @ion.load("(+ 1 (* 2 3))") {
    Ok(v) => {
      println(@ion.dumps(v))
      match v.datum {
        @ion.SexpD(items) => println("ops=" + items.length().to_string())
        _ => println("not sexp")
      }
    }
    Err(e) => println("error=" + e.message())
  }
}
