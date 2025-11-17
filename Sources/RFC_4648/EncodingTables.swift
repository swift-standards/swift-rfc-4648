// EncodingTables.swift
// swift-rfc-4648
//
// Encoding and decoding tables for RFC 4648 data encodings

/// Encoding tables and constants for RFC 4648 data encodings
enum EncodingTables {
    // MARK: - Common

    /// Padding character used in Base64 and Base32 encodings
    static let paddingCharacter: UInt8 = UInt8(ascii: "=")

    // MARK: - Base64 (RFC 4648 Section 4)

    /// Base64 encode table
    static let base64: [UInt8] = Array(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".utf8
    )

    /// Base64 decode table (255 = invalid)
    static let base64Decode: [UInt8] = {
        var table = [UInt8](repeating: 255, count: 256)
        for (index, char) in base64.enumerated() {
            table[Int(char)] = UInt8(index)
        }
        return table
    }()

    // MARK: - Base64URL (RFC 4648 Section 5)

    /// Base64URL encode table (URL and filename safe alphabet)
    static let base64URL: [UInt8] = Array(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".utf8
    )

    /// Base64URL decode table (255 = invalid)
    static let base64URLDecode: [UInt8] = {
        var table = [UInt8](repeating: 255, count: 256)
        for (index, char) in base64URL.enumerated() {
            table[Int(char)] = UInt8(index)
        }
        return table
    }()

    // MARK: - Base32 (RFC 4648 Section 6)

    /// Base32 encode table
    static let base32: [UInt8] = Array(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".utf8
    )

    /// Base32 decode table (255 = invalid, case-insensitive)
    static let base32Decode: [UInt8] = {
        var table = [UInt8](repeating: 255, count: 256)
        for (index, char) in base32.enumerated() {
            table[Int(char)] = UInt8(index)
            // Base32 is case-insensitive, support lowercase too
            if char >= UInt8(ascii: "A") && char <= UInt8(ascii: "Z") {
                let lowercase = char + 32
                table[Int(lowercase)] = UInt8(index)
            }
        }
        return table
    }()

    // MARK: - Base32-HEX (RFC 4648 Section 7)

    /// Base32-HEX encode table (Extended Hex Alphabet)
    static let base32Hex: [UInt8] = Array(
        "0123456789ABCDEFGHIJKLMNOPQRSTUV".utf8
    )

    /// Base32-HEX decode table (255 = invalid, case-insensitive)
    static let base32HexDecode: [UInt8] = {
        var table = [UInt8](repeating: 255, count: 256)
        for (index, char) in base32Hex.enumerated() {
            table[Int(char)] = UInt8(index)
            // Base32-HEX is case-insensitive for letters
            if char >= UInt8(ascii: "A") && char <= UInt8(ascii: "V") {
                let lowercase = char + 32
                table[Int(lowercase)] = UInt8(index)
            }
        }
        return table
    }()

    // MARK: - Base16/Hex (RFC 4648 Section 8)

    /// Hex encode table (lowercase)
    static let hex: [UInt8] = Array(
        "0123456789abcdef".utf8
    )

    /// Hex encode table (uppercase)
    static let hexUppercase: [UInt8] = Array(
        "0123456789ABCDEF".utf8
    )

    /// Hex decode table (255 = invalid, case-insensitive)
    static let hexDecode: [UInt8] = {
        var table = [UInt8](repeating: 255, count: 256)

        // 0-9
        for char in UInt8(ascii: "0")...UInt8(ascii: "9") {
            table[Int(char)] = char - UInt8(ascii: "0")
        }

        // a-f
        for char in UInt8(ascii: "a")...UInt8(ascii: "f") {
            table[Int(char)] = 10 + (char - UInt8(ascii: "a"))
        }

        // A-F
        for char in UInt8(ascii: "A")...UInt8(ascii: "F") {
            table[Int(char)] = 10 + (char - UInt8(ascii: "A"))
        }

        return table
    }()
}

// MARK: - Whitespace Handling

extension UInt8 {
    /// Whitespace characters allowed in encoded data (space, tab, LF, CR)
    @inlinable
    var isEncodingWhitespace: Bool {
        self == 0x20 || self == 0x09 || self == 0x0A || self == 0x0D
    }
}
