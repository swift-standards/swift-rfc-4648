// RFC_4648.swift
// swift-rfc-4648
//
// Core implementations for RFC 4648: The Base16, Base32, and Base64 Data Encodings

/// RFC 4648: The Base16, Base32, and Base64 Data Encodings
public enum RFC_4648 {

    // MARK: - Base64 (Section 4)

    /// Base64 encoding (RFC 4648 Section 4)
    public enum Base64 {
        /// Encodes bytes to Base64
        /// - Parameters:
        ///   - bytes: The bytes to encode
        ///   - padding: Whether to include padding characters (default: true)
        /// - Returns: Base64 encoded bytes
        public static func encode(_ bytes: [UInt8], padding: Bool = true) -> [UInt8] {
            guard !bytes.isEmpty else { return [] }

            var result = [UInt8]()
            result.reserveCapacity(((bytes.count + 2) / 3) * 4)

            var index = 0
            while index < bytes.count {
                let b1 = bytes[index]
                let b2 = index + 1 < bytes.count ? bytes[index + 1] : 0
                let b3 = index + 2 < bytes.count ? bytes[index + 2] : 0

                let c1 = (b1 >> 2) & 0x3F
                let c2 = ((b1 << 4) | (b2 >> 4)) & 0x3F
                let c3 = ((b2 << 2) | (b3 >> 6)) & 0x3F
                let c4 = b3 & 0x3F

                result.append([UInt8].encodingtable.base64.encode[Int(c1)])
                result.append([UInt8].encodingtable.base64.encode[Int(c2)])

                if index + 1 < bytes.count {
                    result.append([UInt8].encodingtable.base64.encode[Int(c3)])
                } else if padding {
                    result.append([UInt8].encodingtable.padding)
                }

                if index + 2 < bytes.count {
                    result.append([UInt8].encodingtable.base64.encode[Int(c4)])
                } else if padding {
                    result.append([UInt8].encodingtable.padding)
                }

                index += 3
            }

            return result
        }

        /// Decodes Base64 encoded string
        /// - Parameter string: Base64 encoded string
        /// - Returns: Decoded bytes, or nil if invalid
        public static func decode(_ string: String) -> [UInt8]? {
            let bytes = Array(string.utf8)
            guard !bytes.isEmpty else { return [] }

            let decodeTable = [UInt8].encodingtable.base64.decode
            var result = [UInt8]()
            result.reserveCapacity((bytes.count * 3) / 4)

            var index = 0
            while index < bytes.count {
                // Skip whitespace
                while index < bytes.count && bytes[index].isEncodingWhitespace {
                    index += 1
                }
                if index >= bytes.count { break }

                guard index + 3 < bytes.count else { return nil }

                let c1 = decodeTable[Int(bytes[index])]
                let c2 = decodeTable[Int(bytes[index + 1])]
                let c3 = bytes[index + 2] == [UInt8].encodingtable.padding ? 255 : decodeTable[Int(bytes[index + 2])]
                let c4 = bytes[index + 3] == [UInt8].encodingtable.padding ? 255 : decodeTable[Int(bytes[index + 3])]

                guard c1 != 255 && c2 != 255 else { return nil }

                let b1 = (c1 << 2) | (c2 >> 4)
                result.append(b1)

                if c3 != 255 {
                    let b2 = ((c2 & 0x0F) << 4) | (c3 >> 2)
                    result.append(b2)

                    if c4 != 255 {
                        let b3 = ((c3 & 0x03) << 6) | c4
                        result.append(b3)
                    }
                }

                index += 4
            }

            return result
        }
    }

    // MARK: - Base64URL (Section 5)

