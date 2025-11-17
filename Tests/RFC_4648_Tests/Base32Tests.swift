// Base32Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 6: Base32 Encoding

import Testing
import RFC_4648

@Suite("Base32 Encoding Tests")
struct Base32Tests {

    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test("RFC 4648 test vector: empty")
    func testEmptyString() {
        let input: [UInt8] = []
        let encoded = String(base32Encoding: input)
        #expect(encoded == "")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: f")
    func testSingleChar() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base32Encoding: input)
        #expect(encoded == "MY======")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: fo")
    func testTwoChars() {
        let input: [UInt8] = Array("fo".utf8)
        let encoded = String(base32Encoding: input)
        #expect(encoded == "MZXQ====")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foo")
    func testThreeChars() {
        let input: [UInt8] = Array("foo".utf8)
        let encoded = String(base32Encoding: input)
        #expect(encoded == "MZXW6===")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foob")
    func testFourChars() {
        let input: [UInt8] = Array("foob".utf8)
        let encoded = String(base32Encoding: input)
        #expect(encoded == "MZXW6YQ=")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: fooba")
    func testFiveChars() {
        let input: [UInt8] = Array("fooba".utf8)
        let encoded = String(base32Encoding: input)
        #expect(encoded == "MZXW6YTB")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foobar")
    func testSixChars() {
        let input: [UInt8] = Array("foobar".utf8)
        let encoded = String(base32Encoding: input)
        #expect(encoded == "MZXW6YTBOI======")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Case Insensitivity Tests

    @Test("Base32 decoding is case-insensitive")
    func testCaseInsensitive() {
        let input: [UInt8] = Array("foo".utf8)

        // Uppercase
        let uppercase = [UInt8](base32Encoded: "MZXW6===")
        #expect(uppercase == input)

        // Lowercase
        let lowercase = [UInt8](base32Encoded: "mzxw6===")
        #expect(lowercase == input)

        // Mixed case
        let mixed = [UInt8](base32Encoded: "MzXw6===")
        #expect(mixed == input)
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

    @Test("Base32 decoding invalid characters")
    func testInvalidCharacters() {
        // Base32 doesn't use 0, 1, 8, 9
        let invalid1 = "MZXW0==="
        #expect([UInt8](base32Encoded: invalid1) == nil)

        let invalid2 = "MZXW1==="
        #expect([UInt8](base32Encoded: invalid2) == nil)

        let invalid3 = "MZXW8==="
        #expect([UInt8](base32Encoded: invalid3) == nil)

        let invalid4 = "MZXW9==="
        #expect([UInt8](base32Encoded: invalid4) == nil)
    }

    @Test("Base32 decoding invalid length")
    func testInvalidLength() {
        let input = "M"
        let decoded = [UInt8](base32Encoded: input)
        #expect(decoded == nil)
    }

    @Test("Base32 decoding special characters")
    func testInvalidSpecialCharacters() {
        let input = "MZXW!@#$"
        let decoded = [UInt8](base32Encoded: input)
        #expect(decoded == nil)
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
