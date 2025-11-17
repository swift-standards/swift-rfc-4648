// [UInt8]+RFC4648.swift
// swift-rfc-4648
//
// Array decoding extensions using RFC_4648 primitives

// MARK: - Base64 (RFC 4648 Section 4)

extension [UInt8] {
    /// Creates an array from a Base64 encoded string (RFC 4648 Section 4)
    /// - Parameter base64Encoded: Base64 encoded string
    /// - Returns: Decoded bytes, or nil if invalid Base64
    public init?(base64Encoded string: String) {
        guard let decoded = RFC_4648.Base64.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Base64URL (RFC 4648 Section 5)

extension [UInt8] {
    /// Creates an array from a Base64URL encoded string (RFC 4648 Section 5)
    /// - Parameter base64URLEncoded: Base64URL encoded string
    /// - Returns: Decoded bytes, or nil if invalid Base64URL
    public init?(base64URLEncoded string: String) {
        guard let decoded = RFC_4648.Base64URL.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Base32 (RFC 4648 Section 6)

extension [UInt8] {
    /// Creates an array from a Base32 encoded string (RFC 4648 Section 6)
    /// - Parameter base32Encoded: Base32 encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base32
    public init?(base32Encoded string: String) {
        guard let decoded = RFC_4648.Base32.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Base32-HEX (RFC 4648 Section 7)

extension [UInt8] {
    /// Creates an array from a Base32-HEX encoded string (RFC 4648 Section 7)
    /// - Parameter base32HexEncoded: Base32-HEX encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base32-HEX
    public init?(base32HexEncoded string: String) {
        guard let decoded = RFC_4648.Base32Hex.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Hex (RFC 4648 Section 8)

extension [UInt8] {
    /// Creates an array from a hexadecimal encoded string (RFC 4648 Section 8)
    /// - Parameter hexEncoded: Hexadecimal encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid hex
    public init?(hexEncoded string: String) {
        guard let decoded = RFC_4648.Hex.decode(string) else { return nil }
        self = decoded
    }
}