    /// Base64URL encoding (RFC 4648 Section 5) - URL and filename safe
    public enum Base64URL {
        /// Encodes bytes to Base64URL
        /// - Parameters:
        ///   - bytes: The bytes to encode
        ///   - padding: Whether to include padding (default: false per RFC 7515)
        /// - Returns: Base64URL encoded bytes
        public static func encode(_ bytes: [UInt8], padding: Bool = false) -> [UInt8] {
            guard !bytes.isEmpty else { return [] }

            var result = [UInt8]()
            result.reserveCapacity(((bytes.count + 2) / 3) * 4)

            var index = 0
            while index < bytes.count {
                let b1 = bytes[index]
                let b2 = index + 1 < bytes.count ? bytes[index + 1] : 0
                let b3 = index + 2 < bytes.count ? bytes[index + 2] : 0

                let c1 = (b1 >> 2) & 0x3F
                let c2 = ((b1 << 4) | (b2 >> 4)) & 0x3F
                let c3 = ((b2 << 2) | (b3 >> 6)) & 0x3F
                let c4 = b3 & 0x3F

                result.append([UInt8].encodingtable.base64url.encode[Int(c1)])
                result.append([UInt8].encodingtable.base64url.encode[Int(c2)])

                if index + 1 < bytes.count {
                    result.append([UInt8].encodingtable.base64url.encode[Int(c3)])
                } else if padding {
                    result.append([UInt8].encodingtable.padding)
                }

                if index + 2 < bytes.count {
                    result.append([UInt8].encodingtable.base64url.encode[Int(c4)])
                } else if padding {
                    result.append([UInt8].encodingtable.padding)
                }

                index += 3
            }

            return result
        }

        /// Decodes Base64URL encoded string
        /// - Parameter string: Base64URL encoded string
        /// - Returns: Decoded bytes, or nil if invalid
        public static func decode(_ string: String) -> [UInt8]? {
            let bytes = Array(string.utf8)
            guard !bytes.isEmpty else { return [] }

            let decodeTable = [UInt8].encodingtable.base64url.decode
            var result = [UInt8]()
            result.reserveCapacity((bytes.count * 3) / 4)

            var index = 0
            while index < bytes.count {
                // Skip whitespace
                while index < bytes.count && bytes[index].isEncodingWhitespace {
                    index += 1
                }
                if index >= bytes.count { break }

                // Base64URL allows missing padding
                let remaining = bytes.count - index
                if remaining < 2 { return nil }

                let c1 = decodeTable[Int(bytes[index])]
                let c2 = decodeTable[Int(bytes[index + 1])]

                guard c1 != 255 && c2 != 255 else { return nil }

                let b1 = (c1 << 2) | (c2 >> 4)
                result.append(b1)

                if remaining >= 3 && bytes[index + 2] != [UInt8].encodingtable.padding {
                    let c3 = decodeTable[Int(bytes[index + 2])]
                    guard c3 != 255 else { return nil }

                    let b2 = ((c2 & 0x0F) << 4) | (c3 >> 2)
                    result.append(b2)

                    if remaining >= 4 && bytes[index + 3] != [UInt8].encodingtable.padding {
                        let c4 = decodeTable[Int(bytes[index + 3])]
                        guard c4 != 255 else { return nil }

                        let b3 = ((c3 & 0x03) << 6) | c4
                        result.append(b3)
                        index += 4
                    } else {
                        index += 4
                        if remaining < 4 { break }
                    }
                } else {
                    index += 4
                    if remaining < 3 { break }
                }
            }

            return result
        }
    }

    // MARK: - Base32 (Section 6)

