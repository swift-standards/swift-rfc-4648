// HexTests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 8: Base16 (Hexadecimal) Encoding

import Testing
import RFC_4648

@Suite("Hex Encoding Tests")
struct HexTests {

    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test("RFC 4648 test vector: empty")
    func testEmptyString() {
        let input: [UInt8] = []
        let encoded = String(hexEncoding: input)
        #expect(encoded == "")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: f")
    func testSingleChar() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(hexEncoding: input)
        #expect(encoded == "66")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: fo")
    func testTwoChars() {
        let input: [UInt8] = Array("fo".utf8)
        let encoded = String(hexEncoding: input)
        #expect(encoded == "666f")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foo")
    func testThreeChars() {
        let input: [UInt8] = Array("foo".utf8)
        let encoded = String(hexEncoding: input)
        #expect(encoded == "666f6f")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foob")
    func testFourChars() {
        let input: [UInt8] = Array("foob".utf8)
        let encoded = String(hexEncoding: input)
        #expect(encoded == "666f6f62")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: fooba")
    func testFiveChars() {
        let input: [UInt8] = Array("fooba".utf8)
        let encoded = String(hexEncoding: input)
        #expect(encoded == "666f6f6261")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foobar")
    func testSixChars() {
        let input: [UInt8] = Array("foobar".utf8)
        let encoded = String(hexEncoding: input)
        #expect(encoded == "666f6f626172")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Case Tests

    @Test("Hex encoding lowercase by default")
    func testLowercaseDefault() {
        let input: [UInt8] = [0xFF, 0xAB, 0xCD]
        let encoded = String(hexEncoding: input)
        #expect(encoded == "ffabcd")
    }

    @Test("Hex encoding uppercase when requested")
    func testUppercaseOption() {
        let input: [UInt8] = [0xFF, 0xAB, 0xCD]
        let encoded = String(hexEncoding: input, uppercase: true)
        #expect(encoded == "FFABCD")
    }

    @Test("Hex decoding is case-insensitive")
    func testDecodingCaseInsensitive() {
        let input: [UInt8] = [0xFF, 0xAB]

        // Lowercase
        let lowercase = [UInt8](hexEncoded: "ffab")
        #expect(lowercase == input)

        // Uppercase
        let uppercase = [UInt8](hexEncoded: "FFAB")
        #expect(uppercase == input)

        // Mixed case
        let mixed = [UInt8](hexEncoded: "FfAb")
        #expect(mixed == input)
    }

    // MARK: - Prefix Tests

    @Test("Hex decoding with 0x prefix")
    func testWithPrefix() {
        let input = "0xFF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == [0xFF])
    }

    @Test("Hex decoding with 0X prefix (uppercase)")
    func testWithUppercasePrefix() {
        let input = "0XFF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == [0xFF])
    }

    @Test("Hex decoding without prefix")
    func testWithoutPrefix() {
        let input = "FF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == [0xFF])
    }

    @Test("Hex decoding multiple bytes with prefix")
    func testMultipleBytesWithPrefix() {
        let input = "0xDEADBEEF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == [0xDE, 0xAD, 0xBE, 0xEF])
    }

    // MARK: - Whitespace Handling

    @Test("Hex decoding with spaces")
    func testSpaceHandling() {
        let input = "DE AD BE EF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == [0xDE, 0xAD, 0xBE, 0xEF])
    }

    @Test("Hex decoding with newlines")
    func testNewlineHandling() {
        let input = "DE\nAD\nBE\nEF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == [0xDE, 0xAD, 0xBE, 0xEF])
    }

    @Test("Hex decoding with tabs")
    func testTabHandling() {
        let input = "DE\tAD\tBE\tEF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == [0xDE, 0xAD, 0xBE, 0xEF])
    }

    @Test("Hex decoding with mixed whitespace")
    func testMixedWhitespace() {
        let input = "DE AD\nBE\tEF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == [0xDE, 0xAD, 0xBE, 0xEF])
    }

    // MARK: - Invalid Input Tests

    @Test("Hex decoding invalid characters")
    func testInvalidCharacters() {
        let input = "GGGG"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == nil)
    }

    @Test("Hex decoding odd length")
    func testOddLength() {
        let input = "FFF"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == nil)
    }

    @Test("Hex decoding special characters")
    func testInvalidSpecialCharacters() {
        let input = "FF!!"
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == nil)
    }

    // MARK: - Binary Data Tests

    @Test("Hex encoding all byte values")
    func testAllByteValues() {
        for byte in 0...255 {
            let input: [UInt8] = [UInt8(byte)]
            let encoded = String(hexEncoding: input)
            let decoded = [UInt8](hexEncoded: encoded)
            #expect(decoded == input)
        }
    }

    @Test("Hex encoding all zeros")
    func testAllZeros() {
        let input: [UInt8] = [0x00, 0x00, 0x00]
        let encoded = String(hexEncoding: input)
        #expect(encoded == "000000")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Hex encoding all ones")
    func testAllOnes() {
        let input: [UInt8] = [0xFF, 0xFF, 0xFF]
        let encoded = String(hexEncoding: input)
        #expect(encoded == "ffffff")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Hex encoding sequential bytes")
    func testSequentialBytes() {
        let input: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05]
        let encoded = String(hexEncoding: input)
        #expect(encoded == "000102030405")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Common Use Cases

    @Test("Hex encoding SHA-256 hash")
    func testSHA256Hash() {
        // Typical SHA-256 hash: 32 bytes
        let hash: [UInt8] = [
            0xe3, 0xb0, 0xc4, 0x42, 0x98, 0xfc, 0x1c, 0x14,
            0x9a, 0xfb, 0xf4, 0xc8, 0x99, 0x6f, 0xb9, 0x24,
            0x27, 0xae, 0x41, 0xe4, 0x64, 0x9b, 0x93, 0x4c,
            0xa4, 0x95, 0x99, 0x1b, 0x78, 0x52, 0xb8, 0x55
        ]

        let encoded = String(hexEncoding: hash)
        #expect(encoded.count == 64) // 32 bytes * 2 chars per byte

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == hash)
    }

    @Test("Hex encoding UUID bytes")
    func testUUIDBytes() {
        // Typical UUID: 16 bytes
        let uuid: [UInt8] = [
            0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
            0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0
        ]

        let encoded = String(hexEncoding: uuid)
        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == uuid)
    }

    @Test("Hex encoding color values")
    func testColorValues() {
        // RGB color: #FF5733
        let color: [UInt8] = [0xFF, 0x57, 0x33]
        let encoded = String(hexEncoding: color, uppercase: true)
        #expect(encoded == "FF5733")

        let decoded = [UInt8](hexEncoded: "#FF5733")
        #expect(decoded == nil) // # is not valid hex

        let decoded2 = [UInt8](hexEncoded: "FF5733")
        #expect(decoded2 == color)
    }

    // MARK: - Edge Cases

    @Test("Hex round-trip various sizes")
    func testRoundTripVariousSizes() {
        for size in [1, 2, 10, 100, 1000] {
            let input: [UInt8] = (0..<size).map { UInt8($0 % 256) }
            let encoded = String(hexEncoding: input)
            let decoded = [UInt8](hexEncoded: encoded)
            #expect(decoded == input)
        }
    }

    @Test("Hex round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String(hexEncoding: input)
        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Format Variations

    @Test("Hex decoding common format variations")
    func testFormatVariations() {
        let expected: [UInt8] = [0xDE, 0xAD]

        // Standard
        #expect([UInt8](hexEncoded: "DEAD") == expected)

        // With 0x prefix
        #expect([UInt8](hexEncoded: "0xDEAD") == expected)

        // With spaces
        #expect([UInt8](hexEncoded: "DE AD") == expected)

        // Lowercase
        #expect([UInt8](hexEncoded: "dead") == expected)

        // Mixed case
        #expect([UInt8](hexEncoded: "DeAd") == expected)
    }

    @Test("Hex encoding produces consistent output")
    func testConsistentOutput() {
        let input: [UInt8] = [0xAB, 0xCD, 0xEF]

        let encoded1 = String(hexEncoding: input)
        let encoded2 = String(hexEncoding: input)

        #expect(encoded1 == encoded2)
    }
}
