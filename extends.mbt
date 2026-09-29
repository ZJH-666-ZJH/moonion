///|
// Keep the derived trait methods explicit on the public API.  Newer MoonBit
// compilers no longer promote these methods implicitly from `derive`.
pub extend BigInt with Eq::{equal, not_equal}

///|
pub extend BigInt with @debug.Debug::{to_repr}

///|
pub extend IonDecimal with Eq::{equal, not_equal}

///|
pub extend IonDecimal with @debug.Debug::{to_repr}

///|
pub extend IonError with Eq::{equal, not_equal}

///|
pub extend IonError with @debug.Debug::{to_repr}

///|
pub extend TimestampPrecision with Eq::{equal, not_equal}

///|
pub extend TimestampPrecision with @debug.Debug::{to_repr}

///|
pub extend IonTimestamp with Eq::{equal, not_equal}

///|
pub extend IonTimestamp with @debug.Debug::{to_repr}

///|
pub extend IonType with Eq::{equal, not_equal}

///|
pub extend IonType with @debug.Debug::{to_repr}

///|
pub extend IonField with Eq::{equal, not_equal}

///|
pub extend IonField with @debug.Debug::{to_repr}

///|
pub extend IonDatum with Eq::{equal, not_equal}

///|
pub extend IonDatum with @debug.Debug::{to_repr}

///|
pub extend IonValue with Eq::{equal, not_equal}

///|
pub extend IonValue with @debug.Debug::{to_repr}
