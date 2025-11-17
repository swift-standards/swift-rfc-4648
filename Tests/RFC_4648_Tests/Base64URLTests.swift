// Base64URLTests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 5: Base64URL Encoding (URL and filename safe)

import Testing
import RFC_4648

@Suite("Base64URL Encoding Tests")
struct Base64URLTests {

    // MARK: - Basic Encoding/Decoding

    @Test("Base64URL empty string")
    func testEmptyString() {
        let input: [UInt8] = []
        let encoded = String(base64URLEncoding: input)
        #expect(encoded == "")

        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base64URL simple string")
    func testSimpleString() {
        let input: [UInt8] = Array("hello".utf8)
        let encoded = String(base64URLEncoding: input)
        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - URL Safety Tests

    @Test("Base64URL uses URL-safe characters")
    func testURLSafeCharacters() {
        // This input would produce '+' and '/' in standard Base64
        let input: [UInt8] = [0xFB, 0xFF, 0xFF]
        let encoded = String(base64URLEncoding: input)

        // Base64URL should use '-' and '_' instead of '+' and '/'
        #expect(encoded.contains("-") || encoded.contains("_"))
        #expect(!encoded.contains("+"))
        #expect(!encoded.contains("/"))

        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base64URL with special chars")
    func testSpecialCharacterSubstitution() {
        // Input that produces all special chars in Base64URL
        let input: [UInt8] = [0xFF, 0xFF]
        let encoded = String(base64URLEncoding: input)

        // Should contain '_' (not '/')
        #expect(encoded.contains("_"))
        #expect(!encoded.contains("/"))
    }

    // MARK: - Padding Tests (RFC 7515 recommends no padding)

    @Test("Base64URL default no padding")
    func testDefaultNoPadding() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base64URLEncoding: input)
        #expect(encoded == "Zg")
        #expect(!encoded.contains("="))
    }

    @Test("Base64URL with explicit padding")
    func testWithPadding() {
        let input: [UInt8] = Array("f".utf8)
        let encoded = String(base64URLEncoding: input, padding: true)
        #expect(encoded == "Zg==")
    }

    @Test("Base64URL decoding without padding")
    func testDecodingWithoutPadding() {
        let input = "Zg"
        let decoded = [UInt8](base64URLEncoded: input)
        #expect(decoded == Array("f".utf8))
    }

    @Test("Base64URL decoding with padding")
    func testDecodingWithPadding() {
        let input = "Zg=="
        let decoded = [UInt8](base64URLEncoded: input)
        #expect(decoded == Array("f".utf8))
    }

    @Test("Base64URL decoding mixed padding scenarios")
    func testMixedPaddingScenarios() {
        // 1 byte input -> 2 chars (no padding needed)
        #expect([UInt8](base64URLEncoded: "Zg") == Array("f".utf8))

        // 2 bytes input -> 3 chars + 1 padding
        #expect([UInt8](base64URLEncoded: "Zm8") == Array("fo".utf8))
        #expect([UInt8](base64URLEncoded: "Zm8=") == Array("fo".utf8))

        // 3 bytes input -> 4 chars (no padding needed)
        #expect([UInt8](base64URLEncoded: "Zm9v") == Array("foo".utf8))
    }

    // MARK: - Whitespace Handling

    @Test("Base64URL decoding with whitespace")
    func testWhitespaceHandling() {
        let input = "Zm9v\nYmFy"
        let decoded = [UInt8](base64URLEncoded: input)
        #expect(decoded == Array("foobar".utf8))
    }

    // MARK: - Invalid Input Tests

    @Test("Base64URL decoding standard Base64 characters fails")
    func testRejectStandardBase64Characters() {
        // '+' and '/' are not valid in Base64URL
        let withPlus = "Zg+A"
        #expect([UInt8](base64URLEncoded: withPlus) == nil)

        let withSlash = "Zg/A"
        #expect([UInt8](base64URLEncoded: withSlash) == nil)
    }

    @Test("Base64URL decoding invalid characters")
    func testInvalidCharacters() {
        let input = "Zm9v!!!!"
        let decoded = [UInt8](base64URLEncoded: input)
        #expect(decoded == nil)
    }

    @Test("Base64URL decoding invalid length")
    func testInvalidLength() {
        let input = "Z"
        let decoded = [UInt8](base64URLEncoded: input)
        #expect(decoded == nil)
    }

    // MARK: - JWT Use Case

    @Test("Base64URL JWT header example")
    func testJWTHeader() {
        // Typical JWT header: {"alg":"HS256","typ":"JWT"}
        let headerJSON = Array("{\"alg\":\"HS256\",\"typ\":\"JWT\"}".utf8)
        let encoded = String(base64URLEncoding: headerJSON, padding: false)

        // Should not contain URL-unsafe characters
        #expect(!encoded.contains("+"))
        #expect(!encoded.contains("/"))
        #expect(!encoded.contains("="))

        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == headerJSON)
    }

    // MARK: - Binary Data Tests

    @Test("Base64URL binary data")
    func testBinaryData() {
        let input: [UInt8] = [0x00, 0xFF, 0x80, 0x7F, 0x3E, 0x3F]
        let encoded = String(base64URLEncoding: input)
        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base64URL all special characters")
    func testAllSpecialCharacters() {
        // Input that generates maximum special chars
        let input: [UInt8] = [0xFF, 0xEF, 0xFF, 0xEF]
        let encoded = String(base64URLEncoding: input)

        // Should use '_' and '-' not '/' and '+'
        if encoded.contains("_") {
            #expect(!encoded.contains("/"))
        }
        if encoded.contains("-") {
            #expect(!encoded.contains("+"))
        }

        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Edge Cases

    @Test("Base64URL round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String(base64URLEncoding: input, padding: false)
        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Comparison with Standard Base64

    @Test("Base64URL produces different output than Base64 for special chars")
    func testDifferentFromBase64() {
        let input: [UInt8] = [0xFF, 0xFF]

        // Use padding for Base64 (standard Base64 requires it for decoding)
        let base64 = String(base64Encoding: input, padding: true)
        let base64url = String(base64URLEncoding: input, padding: false)

        // They should differ when special chars are present
        #expect(base64 != base64url)

        // Both should decode correctly with their respective decoders
        #expect([UInt8](base64Encoded: base64) == input)
        #expect([UInt8](base64URLEncoded: base64url) == input)
    }
}
