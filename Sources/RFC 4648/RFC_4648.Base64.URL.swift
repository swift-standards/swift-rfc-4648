//
//  RFC_4648.Base64.URL.swift
//  swift-rfc-4648
//
//  Created by Coen ten Thije Boonkkamp on 17/11/2025.
//

import INCITS_4_1986

extension RFC_4648.Base64 {
  // MARK: - Base64URL (Section 5)

  /// Base64URL encoding (RFC 4648 Section 5) - URL and filename safe
  public enum URL {
    /// Base64URL encoding table (RFC 4648 Section 5)
    public static let encodingTable = RFC_4648.EncodingTable(
      encode: Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".utf8)
    )

    /// Encodes bytes to Base64URL
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - padding: Whether to include padding (default: false per RFC 7515)
    /// - Returns: Base64URL encoded bytes
    public static func encode<Bytes: Collection>(
      _ bytes: Bytes,
      padding: Bool = false
    ) -> [UInt8] where Bytes.Element == UInt8 {
      guard !bytes.isEmpty else { return [] }
      let bytes = Array(bytes)

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

    /// Decodes Base64URL encoded string
    /// - Parameter string: Base64URL encoded string
    /// - Returns: Decoded bytes, or nil if invalid
    public static func decode(_ string: some StringProtocol) -> [UInt8]? {
      let bytes = Array(string.utf8)
      guard !bytes.isEmpty else { return [] }

      let decodeTable = encodingTable.decode
      var result = [UInt8]()
      result.reserveCapacity((bytes.count * 3) / 4)

      var index = 0
      while index < bytes.count {
        // Skip whitespace
        while index < bytes.count, bytes[index].ascii.isWhitespace {
          index += 1
        }
        if index >= bytes.count { break }

        // Base64URL allows missing padding
        let remaining = bytes.count - index
        if remaining < 2 { return nil }

        let c1 = decodeTable[Int(bytes[index])]
        let c2 = decodeTable[Int(bytes[index + 1])]

        guard c1 != 255, c2 != 255 else { return nil }

        let b1 = (c1 << 2) | (c2 >> 4)
        result.append(b1)

        if remaining >= 3, bytes[index + 2] != RFC_4648.padding {
          let c3 = decodeTable[Int(bytes[index + 2])]
          guard c3 != 255 else { return nil }

          let b2 = ((c2 & 0x0F) << 4) | (c3 >> 2)
          result.append(b2)

          if remaining >= 4, bytes[index + 3] != RFC_4648.padding {
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

    // MARK: - Collection Wrapper

    /// Wrapper for Base64URL operations on byte collections
    public struct CollectionWrapper<Bytes: Collection> where Bytes.Element == UInt8 {
      public let bytes: Bytes

      @inlinable
      public init(_ bytes: Bytes) {
        self.bytes = bytes
      }

      /// Encodes bytes to Base64URL string
      @inlinable
      public func callAsFunction(padding: Bool = false) -> String {
        encoded(padding: padding)
      }

      /// Encodes bytes to Base64URL string
      @inlinable
      public func encoded(padding: Bool = false) -> String {
        String(decoding: RFC_4648.Base64.URL.encode(bytes, padding: padding), as: UTF8.self)
      }
    }
  }
}
