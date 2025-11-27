// Collection+RFC4648.swift
// swift-rfc-4648
//
// Collection extensions and array decoding using RFC_4648 primitives

// MARK: - Base64 (RFC 4648 Section 4)

public extension [UInt8] {
    /// Creates an array from a Base64 encoded string (RFC 4648 Section 4)
    /// - Parameter base64Encoded: Base64 encoded string
    /// - Returns: Decoded bytes, or nil if invalid Base64
    init?(base64Encoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base64.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Base64URL (RFC 4648 Section 5)

public extension [UInt8] {
    /// Creates an array from a Base64URL encoded string (RFC 4648 Section 5)
    /// - Parameter base64URLEncoded: Base64URL encoded string
    /// - Returns: Decoded bytes, or nil if invalid Base64URL
    init?(base64URLEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base64.URL.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Base32 (RFC 4648 Section 6)

public extension [UInt8] {
    /// Creates an array from a Base32 encoded string (RFC 4648 Section 6)
    /// - Parameter base32Encoded: Base32 encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base32
    init?(base32Encoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base32.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Base32-HEX (RFC 4648 Section 7)

public extension [UInt8] {
    /// Creates an array from a Base32-HEX encoded string (RFC 4648 Section 7)
    /// - Parameter base32HexEncoded: Base32-HEX encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base32-HEX
    init?(base32HexEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base32.Hex.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Base16/Hex (RFC 4648 Section 8)

public extension [UInt8] {
    /// Creates an array from a Base16 (hexadecimal) encoded string (RFC 4648 Section 8)
    /// - Parameter hexEncoded: Base16/hexadecimal encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base16
    init?(hexEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base16.decode(string) else { return nil }
        self = decoded
    }
}

// MARK: - Namespace Access (INCITS Pattern)

public extension Collection where Element == UInt8 {
    /// Access to Base64 instance operations
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]
    /// bytes.base64()  // "SGVsbG8="
    /// bytes.base64(padding: false)  // "SGVsbG8"
    /// ```
    @inlinable
    var base64: RFC_4648.Base64.CollectionWrapper<Self> {
        RFC_4648.Base64.CollectionWrapper(self)
    }

    /// Access to Base64URL instance operations
    @inlinable
    var base64URL: RFC_4648.Base64.URL.CollectionWrapper<Self> {
        RFC_4648.Base64.URL.CollectionWrapper(self)
    }

    /// Access to Base32 instance operations
    @inlinable
    var base32: RFC_4648.Base32.CollectionWrapper<Self> {
        RFC_4648.Base32.CollectionWrapper(self)
    }

    /// Access to Base32Hex instance operations
    @inlinable
    var base32Hex: RFC_4648.Base32.Hex.CollectionWrapper<Self> {
        RFC_4648.Base32.Hex.CollectionWrapper(self)
    }

    /// Access to Base16/Hex instance operations
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    /// bytes.hex()  // "deadbeef"
    /// bytes.hex(uppercase: true)  // "DEADBEEF"
    /// ```
    @inlinable
    var hex: RFC_4648.Base16.CollectionWrapper<Self> {
        RFC_4648.Base16.CollectionWrapper(self)
    }
}
