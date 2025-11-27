// String+RFC4648.swift
// swift-rfc-4648
//
// String encoding extensions using RFC_4648 primitives

// MARK: - Base64 (RFC 4648 Section 4)

extension String {
    /// Creates a Base64 encoded string from bytes (RFC 4648 Section 4)
    /// - Parameters:
    ///   - base64Encoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    public init<Bytes: Collection>(
        base64Encoding bytes: Bytes,
        padding: Bool = true
    ) where Bytes.Element == UInt8 {
        let encoded = RFC_4648.Base64.encode(bytes, padding: padding)
        self = String(decoding: encoded, as: UTF8.self)
    }

    /// Encode a FixedWidthInteger as Base64 (RFC 4648 Section 4)
    ///
    /// Converts the integer to bytes using big-endian byte order, then
    /// applies Base64 encoding per RFC 4648 Section 4.
    ///
    /// - Parameters:
    ///   - base64: The integer value to encode
    ///   - padding: Include padding characters (default: true)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// String(base64: UInt32(123456))               // "AAHiQA=="
    /// String(base64: UInt32(123456), padding: false) // "AAHiQA"
    /// ```
    public init<T: FixedWidthInteger>(
        base64 value: T,
        padding: Bool = true
    ) {
        let bytes = RFC_4648.bytes(from: value)
        self = String(base64Encoding: bytes, padding: padding)
    }
}

// MARK: - Base64URL (RFC 4648 Section 5)

extension String {
    /// Creates a Base64URL encoded string from bytes (RFC 4648 Section 5)
    /// Base64URL uses '-' and '_' instead of '+' and '/', making it URL and filename safe.
    /// - Parameters:
    ///   - base64URLEncoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: false per RFC 7515)
    public init<Bytes: Collection>(
        base64URLEncoding bytes: Bytes,
        padding: Bool = false
    ) where Bytes.Element == UInt8 {
        let encoded = RFC_4648.Base64.URL.encode(bytes, padding: padding)
        self = String(decoding: encoded, as: UTF8.self)
    }

    /// Encode a FixedWidthInteger as Base64URL (RFC 4648 Section 5)
    ///
    /// Converts the integer to bytes using big-endian byte order, then
    /// applies Base64URL encoding (URL-safe variant) per RFC 4648 Section 5.
    ///
    /// - Parameters:
    ///   - base64URL: The integer value to encode
    ///   - padding: Include padding characters (default: false per RFC 7515)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// String(base64URL: UInt32(123456))               // "AAHiQA"
    /// String(base64URL: UInt32(123456), padding: true) // "AAHiQA=="
    /// ```
    public init<T: FixedWidthInteger>(
        base64URL value: T,
        padding: Bool = false
    ) {
        let bytes = RFC_4648.bytes(from: value)
        self = String(base64URLEncoding: bytes, padding: padding)
    }
}

// MARK: - Base32 (RFC 4648 Section 6)

extension String {
    /// Creates a Base32 encoded string from bytes (RFC 4648 Section 6)
    /// Base32 uses 32-character alphabet (A-Z, 2-7), case-insensitive for decoding
    /// - Parameters:
    ///   - base32Encoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    public init<Bytes: Collection>(
        base32Encoding bytes: Bytes,
        padding: Bool = true
    ) where Bytes.Element == UInt8 {
        let encoded = RFC_4648.Base32.encode(bytes, padding: padding)
        self = String(decoding: encoded, as: UTF8.self)
    }

    /// Encode a FixedWidthInteger as Base32 (RFC 4648 Section 6)
    ///
    /// Converts the integer to bytes using big-endian byte order, then
    /// applies Base32 encoding per RFC 4648 Section 6.
    ///
    /// - Parameters:
    ///   - base32: The integer value to encode
    ///   - padding: Include padding characters (default: true)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// String(base32: UInt32(123456))               // "AAPCQAA====="
    /// String(base32: UInt32(123456), padding: false) // "AAPCQAA"
    /// ```
    public init<T: FixedWidthInteger>(
        base32 value: T,
        padding: Bool = true
    ) {
        let bytes = RFC_4648.bytes(from: value)
        self = String(base32Encoding: bytes, padding: padding)
    }
}

// MARK: - Base32-HEX (RFC 4648 Section 7)

extension String {
    /// Creates a Base32-HEX encoded string from bytes (RFC 4648 Section 7)
    /// Base32-HEX uses 0-9,A-V alphabet, case-insensitive for decoding
    /// - Parameters:
    ///   - base32HexEncoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    public init<Bytes: Collection>(
        base32HexEncoding bytes: Bytes,
        padding: Bool = true
    ) where Bytes.Element == UInt8 {
        let encoded = RFC_4648.Base32.Hex.encode(bytes, padding: padding)
        self = String(decoding: encoded, as: UTF8.self)
    }

    /// Encode a FixedWidthInteger as Base32-HEX (RFC 4648 Section 7)
    ///
    /// Converts the integer to bytes using big-endian byte order, then
    /// applies Base32-HEX encoding (Extended Hex Alphabet) per RFC 4648 Section 7.
    ///
    /// - Parameters:
    ///   - base32Hex: The integer value to encode
    ///   - padding: Include padding characters (default: true)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// String(base32Hex: UInt32(123456))               // "00F2G00====="
    /// String(base32Hex: UInt32(123456), padding: false) // "00F2G00"
    /// ```
    public init<T: FixedWidthInteger>(
        base32Hex value: T,
        padding: Bool = true
    ) {
        let bytes = RFC_4648.bytes(from: value)
        self = String(base32HexEncoding: bytes, padding: padding)
    }
}

// MARK: - Base16/Hex (RFC 4648 Section 8)

extension String {
    /// Creates a Base16 (hexadecimal) encoded string from bytes (RFC 4648 Section 8)
    /// - Parameters:
    ///   - hexEncoding: The bytes to encode
    ///   - uppercase: Whether to use uppercase hex digits (default: false)
    public init<Bytes: Collection>(
        hexEncoding bytes: Bytes,
        uppercase: Bool = false
    ) where Bytes.Element == UInt8 {
        let encoded = RFC_4648.Base16.encode(bytes, uppercase: uppercase)
        self = String(decoding: encoded, as: UTF8.self)
    }

    /// Encode a FixedWidthInteger as hexadecimal (RFC 4648 Section 8)
    ///
    /// Converts the integer to bytes using big-endian byte order, then
    /// applies hexadecimal encoding per RFC 4648 Section 8.
    ///
    /// - Parameters:
    ///   - hex: The integer value to encode
    ///   - prefix: Prefix string (default: "0x" for standard hex notation)
    ///   - uppercase: Use uppercase hex digits (default: false)
    ///
    /// - Returns: Hexadecimal string representation
    ///
    /// ## Examples
    ///
    /// ```swift
    /// String(hex: 255)                      // "0xff"
    /// String(hex: 255, prefix: "")          // "ff"
    /// String(hex: 255, uppercase: true)     // "0xFF"
    /// String(hex: UInt16(0xABCD))           // "0xabcd"
    /// String(hex: Int8(-1))                 // "0xff"
    /// ```
    public init<T: FixedWidthInteger>(
        hex value: T,
        prefix: String = "0x",
        uppercase: Bool = false
    ) {
        let bytes = RFC_4648.bytes(from: value)
        let encoded = String(hexEncoding: bytes, uppercase: uppercase)
        self = prefix + encoded
    }
}