    /// Base32 encoding (RFC 4648 Section 6) - Case-insensitive, human-friendly
    public enum Base32 {
        /// Encodes bytes to Base32
        /// - Parameters:
        ///   - bytes: The bytes to encode
        ///   - padding: Whether to include padding (default: true)
        /// - Returns: Base32 encoded bytes
        public static func encode(_ bytes: [UInt8], padding: Bool = true) -> [UInt8] {
            guard !bytes.isEmpty else { return [] }

            var result = [UInt8]()
            result.reserveCapacity(((bytes.count + 4) / 5) * 8)

            var index = 0
            while index < bytes.count {
                let b1 = bytes[index]
                let b2 = index + 1 < bytes.count ? bytes[index + 1] : 0
                let b3 = index + 2 < bytes.count ? bytes[index + 2] : 0
                let b4 = index + 3 < bytes.count ? bytes[index + 3] : 0
                let b5 = index + 4 < bytes.count ? bytes[index + 4] : 0

                let c1 = (b1 >> 3) & 0x1F
                let c2 = ((b1 << 2) | (b2 >> 6)) & 0x1F
                let c3 = (b2 >> 1) & 0x1F
                let c4 = ((b2 << 4) | (b3 >> 4)) & 0x1F
                let c5 = ((b3 << 1) | (b4 >> 7)) & 0x1F
                let c6 = (b4 >> 2) & 0x1F
                let c7 = ((b4 << 3) | (b5 >> 5)) & 0x1F
                let c8 = b5 & 0x1F

                result.append([UInt8].encodingtable.base32.encode[Int(c1)])
                result.append([UInt8].encodingtable.base32.encode[Int(c2)])

                if index + 1 < bytes.count {
                    result.append([UInt8].encodingtable.base32.encode[Int(c3)])
                    result.append([UInt8].encodingtable.base32.encode[Int(c4)])
                } else if padding {
                    result.append(contentsOf: [[UInt8].encodingtable.padding, [UInt8].encodingtable.padding,
                                              [UInt8].encodingtable.padding, [UInt8].encodingtable.padding,
                                              [UInt8].encodingtable.padding, [UInt8].encodingtable.padding])
                    break
                } else {
                    break
                }

                if index + 2 < bytes.count {
                    result.append([UInt8].encodingtable.base32.encode[Int(c5)])
                } else if padding {
                    result.append(contentsOf: [[UInt8].encodingtable.padding, [UInt8].encodingtable.padding,
                                              [UInt8].encodingtable.padding, [UInt8].encodingtable.padding])
                    break
                } else {
                    break
                }

                if index + 3 < bytes.count {
                    result.append([UInt8].encodingtable.base32.encode[Int(c6)])
                    result.append([UInt8].encodingtable.base32.encode[Int(c7)])
                } else if padding {
                    result.append(contentsOf: [[UInt8].encodingtable.padding, [UInt8].encodingtable.padding,
                                              [UInt8].encodingtable.padding])
                    break
                } else {
                    break
                }

                if index + 4 < bytes.count {
                    result.append([UInt8].encodingtable.base32.encode[Int(c8)])
                } else if padding {
                    result.append([UInt8].encodingtable.padding)
                    break
                } else {
                    break
                }

                index += 5
            }

            return result
        }

        /// Decodes Base32 encoded string (case-insensitive)
        /// - Parameter string: Base32 encoded string
        /// - Returns: Decoded bytes, or nil if invalid
        public static func decode(_ string: String) -> [UInt8]? {
            let bytes = Array(string.utf8)
            guard !bytes.isEmpty else { return [] }

            let decodeTable = [UInt8].encodingtable.base32.decode
            var result = [UInt8]()
            result.reserveCapacity((bytes.count * 5) / 8)

            var index = 0
            while index < bytes.count {
                // Skip whitespace
                while index < bytes.count && bytes[index].isEncodingWhitespace {
                    index += 1
                }
                if index >= bytes.count { break }

                let remaining = bytes.count - index
                if remaining < 2 { return nil }

                var values = [UInt8]()
                for i in 0..<8 {
                    if index + i >= bytes.count { break }
                    let byte = bytes[index + i]
                    if byte == [UInt8].encodingtable.padding { break }
                    let value = decodeTable[Int(byte)]
                    guard value != 255 else { return nil }
                    values.append(value)
                }

                guard values.count >= 2 else { return nil }

                result.append((values[0] << 3) | (values[1] >> 2))

                if values.count >= 4 {
                    result.append((values[1] << 6) | (values[2] << 1) | (values[3] >> 4))
                }

                if values.count >= 5 {
                    result.append((values[3] << 4) | (values[4] >> 1))
                }

                if values.count >= 7 {
                    result.append((values[4] << 7) | (values[5] << 2) | (values[6] >> 3))
                }

                if values.count >= 8 {
                    result.append((values[6] << 5) | values[7])
                }

                index += 8
            }

            return result
        }
    }

