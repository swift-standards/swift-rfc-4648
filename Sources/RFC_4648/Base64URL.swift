// Base64URL.swift
// swift-rfc-4648
//
// RFC 4648 Section 5: Base64URL Encoding (URL and filename safe)

extension String {
    /// Creates a Base64URL encoded string from bytes (RFC 4648 Section 5)
    /// Base64URL uses '-' and '_' instead of '+' and '/', making it URL and filename safe.
    /// - Parameters:
    ///   - base64URLEncoding: The bytes to encode
    ///   - padding: Whether to include padding characters (default: false per RFC 7515)
    public init(base64URLEncoding bytes: [UInt8], padding: Bool = false) {
        guard !bytes.isEmpty else {
            self = ""
            return
        }

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

            result.append(EncodingTables.base64URL[Int(c1)])
            result.append(EncodingTables.base64URL[Int(c2)])

            if index + 1 < bytes.count {
                result.append(EncodingTables.base64URL[Int(c3)])
            } else if padding {
                result.append(EncodingTables.paddingCharacter)
            }

            if index + 2 < bytes.count {
                result.append(EncodingTables.base64URL[Int(c4)])
            } else if padding {
                result.append(EncodingTables.paddingCharacter)
            }

            index += 3
        }

        self = String(decoding: result, as: UTF8.self)
    }
}

extension [UInt8] {
    /// Creates an array from a Base64URL encoded string (RFC 4648 Section 5)
    /// - Parameter base64URLEncoded: Base64URL encoded string
    /// - Returns: Decoded bytes, or nil if invalid Base64URL
    public init?(base64URLEncoded string: String) {
        let bytes = Array(string.utf8)
        guard !bytes.isEmpty else {
            self = []
            return
        }

        let decodeTable = EncodingTables.base64URLDecode
        var result = [UInt8]()
        result.reserveCapacity((bytes.count * 3) / 4)

        var index = 0
        while index < bytes.count {
            // Skip whitespace
            while index < bytes.count && bytes[index].isEncodingWhitespace {
                index += 1
            }
            if index >= bytes.count { break }

            // Base64URL allows missing padding, calculate actual group size
            let remaining = bytes.count - index
            if remaining < 2 { return nil }

            let c1 = decodeTable[Int(bytes[index])]
            let c2 = decodeTable[Int(bytes[index + 1])]

            guard c1 != 255 && c2 != 255 else { return nil }

            let b1 = (c1 << 2) | (c2 >> 4)
            result.append(b1)

            if remaining >= 3 && bytes[index + 2] != EncodingTables.paddingCharacter {
                let c3 = decodeTable[Int(bytes[index + 2])]
                guard c3 != 255 else { return nil }

                let b2 = ((c2 & 0x0F) << 4) | (c3 >> 2)
                result.append(b2)

                if remaining >= 4 && bytes[index + 3] != EncodingTables.paddingCharacter {
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

        self = result
    }
}
