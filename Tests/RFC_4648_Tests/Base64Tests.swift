// Base64Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 4: Base64 Encoding

import Testing
import RFC_4648

@Suite("Base64 Encoding Tests")
struct Base64Tests {

    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test("RFC 4648 test vectors", arguments: [
        ("", ""),
        ("f", "Zg=="),
        ("fo", "Zm8="),
        ("foo", "Zm9v"),
        ("foob", "Zm9vYg=="),
        ("fooba", "Zm9vYmE="),
        ("foobar", "Zm9vYmFy")
    ])
    func testRFCVectors(input: String, expected: String) {
        let bytes = Array(input.utf8)
        let encoded = String(base64Encoding: bytes)
        #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == bytes, "Round-trip failed for '\(input)'")
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

    @Test("Base64 decoding with whitespace", arguments: [
        "Zm9v\nYmFy",     // newline
        "Zm9v\tYmFy",     // tab
        "Zm9v YmFy",      // space
        "Zm9v\n\t YmFy"   // mixed whitespace
    ])
    func testWhitespaceHandling(input: String) {
        let decoded = [UInt8](base64Encoded: input)
        #expect(decoded == Array("foobar".utf8), "Whitespace should be ignored")
    }

    // MARK: - Invalid Input Tests

    @Test("Base64 decoding rejects invalid input", arguments: [
        "Zm9v!!!!",  // invalid characters
        "Zm9",       // invalid length (not multiple of 4)
        "====",      // only padding
        "Z"          // too short
    ])
    func testInvalidInput(input: String) {
        let decoded = [UInt8](base64Encoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
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
