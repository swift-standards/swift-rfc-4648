//
//  RFC_4648.Base32.Hex.swift
//  swift-rfc-4648
//
//  Base32-HEX encoding per RFC 4648 Section 7

import INCITS_4_1986

// MARK: - Base32-HEX Type

extension RFC_4648.Base32 {
    /// Base32-HEX encoding (RFC 4648 Section 7) - Extended Hex Alphabet
    ///
    /// Base32-HEX uses a 32-character alphabet (0-9, A-V) that preserves
    /// lexicographic sort order when the encoded data is sorted as bytes.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base32.Hex.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base32.Hex.decode("91IMOR3F")
    ///
    /// // Instance methods (convenience) - via base32.hex
    /// bytes.base32.hex.encoded()
    /// "91IMOR3F".base32.hex.decoded()
    /// ```
    public enum Hex {
        /// Wrapper for instance-based convenience methods
        public struct Wrapper<Wrapped> {
            public let wrapped: Wrapped

            @inlinable
            public init(_ wrapped: Wrapped) {
                self.wrapped = wrapped
            }
        }
    }
}

// MARK: - Encoding Table

extension RFC_4648.Base32.Hex {
    /// Base32-HEX encoding table (RFC 4648 Section 7)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: Array("0123456789ABCDEFGHIJKLMNOPQRSTUV".utf8),
        caseInsensitive: true
    )
}

// MARK: - Encoder (for String.base32.hex(...) syntax)

extension RFC_4648.Base32.Hex {
    /// Encoder for `String.base32.hex(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base32.hex([72, 101, 108, 108, 111])  // "91IMOR3F"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to Base32-HEX string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            padding: Bool = true
        ) -> String where Bytes.Element == UInt8 {
            String(decoding: RFC_4648.Base32.Hex.encode(bytes, padding: padding), as: UTF8.self)
        }

        /// Encodes an integer to Base32-HEX string (big-endian byte order)
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            padding: Bool = true
        ) -> String {
            callAsFunction(value.bytes(endianness: .big), padding: padding)
        }
    }
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base32.Hex {
    /// Encodes bytes to Base32-HEX into a buffer (streaming)
    ///
    /// Base32-HEX encodes 5 bytes into 8 characters.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append Base32-HEX characters to
    ///   - padding: Whether to include padding characters (default: true)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// RFC_4648.Base32.Hex.encode("Hello".utf8, into: &buffer)
    /// // buffer contains "91IMOR3F" as bytes
    /// ```
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        guard !bytes.isEmpty else { return }

        let table = encodingTable.encode
        var iterator = bytes.makeIterator()

        while let b1 = iterator.next() {
            let b2 = iterator.next()
            let b3 = iterator.next()
            let b4 = iterator.next()
            let b5 = iterator.next()

            // First character: high 5 bits of b1
            buffer.append(table[Int((b1 >> 3) & 0x1F)])

            // Second character: low 2 bits of b1 + high 3 bits of b2
            let c2 = ((b1 << 2) | ((b2 ?? 0) >> 6)) & 0x1F
            buffer.append(table[Int(c2)])

            guard let b2 = b2 else {
                if padding {
                    buffer.append(contentsOf: [RFC_4648.padding, RFC_4648.padding,
                                               RFC_4648.padding, RFC_4648.padding,
                                               RFC_4648.padding, RFC_4648.padding])
                }
                break
            }

            // Third character: bits 5-1 of b2
            buffer.append(table[Int((b2 >> 1) & 0x1F)])

            // Fourth character: low 1 bit of b2 + high 4 bits of b3
            let c4 = ((b2 << 4) | ((b3 ?? 0) >> 4)) & 0x1F
            buffer.append(table[Int(c4)])

            guard let b3 = b3 else {
                if padding {
                    buffer.append(contentsOf: [RFC_4648.padding, RFC_4648.padding,
                                               RFC_4648.padding, RFC_4648.padding])
                }
                break
            }

            // Fifth character: low 4 bits of b3 + high 1 bit of b4
            let c5 = ((b3 << 1) | ((b4 ?? 0) >> 7)) & 0x1F
            buffer.append(table[Int(c5)])

            guard let b4 = b4 else {
                if padding {
                    buffer.append(contentsOf: [RFC_4648.padding, RFC_4648.padding, RFC_4648.padding])
                }
                break
            }

            // Sixth character: bits 6-2 of b4
            buffer.append(table[Int((b4 >> 2) & 0x1F)])

            // Seventh character: low 2 bits of b4 + high 3 bits of b5
            let c7 = ((b4 << 3) | ((b5 ?? 0) >> 5)) & 0x1F
            buffer.append(table[Int(c7)])

            guard let b5 = b5 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            // Eighth character: low 5 bits of b5
            buffer.append(table[Int(b5 & 0x1F)])
        }
    }

    /// Encodes bytes to Base32-HEX, returning a new array
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    /// - Returns: Base32-HEX encoded bytes
    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = true
    ) -> [UInt8] where Bytes.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity(((bytes.count + 4) / 5) * 8)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base32.Hex {
    /// Decodes a single Base32-HEX character to its 5-bit value (PRIMITIVE)
    ///
    /// - Parameter quintet: ASCII byte of Base32-HEX character (0-9, A-V, case-insensitive)
    /// - Returns: 5-bit value (0-31), or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base32.Hex.decode(quintet: UInt8(ascii: "0"))  // 0
    /// RFC_4648.Base32.Hex.decode(quintet: UInt8(ascii: "V"))  // 31
    /// RFC_4648.Base32.Hex.decode(quintet: UInt8(ascii: "W"))  // nil (invalid)
    /// ```
    @inlinable
    public static func decode(quintet: UInt8) -> UInt8? {
        let value = encodingTable.decode[Int(quintet)]
        return value == 255 ? nil : value
    }

    /// Decodes Base32-HEX bytes into a buffer (streaming, no allocation)
    ///
    /// - Parameters:
    ///   - bytes: Base32-HEX encoded bytes
    ///   - buffer: The buffer to append decoded bytes to
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// let success = RFC_4648.Base32.Hex.decode("91IMOR3F".utf8, into: &buffer)
    /// // buffer == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer
    ) -> Bool where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        guard !bytes.isEmpty else { return true }

        let decodeTable = encodingTable.decode
        var iterator = bytes.makeIterator()

        // Collect up to 8 quintets at a time
        var values = [UInt8]()
        values.reserveCapacity(8)

        var hasDecodedAny = false

        while true {
            values.removeAll(keepingCapacity: true)
            var hitPadding = false

            // Collect quintets for this group
            while values.count < 8 {
                guard let byte = iterator.next() else { break }
                if byte == RFC_4648.padding { hitPadding = true; break }
                if byte.ascii.isWhitespace { continue }
                let value = decodeTable[Int(byte)]
                guard value != 255 else { return false }
                values.append(value)
            }

            // All-padding without data is invalid
            if values.isEmpty && hitPadding && !hasDecodedAny { return false }
            if values.isEmpty { break }
            guard values.count >= 2 else { return false }
            hasDecodedAny = true

            // First byte: 5 bits from v1 + high 3 bits from v2
            buffer.append((values[0] << 3) | (values[1] >> 2))

            if values.count >= 4 {
                // Second byte
                buffer.append((values[1] << 6) | (values[2] << 1) | (values[3] >> 4))
            }

            if values.count >= 5 {
                // Third byte
                buffer.append((values[3] << 4) | (values[4] >> 1))
            }

            if values.count >= 7 {
                // Fourth byte
                buffer.append((values[4] << 7) | (values[5] << 2) | (values[6] >> 3))
            }

            if values.count >= 8 {
                // Fifth byte
                buffer.append((values[6] << 5) | values[7])
            }

            if values.count < 8 { break }
        }

        return true
    }

    /// Decodes Base32-HEX encoded bytes to a new array
    ///
    /// - Parameter bytes: Base32-HEX encoded bytes
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base32.Hex.decode("91IMOR3F".utf8)
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes
    ) -> [UInt8]? where Bytes.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity((bytes.count * 5) / 8)
        guard decode(bytes, into: &result) else { return nil }
        return result
    }

    /// Decodes Base32-HEX encoded string (case-insensitive)
    ///
    /// Convenience overload that delegates to the byte-based version.
    ///
    /// - Parameter string: Base32-HEX encoded string
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base32.Hex.decode("91IMOR3F")
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode(_ string: some StringProtocol) -> [UInt8]? {
        decode(string.utf8)
    }

    /// Decodes Base32-HEX to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes Base32-HEX bytes directly to an integer value without intermediate array allocation.
    ///
    /// - Parameter bytes: Base32-HEX encoded bytes
    /// - Returns: Decoded integer value, or nil if invalid or overflow
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: UInt32? = RFC_4648.Base32.Hex.decode("64P36D1L".utf8)
    /// // value == 0x31323334 ("1234" as bytes)
    /// ```
    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self
    ) -> T? where Bytes.Element == UInt8 {
        guard !bytes.isEmpty else { return 0 }

        let decodeTable = encodingTable.decode
        var iterator = bytes.makeIterator()
        var result: T = 0
        var bitCount = 0
        let maxBits = T.bitWidth

        while let byte = iterator.next() {
            if byte == RFC_4648.padding { break }
            guard !byte.ascii.isWhitespace else { continue }

            let value = decodeTable[Int(byte)]
            guard value != 255 else { return nil }

            bitCount += 5
            guard bitCount <= maxBits else { return nil } // overflow

            result = (result << 5) | T(value)
        }

        return result
    }
}

