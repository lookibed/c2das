use std::fmt;

/// daScript type representation, analogous to [`syn::Type`].
#[derive(Clone, Debug, PartialEq)]
pub enum DaType {
    Void,
    Bool,
    Int,
    Int8,
    Int16,
    Int64,
    UInt,
    UInt8,
    UInt16,
    UInt64,
    Float,
    Double,
    String_,
    /// Pointer type: `T?`
    Pointer(Box<DaType>),
    /// Dynamic array: `array<T>`
    Array(Box<DaType>),
    /// Fixed-size array: `fixed_array<T, N>`
    FixedArray(Box<DaType>, usize),
    /// Named type reference (struct, enum, alias)
    Named(String),
    /// Auto-inferred type
    Auto,
}

impl fmt::Display for DaType {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            DaType::Void => write!(f, "void"),
            DaType::Bool => write!(f, "bool"),
            DaType::Int => write!(f, "int"),
            DaType::Int8 => write!(f, "int8"),
            DaType::Int16 => write!(f, "int16"),
            DaType::Int64 => write!(f, "int64"),
            DaType::UInt => write!(f, "uint"),
            DaType::UInt8 => write!(f, "uint8"),
            DaType::UInt16 => write!(f, "uint16"),
            DaType::UInt64 => write!(f, "uint64"),
            DaType::Float => write!(f, "float"),
            DaType::Double => write!(f, "double"),
            DaType::String_ => write!(f, "string"),
            DaType::Pointer(inner) => write!(f, "{}?", inner),
            DaType::Array(inner) => write!(f, "array<{}>", inner),
            DaType::FixedArray(inner, n) => write!(f, "fixed_array<{}, {}>", inner, n),
            DaType::Named(name) => write!(f, "{}", name),
            DaType::Auto => write!(f, "auto"),
        }
    }
}