    // MARK: - Base32-HEX (Section 7)

    /// Base32-HEX encoding (RFC 4648 Section 7) - Extended Hex Alphabet
    public enum Base32Hex {
        /// Encodes bytes to Base32-HEX
        /// - Parameters:
        ///   - bytes: The bytes to encode
        ///   - padding: Whether to include padding (default: true)
        /// - Returns: Base32-HEX encoded bytes
        public static func encode(_ bytes: [UInt8], padding: Bool = true) -> [UInt8] {
            guard !bytes.isEmpty else { return [] }

            var result = [UInt8]()
            result.reserveCapacity(((bytes.count + 4) / 5) * 8)

            var index = 0
            while index < bytes.count {
                let b1 = bytes[index]
                let b2 = index + 1 < bytes.count ? bytes[index + 1] : 0
                let b3 = index + 2 < bytes.count ? bytes[index + 2] : 0
                let b4 = index + 3 < bytes.count ? bytes[index + 3] : 0
                let b5 = index + 4 < bytes.count ? bytes[index + 4] : 0

                let c1 = (b1 >> 3) & 0x1F
                let c2 = ((b1 << 2) | (b2 >> 6)) & 0x1F
                let c3 = (b2 >> 1) & 0x1F
                let c4 = ((b2 << 4) | (b3 >> 4)) & 0x1F
                let c5 = ((b3 << 1) | (b4 >> 7)) & 0x1F
                let c6 = (b4 >> 2) & 0x1F
                let c7 = ((b4 << 3) | (b5 >> 5)) & 0x1F
                let c8 = b5 & 0x1F

                result.append([UInt8].encodingtable.base32hex.encode[Int(c1)])
                result.append([UInt8].encodingtable.base32hex.encode[Int(c2)])

                if index + 1 < bytes.count {
                    result.append([UInt8].encodingtable.base32hex.encode[Int(c3)])
                    result.append([UInt8].encodingtable.base32hex.encode[Int(c4)])
                } else if padding {
                    result.append(contentsOf: [[UInt8].encodingtable.padding, [UInt8].encodingtable.padding,
                                              [UInt8].encodingtable.padding, [UInt8].encodingtable.padding,
                                              [UInt8].encodingtable.padding, [UInt8].encodingtable.padding])
                    break
                } else {
                    break
                }

                if index + 2 < bytes.count {
                    result.append([UInt8].encodingtable.base32hex.encode[Int(c5)])
                } else if padding {
                    result.append(contentsOf: [[UInt8].encodingtable.padding, [UInt8].encodingtable.padding,
                                              [UInt8].encodingtable.padding, [UInt8].encodingtable.padding])
                    break
                } else {
                    break
                }

                if index + 3 < bytes.count {
                    result.append([UInt8].encodingtable.base32hex.encode[Int(c6)])
                    result.append([UInt8].encodingtable.base32hex.encode[Int(c7)])
                } else if padding {
                    result.append(contentsOf: [[UInt8].encodingtable.padding, [UInt8].encodingtable.padding,
                                              [UInt8].encodingtable.padding])
                    break
                } else {
                    break
                }

                if index + 4 < bytes.count {
                    result.append([UInt8].encodingtable.base32hex.encode[Int(c8)])
                } else if padding {
                    result.append([UInt8].encodingtable.padding)
                    break
                } else {
                    break
                }

                index += 5
            }

            return result
        }