// MARK: - Instance Methods (Convenience) - Bytes

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: Collection, Wrapped.Element == UInt8 {
    // MARK: Encoding (bytes → Base32-HEX)

    /// Encodes wrapped bytes to Base32-HEX into a buffer
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.encode(_:into:padding:)`.
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Buffer.Element == UInt8 {
        RFC_4648.Base32.Hex.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base32-HEX string
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.encode(_:padding:)`.
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        String(decoding: RFC_4648.Base32.Hex.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base32-HEX string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = true) -> String {
        encoded(padding: padding)
    }

    // MARK: Decoding (Base32-HEX bytes → raw bytes)

    /// Decodes wrapped Base32-HEX-encoded bytes into a buffer
    ///
    /// Treats the wrapped bytes as ASCII Base32-HEX characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base32.Hex.decode(wrapped, into: &buffer)
    }

    /// Decodes wrapped Base32-HEX-encoded bytes to raw bytes
    ///
    /// Treats the wrapped bytes as ASCII Base32-HEX characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base32.Hex.decode(wrapped)
    }

    /// Decodes wrapped Base32-HEX-encoded bytes to a FixedWidthInteger
    ///
    /// Treats the wrapped bytes as ASCII Base32-HEX characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.Hex.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base32-HEX string into a buffer
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base32.Hex.decode(wrapped.utf8, into: &buffer)
    }

    /// Decodes wrapped Base32-HEX string to bytes
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base32.Hex.decode(wrapped)
    }

    /// Decodes wrapped Base32-HEX string to a FixedWidthInteger
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.Hex.decode(wrapped.utf8, as: type)
    }
}
