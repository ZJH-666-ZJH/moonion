///|
pub(all) enum IonType {
  NullT
  BoolT
  IntT
  FloatT
  DecimalT
  TimestampT
  SymbolT
  StringT
  ClobT
  BlobT
  ListT
  SexpT
  StructT
} derive(Eq, Debug)

///|
pub fn IonType::name(self : IonType) -> String {
  match self {
    NullT => "null"
    BoolT => "bool"
    IntT => "int"
    FloatT => "float"
    DecimalT => "decimal"
    TimestampT => "timestamp"
    SymbolT => "symbol"
    StringT => "string"
    ClobT => "clob"
    BlobT => "blob"
    ListT => "list"
    SexpT => "sexp"
    StructT => "struct"
  }
}

///|
pub(all) struct IonField {
  name : String
  value : IonValue
} derive(Eq, Debug)

///|
pub(all) enum IonDatum {
  NullD(IonType)
  BoolD(Bool)
  IntD(BigInt)
  FloatD(Double)
  DecimalD(IonDecimal)
  TimestampD(IonTimestamp)
  SymbolD(String)
  StringD(String)
  ClobD(Bytes)
  BlobD(Bytes)
  ListD(Array[IonValue])
  SexpD(Array[IonValue])
  StructD(Array[IonField])
} derive(Eq, Debug)

///|
pub(all) struct IonValue {
  annotations : Array[String]
  datum : IonDatum
} derive(Eq, Debug)

///|
pub fn ion_value(datum : IonDatum) -> IonValue {
  { annotations: [], datum, }
}

///|
pub fn ion_annotated(annotations : Array[String], datum : IonDatum) -> IonValue {
  { annotations, datum, }
}

///|
pub fn ion_null(typ : IonType) -> IonValue {
  ion_value(NullD(typ))
}

///|
pub fn ion_bool(value : Bool) -> IonValue {
  ion_value(BoolD(value))
}

///|
pub fn ion_int(value : Int) -> IonValue {
  ion_value(IntD(bigint_from_int(value)))
}

///|
pub fn ion_int64(value : Int64) -> IonValue {
  ion_value(IntD(bigint_from_int64(value)))
}

///|
pub fn ion_bigint(value : BigInt) -> IonValue {
  ion_value(IntD(value))
}

///|
pub fn ion_float(value : Double) -> IonValue {
  ion_value(FloatD(value))
}

///|
pub fn ion_decimal(value : IonDecimal) -> IonValue {
  ion_value(DecimalD(value))
}

///|
pub fn ion_timestamp(value : IonTimestamp) -> IonValue {
  ion_value(TimestampD(value))
}

///|
pub fn ion_symbol(value : String) -> IonValue {
  ion_value(SymbolD(value))
}

///|
pub fn ion_string(value : String) -> IonValue {
  ion_value(StringD(value))
}

///|
pub fn ion_clob(value : Bytes) -> IonValue {
  ion_value(ClobD(value))
}

///|
pub fn ion_blob(value : Bytes) -> IonValue {
  ion_value(BlobD(value))
}

///|
pub fn ion_list(values : Array[IonValue]) -> IonValue {
  ion_value(ListD(values))
}

///|
pub fn ion_sexp(values : Array[IonValue]) -> IonValue {
  ion_value(SexpD(values))
}

///|
pub fn ion_struct(fields : Array[IonField]) -> IonValue {
  ion_value(StructD(fields))
}

///|
pub fn ion_field(name : String, value : IonValue) -> IonField {
  { name, value, }
}

///|
pub fn IonValue::ion_type(self : IonValue) -> IonType {
  match self.datum {
    NullD(t) => t
    BoolD(_) => BoolT
    IntD(_) => IntT
    FloatD(_) => FloatT
    DecimalD(_) => DecimalT
    TimestampD(_) => TimestampT
    SymbolD(_) => SymbolT
    StringD(_) => StringT
    ClobD(_) => ClobT
    BlobD(_) => BlobT
    ListD(_) => ListT
    SexpD(_) => SexpT
    StructD(_) => StructT
  }
}

///|
pub fn IonValue::with_annotation(self : IonValue, name : String) -> IonValue {
  let anns : Array[String] = []
  for a in self.annotations {
    anns.push(a)
  }
  anns.push(name)
  { annotations: anns, datum: self.datum, }
}

///|
pub fn IonValue::is_null(self : IonValue) -> Bool {
  match self.datum {
    NullD(_) => true
    _ => false
  }
}

///|
pub fn IonValue::as_bool(self : IonValue) -> Bool? {
  match self.datum {
    BoolD(v) => Some(v)
    _ => None
  }
}

///|
pub fn IonValue::as_int(self : IonValue) -> BigInt? {
  match self.datum {
    IntD(v) => Some(v)
    _ => None
  }
}

///|
pub fn IonValue::as_string(self : IonValue) -> String? {
  match self.datum {
    StringD(v) => Some(v)
    _ => None
  }
}

///|
pub fn IonValue::as_symbol(self : IonValue) -> String? {
  match self.datum {
    SymbolD(v) => Some(v)
    _ => None
  }
}

///|
pub fn IonValue::as_list(self : IonValue) -> Array[IonValue]? {
  match self.datum {
    ListD(v) => Some(v)
    _ => None
  }
}

///|
pub fn IonValue::as_struct(self : IonValue) -> Array[IonField]? {
  match self.datum {
    StructD(v) => Some(v)
    _ => None
  }
}

///|
pub fn IonValue::field(self : IonValue, name : String) -> IonValue? {
  match self.datum {
    StructD(fields) => {
      let mut found : IonValue? = None
      for f in fields {
        if f.name == name {
          found = Some(f.value)
        }
      }
      found
    }
    _ => None
  }
}

///|
pub fn IonValue::is_symbol_table(self : IonValue) -> Bool {
  let mut found = false
  for a in self.annotations {
    if a == "$ion_symbol_table" {
      found = true
    }
  }
  found
}
