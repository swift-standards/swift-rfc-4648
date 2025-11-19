// BinaryInteger+RFC4648.swift
// swift-rfc-4648
//
// BinaryInteger decoding extensions for RFC 4648 encodings

import Foundation
import RFC_4648
import Standards

// MARK: - BinaryInteger Decoding

extension FixedWidthInteger {
    /// Creates an integer from a Base64 encoded string (RFC 4648 Section 4)
    ///
    /// Decodes the Base64 string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width.
    ///
    /// - Parameter base64Encoded: Base64 encoded string
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value = UInt32(base64Encoded: "AAHiQA==")  // 123456
    /// let invalid = UInt32(base64Encoded: "invalid")  // nil
    /// let wrongSize = UInt8(base64Encoded: "AAHiQA==")  // nil (4 bytes != 1 byte)
    /// ```
    public init?(base64Encoded string: String) {
        guard let bytes = [UInt8](base64Encoded: string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    /// Creates an integer from a Base64URL encoded string (RFC 4648 Section 5)
    ///
    /// Decodes the Base64URL string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width.
    ///
    /// - Parameter base64URLEncoded: Base64URL encoded string
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value = UInt32(base64URLEncoded: "AAHiQA")  // 123456
    /// ```
    public init?(base64URLEncoded string: String) {
        guard let bytes = [UInt8](base64URLEncoded: string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    /// Creates an integer from a Base32 encoded string (RFC 4648 Section 6)
    ///
    /// Decodes the Base32 string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width.
    ///
    /// - Parameter base32Encoded: Base32 encoded string (case-insensitive)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value = UInt32(base32Encoded: "AAA6EQA=")  // 123456
    /// ```
    public init?(base32Encoded string: String) {
        guard let bytes = [UInt8](base32Encoded: string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    /// Creates an integer from a Base32-HEX encoded string (RFC 4648 Section 7)
    ///
    /// Decodes the Base32-HEX string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width.
    ///
    /// - Parameter base32HexEncoded: Base32-HEX encoded string (case-insensitive)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value = UInt32(base32HexEncoded: "000U4G0=")  // 123456
    /// ```
    public init?(base32HexEncoded string: String) {
        guard let bytes = [UInt8](base32HexEncoded: string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    /// Creates an integer from a hexadecimal encoded string (RFC 4648 Section 8)
    ///
    /// Decodes the hexadecimal string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width. Accepts strings with or without "0x" prefix.
    ///
    /// - Parameter hexEncoded: Hexadecimal encoded string (case-insensitive)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value1 = UInt32(hexEncoded: "deadbeef")  // 3735928559
    /// let value2 = UInt32(hexEncoded: "0xdeadbeef")  // 3735928559
    /// let value3 = UInt32(hexEncoded: "0xDEADBEEF")  // 3735928559
    /// ```
    public init?(hexEncoded string: String) {
        // Strip common prefixes
        let cleaned = string.hasPrefix("0x") || string.hasPrefix("0X")
            ? String(string.dropFirst(2))
            : string

        guard let bytes = [UInt8](hexEncoded: cleaned) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }
}

// MARK: - Convenience Properties

extension FixedWidthInteger {
    /// Base64 encoded representation of this integer (RFC 4648 Section 4)
    ///
    /// Converts the integer to big-endian bytes and encodes as Base64 with padding.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// UInt32(123456).base64Encoded  // "AAHiQA=="
    /// UInt64(0x123456789ABCDEF0).base64Encoded  // "EjRWeJq83vA="
    /// ```
    public var base64Encoded: String {
        String(base64: self, padding: true)
    }

    /// Base64URL encoded representation of this integer (RFC 4648 Section 5)
    ///
    /// Converts the integer to big-endian bytes and encodes as Base64URL without padding.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// UInt32(123456).base64URLEncoded  // "AAHiQA"
    /// ```
    public var base64URLEncoded: String {
        String(base64URL: self, padding: false)
    }

    /// Base32 encoded representation of this integer (RFC 4648 Section 6)
    ///
    /// Converts the integer to big-endian bytes and encodes as Base32 with padding.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// UInt32(123456).base32Encoded  // "AAA6EQA="
    /// ```
    public var base32Encoded: String {
        String(base32: self, padding: true)
    }

    /// Base32-HEX encoded representation of this integer (RFC 4648 Section 7)
    ///
    /// Converts the integer to big-endian bytes and encodes as Base32-HEX with padding.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// UInt32(123456).base32HexEncoded  // "000U4G0="
    /// ```
    public var base32HexEncoded: String {
        String(base32Hex: self, padding: true)
    }

    /// Hexadecimal encoded representation of this integer (RFC 4648 Section 8)
    ///
    /// Converts the integer to big-endian bytes and encodes as lowercase hexadecimal
    /// without a prefix.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// UInt32(0xDEADBEEF).hexEncoded  // "deadbeef"
    /// UInt8(255).hexEncoded  // "ff"
    /// ```
    public var hexEncoded: String {
        String(hex: self, prefix: "", uppercase: false)
    }
}
