// Base32.swift
// swift-rfc-4648
//
// RFC 4648 Section 6: Base32 Encoding

extension String {
    /// Creates a Base32 encoded string from bytes (RFC 4648 Section 6)
    /// Base32 uses 32-character alphabet (A-Z, 2-7), case-insensitive for decoding
    /// - Parameters:
    ///   - base32Encoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    public init(base32Encoding bytes: [UInt8], padding: Bool = true) {
        guard !bytes.isEmpty else {
            self = ""
            return
        }

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

            result.append(EncodingTables.base32[Int(c1)])
            result.append(EncodingTables.base32[Int(c2)])

            if index + 1 < bytes.count {
                result.append(EncodingTables.base32[Int(c3)])
                result.append(EncodingTables.base32[Int(c4)])
            } else if padding {
                result.append(contentsOf: [EncodingTables.paddingCharacter, EncodingTables.paddingCharacter,
                                          EncodingTables.paddingCharacter, EncodingTables.paddingCharacter,
                                          EncodingTables.paddingCharacter, EncodingTables.paddingCharacter])
                break
            } else {
                break
            }

            if index + 2 < bytes.count {
                result.append(EncodingTables.base32[Int(c5)])
            } else if padding {
                result.append(contentsOf: [EncodingTables.paddingCharacter, EncodingTables.paddingCharacter,
                                          EncodingTables.paddingCharacter, EncodingTables.paddingCharacter])
                break
            } else {
                break
            }

            if index + 3 < bytes.count {
                result.append(EncodingTables.base32[Int(c6)])
                result.append(EncodingTables.base32[Int(c7)])
            } else if padding {
                result.append(contentsOf: [EncodingTables.paddingCharacter, EncodingTables.paddingCharacter,
                                          EncodingTables.paddingCharacter])
                break
            } else {
                break
            }

            if index + 4 < bytes.count {
                result.append(EncodingTables.base32[Int(c8)])
            } else if padding {
                result.append(EncodingTables.paddingCharacter)
                break
            } else {
                break
            }

            index += 5
        }

        self = String(decoding: result, as: UTF8.self)
    }
}

extension [UInt8] {
    /// Creates an array from a Base32 encoded string (RFC 4648 Section 6)
    /// - Parameter base32Encoded: Base32 encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base32
    public init?(base32Encoded string: String) {
        let bytes = Array(string.utf8)
        guard !bytes.isEmpty else {
            self = []
            return
        }

        let decodeTable = EncodingTables.base32Decode
        var result = [UInt8]()
        result.reserveCapacity((bytes.count * 5) / 8)

        var index = 0
        while index < bytes.count {
            // Skip whitespace
            while index < bytes.count && bytes[index].isEncodingWhitespace {
                index += 1
            }
            if index >= bytes.count { break }

            // Base32 groups are 8 characters (or less with padding)
            let remaining = bytes.count - index
            if remaining < 2 { return nil }

            var values = [UInt8]()
            for i in 0..<8 {
                if index + i >= bytes.count { break }
                let byte = bytes[index + i]
                if byte == EncodingTables.paddingCharacter { break }
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

        self = result
    }
}
