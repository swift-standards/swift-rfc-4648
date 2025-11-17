// Base32Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 6: Base32 Encoding

import Testing
import RFC_4648

@Suite("Base32 Encoding Tests")
struct Base32Tests {

    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test("RFC 4648 test vectors", arguments: [
        ("", ""),
        ("f", "MY======"),
        ("fo", "MZXQ===="),
        ("foo", "MZXW6==="),
        ("foob", "MZXW6YQ="),
        ("fooba", "MZXW6YTB"),
        ("foobar", "MZXW6YTBOI======")
    ])
    func testRFCVectors(input: String, expected: String) {
        let bytes = Array(input.utf8)
        let encoded = String(base32Encoding: bytes)
        #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == bytes, "Round-trip failed for '\(input)'")
    }

    // MARK: - Case Insensitivity Tests

    @Test("Base32 decoding is case-insensitive", arguments: [
        "MZXW6===",  // uppercase
        "mzxw6===",  // lowercase
        "MzXw6===",  // mixed case
        "mZxW6==="   // random mixed case
    ])
    func testCaseInsensitive(encoded: String) {
        let expected: [UInt8] = Array("foo".utf8)
        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == expected, "Case-insensitive decoding should work for '\(encoded)'")
    }

    @Test("Base32 encoding produces uppercase")
    func testEncodingProducesUppercase() {
        let input: [UInt8] = Array("hello".utf8)
        let encoded = String(base32Encoding: input)

        // All letters should be uppercase (A-Z)
        for char in encoded {
            if char.isLetter {
                #expect(char.isUppercase)
            }
        }
    }

    // MARK: - Padding Tests

    @Test("Base32 encoding without padding")
    func testNoPadding() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base32Encoding: input, padding: false)
        #expect(encoded == "MY")
        #expect(!encoded.contains("="))
    }

    @Test("Base32 encoding with padding")
    func testWithPadding() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base32Encoding: input, padding: true)
        #expect(encoded == "MY======")
    }

    @Test("Base32 decoding with and without padding")
    func testDecodingPaddingVariations() {
        let input: [UInt8] = Array("foo".utf8)

        // With padding
        let withPadding = [UInt8](base32Encoded: "MZXW6===")
        #expect(withPadding == input)

        // Without padding
        let withoutPadding = [UInt8](base32Encoded: "MZXW6")
        #expect(withoutPadding == input)
    }

    // MARK: - Whitespace Handling

    @Test("Base32 decoding with whitespace")
    func testWhitespaceHandling() {
        let input = "MZXW6===\nYTBOI==="
        let decoded = [UInt8](base32Encoded: input)
        #expect(decoded != nil)
    }

    @Test("Base32 decoding with tabs and spaces")
    func testTabAndSpaceHandling() {
        let input = "MZXW6=== \tMZXQ===="
        let decoded = [UInt8](base32Encoded: input)
        #expect(decoded != nil)
    }

    // MARK: - Invalid Input Tests

    @Test("Base32 decoding rejects invalid input", arguments: [
        "MZXW0===",   // Base32 doesn't use 0
        "MZXW1===",   // Base32 doesn't use 1
        "MZXW8===",   // Base32 doesn't use 8
        "MZXW9===",   // Base32 doesn't use 9
        "M",          // invalid length (too short)
        "MZXW!@#$",   // special characters
        "========",   // only padding
    ])
    func testInvalidInput(input: String) {
        let decoded = [UInt8](base32Encoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
    }

    // MARK: - Alphabet Tests

    @Test("Base32 uses correct alphabet (A-Z, 2-7)")
    func testAlphabetRange() {
        // Test that all characters in encoding are within A-Z, 2-7 range
        let input: [UInt8] = Array("The quick brown fox jumps over the lazy dog".utf8)
        let encoded = String(base32Encoding: input, padding: false)

        for char in encoded {
            let isValid = (char >= "A" && char <= "Z") || (char >= "2" && char <= "7")
            #expect(isValid)
        }
    }

    // MARK: - Binary Data Tests

    @Test("Base32 binary data")
    func testBinaryData() {
        let input: [UInt8] = [0x00, 0xFF, 0x80, 0x7F]
        let encoded = String(base32Encoding: input)
        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base32 all zeros")
    func testAllZeros() {
        let input: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00]
        let encoded = String(base32Encoding: input)
        #expect(encoded == "AAAAAAAA")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base32 sequential bytes")
    func testSequentialBytes() {
        let input: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04]
        let encoded = String(base32Encoding: input)
        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - TOTP/HOTP Use Cases

    @Test("Base32 secret key (typical TOTP use)")
    func testTOTPSecretKey() {
        // Typical TOTP secret: 20 random bytes
        let secret: [UInt8] = [
            0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0xDE, 0xAD,
            0xBE, 0xEF, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21,
            0xDE, 0xAD, 0xBE, 0xEF
        ]

        let encoded = String(base32Encoding: secret, padding: false)

        // Should be decodable case-insensitively
        let decoded = [UInt8](base32Encoded: encoded.lowercased())
        #expect(decoded == secret)
    }

    // MARK: - Edge Cases

    @Test("Base32 round-trip various sizes")
    func testRoundTripVariousSizes() {
        for size in [1, 2, 3, 4, 5, 10, 20, 50, 100] {
            let input: [UInt8] = (0..<size).map { UInt8($0 % 256) }
            let encoded = String(base32Encoding: input)
            let decoded = [UInt8](base32Encoded: encoded)
            #expect(decoded == input)
        }
    }

    @Test("Base32 round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String(base32Encoding: input)
        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }
}
