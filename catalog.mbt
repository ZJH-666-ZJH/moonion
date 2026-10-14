///|
// A catalog is supplied by the caller; no network lookup occurs during decoding.
pub(all) struct SharedSymbolTable {
  name : String
  version : Int32
  symbols : Array[String?]
} derive(Eq, Debug)

///|
pub extend SharedSymbolTable with Eq::{equal, not_equal}

///|
pub extend SharedSymbolTable with @debug.Debug::{to_repr}

///|
fn apply_local_table(
  table : SymbolTable,
  value : IonValue,
  catalog : Array[SharedSymbolTable],
) -> Result[Unit, IonError] {
  // Duplicate reserved fields make a local symbol table ambiguous.
  match value.datum {
    StructD(fields) => {
      let mut seen_symbols = false
      let mut seen_imports = false
      for f in fields {
        if f.name == "symbols" {
          if seen_symbols {
            return Err(InvalidSymbol("duplicate symbols"))
          }
          seen_symbols = true
        }
        if f.name == "imports" {
          if seen_imports {
            return Err(InvalidSymbol("duplicate imports"))
          }
          seen_imports = true
        }
      }
    }
    _ => return Err(InvalidSymbol("symbol table must be a struct"))
  }
  let imports = value.field("imports")
  let append = match imports {
    Some({ datum: SymbolD(s), .. }) => s == "$ion_symbol_table"
    _ => false
  }
  if !append {
    table.reset_locals()
  }
  if !append {
    match imports {
      Some({ datum: ListD(items), .. }) =>
        for item in items {
          if item.is_null() {
            continue
          }
          let name = match item.field("name") {
            Some({ datum: StringD(s), .. }) => s
            _ => continue
          }
          if name == "" || name == "$ion" {
            continue
          }
          let version = match item.field("version") {
            Some({ datum: IntD(n), .. }) =>
              match n.to_int64() {
                Some(v) =>
                  if v > 0L && v <= 2147483647L {
                    v.to_int()
                  } else {
                    1
                  }
                None => 1
              }
            _ => 1
          }
          let mut shared : SharedSymbolTable? = None
          for entry in catalog {
            if entry.name == name && entry.version == version {
              shared = Some(entry)
            }
          }
          let max_id = match item.field("max_id") {
            Some({ datum: IntD(n), .. }) =>
              match n.to_int64() {
                Some(v) =>
                  if v >= 0L && v <= 1000000L {
                    v.to_int()
                  } else {
                    return Err(InvalidSymbol("invalid import max_id"))
                  }
                None => return Err(InvalidSymbol("invalid import max_id"))
              }
            _ =>
              match shared {
                Some(entry) => entry.symbols.length()
                None =>
                  return Err(InvalidSymbol("import requires catalog or max_id"))
              }
          }
          if max_id > 1000000 - table.locals.length() {
            return Err(InvalidSymbol("symbol table limit exceeded"))
          }
          for i = 0; i < max_id; i = i + 1 {
            let slot = match shared {
              Some(entry) =>
                if i < entry.symbols.length() {
                  entry.symbols[i]
                } else {
                  None
                }
              None => None
            }
            table.locals.push(slot)
          }
        }
      _ => ()
    }
  }
  match value.field("symbols") {
    Some({ datum: ListD(items), .. }) =>
      for item in items {
        if table.locals.length() >= 1000000 {
          return Err(InvalidSymbol("symbol table limit exceeded"))
        }
        table.locals.push(
          match item.datum {
            StringD(s) => Some(s)
            _ => None
          },
        )
      }
    _ => ()
  }
  Ok(())
}
