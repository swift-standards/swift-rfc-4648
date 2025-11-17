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
    public init(base64Encoding bytes: [UInt8], padding: Bool = true) {
        let encoded = RFC_4648.Base64.encode(bytes, padding: padding)
        self = String(decoding: encoded, as: UTF8.self)
    }
}

// MARK: - Base64URL (RFC 4648 Section 5)

extension String {
    /// Creates a Base64URL encoded string from bytes (RFC 4648 Section 5)
    /// Base64URL uses '-' and '_' instead of '+' and '/', making it URL and filename safe.
    /// - Parameters:
    ///   - base64URLEncoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: false per RFC 7515)
    public init(base64URLEncoding bytes: [UInt8], padding: Bool = false) {
        let encoded = RFC_4648.Base64.URL.encode(bytes, padding: padding)
        self = String(decoding: encoded, as: UTF8.self)
    }
}

// MARK: - Base32 (RFC 4648 Section 6)

extension String {
    /// Creates a Base32 encoded string from bytes (RFC 4648 Section 6)
    /// Base32 uses 32-character alphabet (A-Z, 2-7), case-insensitive for decoding
    /// - Parameters:
    ///   - base32Encoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    public init(base32Encoding bytes: [UInt8], padding: Bool = true) {
        let encoded = RFC_4648.Base32.encode(bytes, padding: padding)
        self = String(decoding: encoded, as: UTF8.self)
    }
}

// MARK: - Base32-HEX (RFC 4648 Section 7)

extension String {
    /// Creates a Base32-HEX encoded string from bytes (RFC 4648 Section 7)
    /// Base32-HEX uses 0-9,A-V alphabet, case-insensitive for decoding
    /// - Parameters:
    ///   - base32HexEncoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    public init(base32HexEncoding bytes: [UInt8], padding: Bool = true) {
        let encoded = RFC_4648.Base32.Hex.encode(bytes, padding: padding)
        self = String(decoding: encoded, as: UTF8.self)
    }
}

// MARK: - Hex (RFC 4648 Section 8)

extension String {
    /// Creates a hexadecimal encoded string from bytes (RFC 4648 Section 8)
    /// - Parameters:
    ///   - hexEncoding: The bytes to encode
    ///   - uppercase: Whether to use uppercase hex digits (default: false)
    public init(hexEncoding bytes: [UInt8], uppercase: Bool = false) {
        let encoded = RFC_4648.Hex.encode(bytes, uppercase: uppercase)
        self = String(decoding: encoded, as: UTF8.self)
    }
}
