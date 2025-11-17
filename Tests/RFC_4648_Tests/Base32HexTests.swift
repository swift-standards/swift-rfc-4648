// Base32.HexTests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 7: Base32-HEX Encoding (Extended Hex Alphabet)

import Testing
import RFC_4648

@Suite("Base32-HEX Encoding Tests")
struct Base32HexTests {

    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test("RFC 4648 test vectors", arguments: [
        ("", ""),
        ("f", "CO======"),
        ("fo", "CPNG===="),
        ("foo", "CPNMU==="),
        ("foob", "CPNMUOG="),
        ("fooba", "CPNMUOJ1"),
        ("foobar", "CPNMUOJ1E8======")
    ])
    func testRFCVectors(input: String, expected: String) {
        let bytes = Array(input.utf8)
        let encoded = String(base32HexEncoding: bytes)
        #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == bytes, "Round-trip failed for '\(input)'")
    }

    // MARK: - Alphabet Tests

    @Test("Base32-HEX uses correct alphabet (0-9, A-V)")
    func testAlphabetRange() {
        let input: [UInt8] = Array("The quick brown fox jumps over the lazy dog".utf8)
        let encoded = String(base32HexEncoding: input, padding: false)

        for char in encoded {
            let isValid = (char >= "0" && char <= "9") || (char >= "A" && char <= "V")
            #expect(isValid)
        }
    }

    @Test("Base32-HEX differs from Base32")
    func testDifferentFromBase32() {
        let input: [UInt8] = Array("foo".utf8)

        let base32 = String(base32Encoding: input, padding: false)
        let base32hex = String(base32HexEncoding: input, padding: false)

        // Different encodings
        #expect(base32 != base32hex)

        // But both decode correctly
        #expect([UInt8](base32Encoded: base32) == input)
        #expect([UInt8](base32HexEncoded: base32hex) == input)
    }

    // MARK: - Case Insensitivity Tests

    @Test("Base32-HEX decoding is case-insensitive", arguments: [
        "CPNMU===",  // uppercase
        "cpnmu===",  // lowercase
        "CpNmU===",  // mixed case
        "cPnMu==="   // random mixed case
    ])
    func testCaseInsensitive(encoded: String) {
        let expected: [UInt8] = Array("foo".utf8)
        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == expected, "Case-insensitive decoding should work for '\(encoded)'")
    }

    @Test("Base32-HEX encoding produces uppercase")
    func testEncodingProducesUppercase() {
        let input: [UInt8] = Array("hello".utf8)
        let encoded = String(base32HexEncoding: input)

        // All letters should be uppercase (A-V)
        for char in encoded {
            if char.isLetter {
                #expect(char.isUppercase)
            }
        }
    }

    // MARK: - Padding Tests

    @Test("Base32-HEX encoding without padding")
    func testNoPadding() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base32HexEncoding: input, padding: false)
        #expect(encoded == "CO")
        #expect(!encoded.contains("="))
    }

    @Test("Base32-HEX encoding with padding")
    func testWithPadding() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base32HexEncoding: input, padding: true)
        #expect(encoded == "CO======")
    }

    @Test("Base32-HEX decoding with and without padding")
    func testDecodingPaddingVariations() {
        let input: [UInt8] = Array("foo".utf8)

        // With padding
        let withPadding = [UInt8](base32HexEncoded: "CPNMU===")
        #expect(withPadding == input)

        // Without padding
        let withoutPadding = [UInt8](base32HexEncoded: "CPNMU")
        #expect(withoutPadding == input)
    }

    // MARK: - Whitespace Handling

    @Test("Base32-HEX decoding with whitespace")
    func testWhitespaceHandling() {
        let input = "CPNMU===\nCPNG===="
        let decoded = [UInt8](base32HexEncoded: input)
        #expect(decoded != nil)
    }

    @Test("Base32-HEX decoding with tabs")
    func testTabHandling() {
        let input = "CPNMU===\t\tCPNG===="
        let decoded = [UInt8](base32HexEncoded: input)
        #expect(decoded != nil)
    }

    // MARK: - Invalid Input Tests

    @Test("Base32-HEX decoding rejects invalid input", arguments: [
        "CPNMW===",   // Base32-HEX doesn't use W
        "CPNMZ===",   // Base32-HEX doesn't use Z
        "C",          // invalid length (too short)
        "CPNM!@#$",   // special characters
        "========"    // only padding
    ])
    func testInvalidInput(input: String) {
        let decoded = [UInt8](base32HexEncoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
    }

    // MARK: - Binary Data Tests

    @Test("Base32-HEX binary data")
    func testBinaryData() {
        let input: [UInt8] = [0x00, 0xFF, 0x80, 0x7F]
        let encoded = String(base32HexEncoding: input)
        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base32-HEX all zeros")
    func testAllZeros() {
        let input: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00]
        let encoded = String(base32HexEncoding: input)
        #expect(encoded == "00000000")

        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base32-HEX sequential bytes")
    func testSequentialBytes() {
        let input: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04]
        let encoded = String(base32HexEncoding: input)
        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base32-HEX all ones")
    func testAllOnes() {
        let input: [UInt8] = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        let encoded = String(base32HexEncoding: input)
        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Edge Cases

    @Test("Base32-HEX round-trip various sizes")
    func testRoundTripVariousSizes() {
        for size in [1, 2, 3, 4, 5, 10, 20, 50, 100] {
            let input: [UInt8] = (0..<size).map { UInt8($0 % 256) }
            let encoded = String(base32HexEncoding: input)
            let decoded = [UInt8](base32HexEncoded: encoded)
            #expect(decoded == input)
        }
    }

    @Test("Base32-HEX round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String(base32HexEncoding: input)
        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Lexicographic Ordering

    @Test("Base32-HEX maintains lexicographic order")
    func testLexicographicOrder() {
        // Base32-HEX is designed so encoded values maintain the same order as input
        let input1: [UInt8] = [0x00]
        let input2: [UInt8] = [0x01]
        let input3: [UInt8] = [0xFF]

        let encoded1 = String(base32HexEncoding: input1, padding: false)
        let encoded2 = String(base32HexEncoding: input2, padding: false)
        let encoded3 = String(base32HexEncoding: input3, padding: false)

        // Lexicographic order should be preserved
        #expect(encoded1 < encoded2)
        #expect(encoded2 < encoded3)
    }
}
