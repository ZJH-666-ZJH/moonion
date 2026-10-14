///|
pub fn system_symbol_name(id : Int32) -> String? {
  match id {
    1 => Some("$ion")
    2 => Some("$ion_1_0")
    3 => Some("$ion_symbol_table")
    4 => Some("name")
    5 => Some("version")
    6 => Some("imports")
    7 => Some("symbols")
    8 => Some("max_id")
    9 => Some("$ion_shared_symbol_table")
    _ => None
  }
}

///|
pub fn system_symbol_id(name : String) -> Int32? {
  match name {
    "$ion" => Some(1)
    "$ion_1_0" => Some(2)
    "$ion_symbol_table" => Some(3)
    "name" => Some(4)
    "version" => Some(5)
    "imports" => Some(6)
    "symbols" => Some(7)
    "max_id" => Some(8)
    "$ion_shared_symbol_table" => Some(9)
    _ => None
  }
}

///|
pub fn system_max_id() -> Int32 {
  9
}

///|
pub(all) struct SymbolTable {
  locals : Array[String?]
}

///|
pub fn symbol_table_new() -> SymbolTable {
  { locals: [], }
}

///|
pub fn SymbolTable::intern(self : SymbolTable, name : String) -> Int32 {
  match system_symbol_id(name) {
    Some(id) => id
    None => {
      let mut found = -1
      let mut i = 0
      while i < self.locals.length() {
        if self.locals[i] == Some(name) {
          found = i
        }
        i += 1
      }
      if found >= 0 {
        system_max_id() + 1 + found
      } else {
        self.locals.push(Some(name))
        system_max_id() + self.locals.length()
      }
    }
  }
}

///|
pub fn SymbolTable::define_local(self : SymbolTable, name : String) -> Unit {
  self.locals.push(Some(name))
}

///|
pub fn SymbolTable::name_of(
  self : SymbolTable,
  id : Int32,
) -> Result[String, IonError] {
  if id == 0 {
    Err(InvalidSymbol("unresolved SID 0"))
  } else {
    match system_symbol_name(id) {
      Some(name) => Ok(name)
      None => {
        let idx = id - system_max_id() - 1
        if idx >= 0 && idx < self.locals.length() {
          match self.locals[idx] {
            Some(name) => Ok(name)
            None => Err(InvalidSymbol("unresolved id=" + id.to_string()))
          }
        } else {
          Err(InvalidSymbol("id=" + id.to_string()))
        }
      }
    }
  }
}

///|
pub fn SymbolTable::reset_locals(self : SymbolTable) -> Unit {
  while self.locals.length() > 0 {
    let _ = self.locals.pop()
  }
}

///|
pub fn SymbolTable::local_names(self : SymbolTable) -> Array[String] {
  let out : Array[String] = []
  for name in self.locals {
    match name {
      Some(s) => out.push(s)
      None => out.push("")
    }
  }
  out
}

///|
pub fn needs_quoting(name : String) -> Bool {
  if name == "true" ||
    name == "false" ||
    name == "null" ||
    name == "nan" ||
    is_text_version_marker(name) ||
    is_sid_text(name) {
    true
  } else if name.length() == 0 {
    true
  } else if !is_ident_start(name[0].to_int()) {
    true
  } else {
    let mut i = 1
    let mut ok = true
    while i < name.length() {
      if !is_ident_part(name[i].to_int()) {
        ok = false
      }
      i += 1
    }
    !ok
  }
}

///|
pub fn quote_symbol(name : String) -> String {
  if !needs_quoting(name) {
    name
  } else {
    let out = StringBuilder()
    out.write_char('\'')
    let mut i = 0
    while i < name.length() {
      let c = name[i].to_int()
      if c == 39 || c == 92 {
        out.write_char('\\')
        out.write_char(c.unsafe_to_char())
      } else if c < 32 || c == 127 {
        out.write_string("\\x")
        out.write_char(nibble_char((c >> 4) & 15, false))
        out.write_char(nibble_char(c & 15, false))
      } else {
        out.write_char(c.unsafe_to_char())
      }
      i += 1
    }
    out.write_char('\'')
    out.to_string()
  }
}

///|
fn is_sid_text(name : String) -> Bool {
  if name.length() < 2 || name[0].to_int() != 36 {
    return false
  }
  for i = 1; i < name.length(); i = i + 1 {
    if !is_digit(name[i].to_int()) {
      return false
    }
  }
  true
}
