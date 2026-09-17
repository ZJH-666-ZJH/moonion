///|
pub(all) enum IonError {
  UnexpectedEof
  InvalidBinary(String)
  InvalidText(String)
  InvalidUtf8
  InvalidSymbol(String)
  InvalidTimestamp(String)
  InvalidDecimal(String)
  InvalidNumber(String)
  InvalidBlob(String)
  InvalidAnnotation(String)
  InvalidSymbolTable(String)
  Unsupported(String)
  EmptyDocument
} derive(Eq, Debug)

///|
pub fn IonError::code(self : IonError) -> String {
  match self {
    UnexpectedEof => "ION001"
    InvalidBinary(_) => "ION002"
    InvalidText(_) => "ION003"
    InvalidUtf8 => "ION004"
    InvalidSymbol(_) => "ION005"
    InvalidTimestamp(_) => "ION006"
    InvalidDecimal(_) => "ION007"
    InvalidNumber(_) => "ION008"
    InvalidBlob(_) => "ION009"
    InvalidAnnotation(_) => "ION010"
    InvalidSymbolTable(_) => "ION011"
    Unsupported(_) => "ION012"
    EmptyDocument => "ION013"
  }
}

///|
pub fn IonError::message(self : IonError) -> String {
  match self {
    UnexpectedEof => "unexpected end of Ion input"
    InvalidBinary(reason) => "invalid Ion binary: " + reason
    InvalidText(reason) => "invalid Ion text: " + reason
    InvalidUtf8 => "invalid UTF-8 in Ion string or symbol"
    InvalidSymbol(reason) => "invalid Ion symbol: " + reason
    InvalidTimestamp(reason) => "invalid Ion timestamp: " + reason
    InvalidDecimal(reason) => "invalid Ion decimal: " + reason
    InvalidNumber(reason) => "invalid Ion number: " + reason
    InvalidBlob(reason) => "invalid Ion blob/clob: " + reason
    InvalidAnnotation(reason) => "invalid Ion annotation: " + reason
    InvalidSymbolTable(reason) => "invalid Ion symbol table: " + reason
    Unsupported(reason) => "unsupported Ion feature: " + reason
    EmptyDocument => "Ion document contains no values"
  }
}
