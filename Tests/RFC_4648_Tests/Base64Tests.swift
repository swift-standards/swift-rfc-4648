// Base64Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 4: Base64 Encoding

import Testing
import RFC_4648

@Suite("Base64 Encoding Tests")
struct Base64Tests {

    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test("RFC 4648 test vector: empty")
    func testEmptyString() {
        let input: [UInt8] = []
        let encoded = String(base64Encoding: input)
        #expect(encoded == "")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: f")
    func testSingleChar() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base64Encoding: input)
        #expect(encoded == "Zg==")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: fo")
    func testTwoChars() {
        let input: [UInt8] = Array("fo".utf8)
        let encoded = String(base64Encoding: input)
        #expect(encoded == "Zm8=")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foo")
    func testThreeChars() {
        let input: [UInt8] = Array("foo".utf8)
        let encoded = String(base64Encoding: input)
        #expect(encoded == "Zm9v")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foob")
    func testFourChars() {
        let input: [UInt8] = Array("foob".utf8)
        let encoded = String(base64Encoding: input)
        #expect(encoded == "Zm9vYg==")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: fooba")
    func testFiveChars() {
        let input: [UInt8] = Array("fooba".utf8)
        let encoded = String(base64Encoding: input)
        #expect(encoded == "Zm9vYmE=")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("RFC 4648 test vector: foobar")
    func testSixChars() {
        let input: [UInt8] = Array("foobar".utf8)
        let encoded = String(base64Encoding: input)
        #expect(encoded == "Zm9vYmFy")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Padding Tests

    @Test("Base64 encoding without padding")
    func testNoPadding() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base64Encoding: input, padding: false)
        #expect(encoded == "Zg")

        // Should still decode correctly
        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == nil) // Base64 requires padding or proper grouping
    }

    @Test("Base64 encoding with padding")
    func testWithPadding() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base64Encoding: input, padding: true)
        #expect(encoded == "Zg==")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Whitespace Handling

    @Test("Base64 decoding with whitespace")
    func testWhitespaceHandling() {
        let input = "Zm9v\n YmFy"
        let decoded = [UInt8](base64Encoded: input)
        #expect(decoded == Array("foobar".utf8))
    }

    @Test("Base64 decoding with tabs")
    func testTabHandling() {
        let input = "Zm9v\tYmFy"
        let decoded = [UInt8](base64Encoded: input)
        #expect(decoded == Array("foobar".utf8))
    }

    // MARK: - Invalid Input Tests

    @Test("Base64 decoding invalid characters")
    func testInvalidCharacters() {
        let input = "Zm9v!!!!"
        let decoded = [UInt8](base64Encoded: input)
        #expect(decoded == nil)
    }

    @Test("Base64 decoding invalid length")
    func testInvalidLength() {
        let input = "Zm9"
        let decoded = [UInt8](base64Encoded: input)
        #expect(decoded == nil)
    }

    // MARK: - Binary Data Tests

    @Test("Base64 encoding binary data")
    func testBinaryData() {
        let input: [UInt8] = [0x00, 0xFF, 0x80, 0x7F]
        let encoded = String(base64Encoding: input)
        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base64 encoding all zeros")
    func testAllZeros() {
        let input: [UInt8] = [0x00, 0x00, 0x00]
        let encoded = String(base64Encoding: input)
        #expect(encoded == "AAAA")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base64 encoding all ones")
    func testAllOnes() {
        let input: [UInt8] = [0xFF, 0xFF, 0xFF]
        let encoded = String(base64Encoding: input)
        #expect(encoded == "////")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Edge Cases

    @Test("Base64 round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String(base64Encoding: input)
        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }
}
