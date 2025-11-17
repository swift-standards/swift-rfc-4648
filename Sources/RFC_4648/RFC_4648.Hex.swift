//
//  RFC_4648.Hex.swift
//  swift-rfc-4648
//
//  Created by Coen ten Thije Boonkkamp on 17/11/2025.
//

import INCITS_4_1986

extension RFC_4648 {

    // MARK: - Hex (Section 8)

    /// Hexadecimal encoding (RFC 4648 Section 8)
    public enum Hex {
        /// Hexadecimal encoding table - lowercase (RFC 4648 Section 8)
        public static let encodingTable = EncodingTable(
            encode: Array("0123456789abcdef".utf8),
            decode: {
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
        )

        /// Hexadecimal encoding table - uppercase (RFC 4648 Section 8)
        public static let encodingTableUppercase = EncodingTable(
            encode: Array("0123456789ABCDEF".utf8),
            decode: encodingTable.decode  // Share the same decode table
        )

        /// Encodes bytes to hexadecimal
        /// - Parameters:
        ///   - bytes: The bytes to encode
        ///   - uppercase: Whether to use uppercase hex digits (default: false)
        /// - Returns: Hex encoded bytes
        public static func encode(_ bytes: [UInt8], uppercase: Bool = false) -> [UInt8] {
            guard !bytes.isEmpty else { return [] }

            var result = [UInt8]()
            result.reserveCapacity(bytes.count * 2)

            let table = uppercase ? encodingTableUppercase.encode : encodingTable.encode

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
            let hexBytes = bytes[startIndex...].filter { !$0.isASCIIWhitespace }

            // Hex encoding must have even number of characters
            guard hexBytes.count % 2 == 0 else { return nil }

            let decodeTable = encodingTable.decode
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