        /// Decodes Base32-HEX encoded string (case-insensitive)
        /// - Parameter string: Base32-HEX encoded string
        /// - Returns: Decoded bytes, or nil if invalid
        public static func decode(_ string: String) -> [UInt8]? {
            let bytes = Array(string.utf8)
            guard !bytes.isEmpty else { return [] }

            let decodeTable = [UInt8].encodingtable.base32hex.decode
            var result = [UInt8]()
            result.reserveCapacity((bytes.count * 5) / 8)

            var index = 0
            while index < bytes.count {
                // Skip whitespace
                while index < bytes.count && bytes[index].isEncodingWhitespace {
                    index += 1
                }
                if index >= bytes.count { break }

                let remaining = bytes.count - index
                if remaining < 2 { return nil }

                var values = [UInt8]()
                for i in 0..<8 {
                    if index + i >= bytes.count { break }
                    let byte = bytes[index + i]
                    if byte == [UInt8].encodingtable.padding { break }
                    let value = decodeTable[Int(byte)]
                    guard value != 255 else { return nil }
                    values.append(value)
                }

                guard values.count >= 2 else { return nil }

                result.append((values[0] << 3) | (values[1] >> 2))

                if values.count >= 4 {
                    result.append((values[1] << 6) | (values[2] << 1) | (values[3] >> 4))
                }

                if values.count >= 5 {
                    result.append((values[3] << 4) | (values[4] >> 1))
                }

                if values.count >= 7 {
                    result.append((values[4] << 7) | (values[5] << 2) | (values[6] >> 3))
                }

                if values.count >= 8 {
                    result.append((values[6] << 5) | values[7])
                }

                index += 8
            }

            return result
        }
    }

    // MARK: - Hex (Section 8)

    /// Hexadecimal encoding (RFC 4648 Section 8)
    public enum Hex {
        /// Encodes bytes to hexadecimal
        /// - Parameters:
        ///   - bytes: The bytes to encode
        ///   - uppercase: Whether to use uppercase hex digits (default: false)
        /// - Returns: Hex encoded bytes
        public static func encode(_ bytes: [UInt8], uppercase: Bool = false) -> [UInt8] {
            guard !bytes.isEmpty else { return [] }

            var result = [UInt8]()
            result.reserveCapacity(bytes.count * 2)

            let table = uppercase ? [UInt8].encodingtable.hex.encodeUppercase : [UInt8].encodingtable.hex.encode

            for byte in bytes {
                let high = (byte >> 4) & 0x0F
                let low = byte & 0x0F
                result.append(table[Int(high)])
                result.append(table[Int(low)])
            }

            return result
        }

        /// Decodes hexadecimal encoded string (case-insensitive)
        /// - Parameter string: Hex encoded string
        /// - Returns: Decoded bytes, or nil if invalid
        public static func decode(_ string: String) -> [UInt8]? {
            let bytes = Array(string.utf8)
            guard !bytes.isEmpty else { return [] }

            // Skip optional "0x" prefix
            var startIndex = 0
            if bytes.count >= 2 && bytes[0] == 0x30 && (bytes[1] == 0x78 || bytes[1] == 0x58) {
                startIndex = 2
            }

            // Filter out whitespace
            let hexBytes = bytes[startIndex...].filter { !$0.isEncodingWhitespace }

            // Hex encoding must have even number of characters
            guard hexBytes.count % 2 == 0 else { return nil }

            let decodeTable = [UInt8].encodingtable.hex.decode
            var result = [UInt8]()
            result.reserveCapacity(hexBytes.count / 2)

            var index = hexBytes.startIndex
            while index < hexBytes.endIndex {
                let highIdx = hexBytes.index(after: index)
                guard highIdx < hexBytes.endIndex else { return nil }

                let high = decodeTable[Int(hexBytes[index])]
                let low = decodeTable[Int(hexBytes[highIdx])]

                guard high != 255 && low != 255 else { return nil }

                result.append((high << 4) | low)
                index = hexBytes.index(after: highIdx)
            }

            return result
        }
    }
}
