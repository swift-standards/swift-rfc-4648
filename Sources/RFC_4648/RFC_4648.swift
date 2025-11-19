// RFC_4648.swift
// swift-rfc-4648
//
// Core implementations for RFC 4648: The Base16, Base32, and Base64 Data Encodings

/// RFC 4648: The Base16, Base32, and Base64 Data Encodings
public enum RFC_4648 {
    /// Padding character used in Base64 and Base32 encodings (RFC 4648)
    /// Not used by hexadecimal encoding (Section 8)
    public static let padding: UInt8 = UInt8(ascii: "=")

    /// Convert FixedWidthInteger to byte array using big-endian byte order
    ///
    /// Big-endian ensures consistent, platform-independent output and matches
    /// network byte order (most significant byte first).
    ///
    /// - Parameter value: The integer value to convert
    /// - Returns: Array of bytes in big-endian order
    internal static func bytes<T: FixedWidthInteger>(from value: T) -> [UInt8] {
        withUnsafeBytes(of: value.bigEndian) { Array($0) }
    }
}
