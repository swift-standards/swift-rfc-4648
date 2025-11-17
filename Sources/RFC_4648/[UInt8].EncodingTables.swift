// [UInt8].EncodingTables.swift
// swift-rfc-4648
//
// Encoding and decoding tables for RFC 4648 data encodings

extension [UInt8] {
    /// Encoding tables namespace
    enum encodingtable {
        /// Padding character used in Base64 and Base32 encodings
        static let padding: UInt8 = UInt8(ascii: "=")

        /// Base64 encoding tables (RFC 4648 Section 4)
        enum base64 {
            static let encode: [UInt8] = Array(
                "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".utf8
            )

            static let decode: [UInt8] = {
                var table = [UInt8](repeating: 255, count: 256)
                for (index, char) in encode.enumerated() {
                    table[Int(char)] = UInt8(index)
                }
                return table
            }()
        }

        /// Base64URL encoding tables (RFC 4648 Section 5)
        enum base64url {
            static let encode: [UInt8] = Array(
                "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".utf8
            )

            static let decode: [UInt8] = {
                var table = [UInt8](repeating: 255, count: 256)
                for (index, char) in encode.enumerated() {
                    table[Int(char)] = UInt8(index)
                }
                return table
            }()
        }

        /// Base32 encoding tables (RFC 4648 Section 6)
        enum base32 {
            static let encode: [UInt8] = Array(
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".utf8
            )

            static let decode: [UInt8] = {
                var table = [UInt8](repeating: 255, count: 256)
                for (index, char) in encode.enumerated() {
                    table[Int(char)] = UInt8(index)
                    // Base32 is case-insensitive, support lowercase too
                    if char >= UInt8(ascii: "A") && char <= UInt8(ascii: "Z") {
                        let lowercase = char + 32
                        table[Int(lowercase)] = UInt8(index)
                    }
                }
                return table
            }()
        }

        /// Base32-HEX encoding tables (RFC 4648 Section 7)
        enum base32hex {
            static let encode: [UInt8] = Array(
                "0123456789ABCDEFGHIJKLMNOPQRSTUV".utf8
            )

            static let decode: [UInt8] = {
                var table = [UInt8](repeating: 255, count: 256)
                for (index, char) in encode.enumerated() {
                    table[Int(char)] = UInt8(index)
                    // Base32-HEX is case-insensitive for letters
                    if char >= UInt8(ascii: "A") && char <= UInt8(ascii: "V") {
                        let lowercase = char + 32
                        table[Int(lowercase)] = UInt8(index)
                    }
                }
                return table
            }()
        }

        /// Hexadecimal encoding tables (RFC 4648 Section 8)
        enum hex {
            static let encode: [UInt8] = Array(
                "0123456789abcdef".utf8
            )

            static let encodeUppercase: [UInt8] = Array(
                "0123456789ABCDEF".utf8
            )

            static let decode: [UInt8] = {
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
    }
}

// MARK: - Whitespace Handling

extension UInt8 {
    /// Whitespace characters allowed in encoded data (space, tab, LF, CR)
    @inlinable
    var isEncodingWhitespace: Bool {
        self == 0x20 || self == 0x09 || self == 0x0A || self == 0x0D
    }
}
