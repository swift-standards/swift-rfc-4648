// Hex.swift
// swift-rfc-4648
//
// RFC 4648 Section 8: Base16 (Hexadecimal) Encoding

extension String {
    /// Creates a hexadecimal encoded string from bytes (RFC 4648 Section 8)
    /// - Parameters:
    ///   - hexEncoding: The bytes to encode
    ///   - uppercase: Whether to use uppercase hex digits (default: false)
    public init(hexEncoding bytes: [UInt8], uppercase: Bool = false) {
        guard !bytes.isEmpty else {
            self = ""
            return
        }

        var result = [UInt8]()
        result.reserveCapacity(bytes.count * 2)

        let table = uppercase ? EncodingTables.hexUppercase : EncodingTables.hex

        for byte in bytes {
            let high = (byte >> 4) & 0x0F
            let low = byte & 0x0F
            result.append(table[Int(high)])
            result.append(table[Int(low)])
        }

        self = String(decoding: result, as: UTF8.self)
    }
}

extension [UInt8] {
    /// Creates an array from a hexadecimal encoded string (RFC 4648 Section 8)
    /// - Parameter hexEncoded: Hexadecimal encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid hex
    public init?(hexEncoded string: String) {
        let bytes = Array(string.utf8)
        guard !bytes.isEmpty else {
            self = []
            return
        }

        // Skip optional "0x" prefix
        var startIndex = 0
        if bytes.count >= 2 && bytes[0] == 0x30 && (bytes[1] == 0x78 || bytes[1] == 0x58) {
            startIndex = 2
        }

        // Filter out whitespace
        let hexBytes = bytes[startIndex...].filter { !$0.isEncodingWhitespace }

        // Hex encoding must have even number of characters
        guard hexBytes.count % 2 == 0 else { return nil }

        let decodeTable = EncodingTables.hexDecode
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

        self = result
    }
}
