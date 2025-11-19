//
//  RFC_4648.Base64.swift
//  swift-rfc-4648
//
//  Created by Coen ten Thije Boonkkamp on 17/11/2025.
//

import INCITS_4_1986

extension RFC_4648 {
  // MARK: - Base64 (Section 4)

  /// Base64 encoding (RFC 4648 Section 4)
  public enum Base64 {
    /// Base64 encoding table (RFC 4648 Section 4)
    public static let encodingTable = EncodingTable(
      encode: Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".utf8)
    )

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

        result.append(encodingTable.encode[Int(c1)])
        result.append(encodingTable.encode[Int(c2)])

        if index + 1 < bytes.count {
          result.append(encodingTable.encode[Int(c3)])
        } else if padding {
          result.append(RFC_4648.padding)
        }

        if index + 2 < bytes.count {
          result.append(encodingTable.encode[Int(c4)])
        } else if padding {
          result.append(RFC_4648.padding)
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

      let decodeTable = encodingTable.decode
      var result = [UInt8]()
      result.reserveCapacity((bytes.count * 3) / 4)

      var index = 0
      while index < bytes.count {
        // Skip whitespace
        while index < bytes.count && bytes[index].isASCIIWhitespace {
          index += 1
        }
        if index >= bytes.count { break }

        guard index + 3 < bytes.count else { return nil }

        let c1 = decodeTable[Int(bytes[index])]
        let c2 = decodeTable[Int(bytes[index + 1])]
        let c3 = bytes[index + 2] == RFC_4648.padding ? 255 : decodeTable[Int(bytes[index + 2])]
        let c4 = bytes[index + 3] == RFC_4648.padding ? 255 : decodeTable[Int(bytes[index + 3])]

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
}
