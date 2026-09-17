///|
pub fn system_symbol_name(id : Int) -> String? {
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
pub fn system_symbol_id(name : String) -> Int? {
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
pub fn system_max_id() -> Int {
  9
}

///|
pub(all) struct SymbolTable {
  locals : Array[String]
}

///|
pub fn symbol_table_new() -> SymbolTable {
  { locals: [], }
}

///|
pub fn SymbolTable::intern(self : SymbolTable, name : String) -> Int {
  match system_symbol_id(name) {
    Some(id) => id
    None => {
      let mut found = -1
      let mut i = 0
      while i < self.locals.length() {
        if self.locals[i] == name {
          found = i
        }
        i += 1
      }
      if found >= 0 {
        system_max_id() + 1 + found
      } else {
        self.locals.push(name)
        system_max_id() + self.locals.length()
      }
    }
  }
}

///|
pub fn SymbolTable::define_local(self : SymbolTable, name : String) -> Unit {
  self.locals.push(name)
}

///|
pub fn SymbolTable::name_of(
  self : SymbolTable,
  id : Int,
) -> Result[String, IonError] {
  if id == 0 {
    Ok("")
  } else {
    match system_symbol_name(id) {
      Some(name) => Ok(name)
      None => {
        let idx = id - system_max_id() - 1
        if idx >= 0 && idx < self.locals.length() {
          Ok(self.locals[idx])
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
    out.push(name)
  }
  out
}

///|
pub fn needs_quoting(name : String) -> Bool {
  if name.length() == 0 {
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
      }
      out.write_char(c.unsafe_to_char())
      i += 1
    }
    out.write_char('\'')
    out.to_string()
  }
}
