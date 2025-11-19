// FoundationComparisonTests.swift
// swift-rfc-4648
//
// Tests comparing RFC_4648 implementations against Foundation's implementations

import Testing
import RFC_4648
#if canImport(Foundation)
import Foundation

@Suite("Foundation Comparison Tests")
struct FoundationComparisonTests {
    
    // MARK: - Base64 Comparison
    
    @Test("Base64 encoding matches Foundation")
    func testBase64EncodingMatchesFoundation() {
        let testCases: [[UInt8]] = [
            [],
            Array("f".utf8),
            Array("fo".utf8),
            Array("foo".utf8),
            Array("foob".utf8),
            Array("fooba".utf8),
            Array("foobar".utf8),
            [0x00, 0xFF, 0x80, 0x7F],
            Array("The quick brown fox jumps over the lazy dog".utf8),
            (0..<100).map { UInt8($0 % 256) }
        ]
        
        for bytes in testCases {
            let ourEncoding = String(base64Encoding: bytes, padding: true)
            let foundationEncoding = Data(bytes).base64EncodedString()
            
            #expect(ourEncoding == foundationEncoding,
                    "Our encoding: \(ourEncoding), Foundation: \(foundationEncoding)")
        }
    }
    
    @Test("Base64 decoding matches Foundation")
    func testBase64DecodingMatchesFoundation() {
        let testCases = [
            "",
            "Zg==",
            "Zm8=",
            "Zm9v",
            "Zm9vYg==",
            "Zm9vYmE=",
            "Zm9vYmFy",
            "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw=="
        ]
        
        for encoded in testCases {
            let ourDecoding = [UInt8](base64Encoded: encoded)
            let foundationDecoding = Data(base64Encoded: encoded).map { Array($0) }
            
            #expect(ourDecoding == foundationDecoding,
                    "Our decoding: \(String(describing: ourDecoding)), Foundation: \(String(describing: foundationDecoding))")
        }
    }
    
    @Test("Base64 round-trip matches Foundation")
    func testBase64RoundTripMatchesFoundation() {
        let testBytes: [[UInt8]] = [
            Array("Hello, World!".utf8),
            (0..<255).map { UInt8($0) },
            Array(repeating: 0xFF, count: 100),
            Array(repeating: 0x00, count: 100)
        ]
        
        for bytes in testBytes {
            // Our implementation
            let ourEncoded = String(base64Encoding: bytes)
            let ourDecoded = [UInt8](base64Encoded: ourEncoded)
            
            // Foundation implementation
            let foundationEncoded = Data(bytes).base64EncodedString()
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { Array($0) }
            
            #expect(ourEncoded == foundationEncoded)
            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == bytes)
        }
    }
    
    // MARK: - Base64 with Options
    
    @Test("Base64 encoding with line length matches Foundation")
    func testBase64WithLineLength() {
        let longBytes = (0..<200).map { UInt8($0 % 256) }
        
        // Our implementation (single line, no line breaks)
        let ourEncoded = String(base64Encoding: longBytes)
        
        // Foundation implementation without line length
        let foundationEncoded = Data(longBytes).base64EncodedString()
        
        #expect(ourEncoded == foundationEncoded)
        #expect(!ourEncoded.contains("\n"))
        #expect(!ourEncoded.contains("\r"))
    }
    
    // MARK: - Invalid Base64
    
    @Test("Base64 invalid characters rejected by both")
    func testInvalidCharactersRejected() {
        let invalidChars = "!!!!" // Invalid characters
        
        let ourResult = [UInt8](base64Encoded: invalidChars)
        let foundationResult = Data(base64Encoded: invalidChars)
        
        // Both should reject invalid characters
        #expect(ourResult == nil)
        #expect(foundationResult == nil)
    }
    
    @Test("Base64 invalid length rejected by both")
    func testInvalidLengthRejected() {
        let invalidLength = "Zm9" // Not multiple of 4
        
        let ourResult = [UInt8](base64Encoded: invalidLength)
        let foundationResult = Data(base64Encoded: invalidLength)
        
        // Both should reject invalid length
        #expect(ourResult == nil)
        #expect(foundationResult == nil)
    }
    
    @Test("Base64 edge case padding differences")
    func testPaddingEdgeCases() {
        // Note: Foundation is more lenient with some padding edge cases
        // Our implementation strictly follows RFC 4648
        
        // Case 1: Only padding - Foundation accepts, we reject (strict RFC compliance)
        let onlyPadding = "===="
        let ourResult1 = [UInt8](base64Encoded: onlyPadding)
        #expect(ourResult1 == nil, "RFC 4648: Only padding is invalid")
        
        // Case 2: Too much padding - Foundation may accept, we reject
        let tooMuchPadding = "Zm9v==="
        let ourResult2 = [UInt8](base64Encoded: tooMuchPadding)
        #expect(ourResult2 == nil, "RFC 4648: Too much padding is invalid")
    }
    
    // MARK: - Edge Cases
    
    @Test("Base64 whitespace handling - RFC 4648 compliance")
    func testWhitespaceHandling() {
        // RFC 4648 Section 3.3: "Implementations MUST reject the encoded data if it
        // contains characters outside the base alphabet when interpreting base-encoded
        // data, unless the specification referring to this document explicitly states
        // otherwise."
        //
        // However, Section 3.3 also states: "Implementations MAY choose to ignore
        // white space (SP, HTAB, CR, LF)."
        //
        // Our implementation chooses to ignore whitespace (common practice).
        // Foundation does NOT ignore whitespace in base64 (stricter interpretation).
        
        let withWhitespace = "Zm9v\nYmFy"
        let withoutWhitespace = "Zm9vYmFy"
        
        // Our implementation: whitespace is ignored (permitted by RFC 4648)
        let ourDecoded = [UInt8](base64Encoded: withWhitespace)
        #expect(ourDecoded == [UInt8](base64Encoded: withoutWhitespace))
        #expect(ourDecoded == Array("foobar".utf8))
        
        // Foundation: whitespace causes failure
        let foundationDecoded = Data(base64Encoded: withWhitespace)
        #expect(foundationDecoded == nil, "Foundation rejects whitespace in base64")
        
        // Both succeed without whitespace
        let ourClean = [UInt8](base64Encoded: withoutWhitespace)
        let foundationClean = Data(base64Encoded: withoutWhitespace).map { Array($0) }
        #expect(ourClean == foundationClean)
    }
    
    @Test("Base64 empty string handling")
    func testEmptyStringHandling() {
        let emptyBytes: [UInt8] = []
        
        let ourEncoded = String(base64Encoding: emptyBytes)
        let foundationEncoded = Data(emptyBytes).base64EncodedString()
        
        #expect(ourEncoded == foundationEncoded)
        #expect(ourEncoded == "")
        
        let ourDecoded = [UInt8](base64Encoded: "")
        let foundationDecoded = Data(base64Encoded: "").map { Array($0) }
        
        #expect(ourDecoded == foundationDecoded)
        #expect(ourDecoded == [])
    }
    
    // MARK: - Performance Parity
    
    @Test("Base64 large data matches Foundation")
    func testLargeDataMatchesFoundation() {
        // Test with 1MB of data
        let largeBytes = (0..<(1024 * 1024)).map { UInt8($0 % 256) }
        
        let ourEncoded = String(base64Encoding: largeBytes)
        let foundationEncoded = Data(largeBytes).base64EncodedString()
        
        #expect(ourEncoded == foundationEncoded)
        
        let ourDecoded = [UInt8](base64Encoded: ourEncoded)
        let foundationDecoded = Data(base64Encoded: foundationEncoded).map { Array($0) }
        
        #expect(ourDecoded == foundationDecoded)
        #expect(ourDecoded == largeBytes)
    }
    
    // MARK: - Binary Data
    
    @Test("Base64 all byte values match Foundation")
    func testAllByteValuesMatchFoundation() {
        let allBytes = (0...255).map { UInt8($0) }
        
        let ourEncoded = String(base64Encoding: allBytes)
        let foundationEncoded = Data(allBytes).base64EncodedString()
        
        #expect(ourEncoded == foundationEncoded)
        
        let ourDecoded = [UInt8](base64Encoded: ourEncoded)
        let foundationDecoded = Data(base64Encoded: foundationEncoded).map { Array($0) }
        
        #expect(ourDecoded == foundationDecoded)
        #expect(ourDecoded == allBytes)
    }
    
    // MARK: - Hex Comparison (if Foundation provides hex encoding)
    
    @Test("Hex encoding produces valid output")
    func testHexEncodingFormat() {
        let testBytes: [UInt8] = [0x00, 0x0F, 0xFF, 0xAB, 0xCD, 0xEF]
        
        let ourHex = String(hexEncoding: testBytes)
        
        // Verify format is correct (lowercase hex by default)
        #expect(ourHex == "000fffabcdef")
        
        // Verify round-trip
        let decoded = [UInt8](hexEncoded: ourHex)
        #expect(decoded == testBytes)
    }
    
    @Test("Hex uppercase encoding produces valid output")
    func testHexUppercaseEncoding() {
        let testBytes: [UInt8] = [0x00, 0x0F, 0xFF, 0xAB, 0xCD, 0xEF]
        
        let ourHexUpper = String(hexEncoding: testBytes, uppercase: true)
        
        // Verify format is correct (uppercase hex)
        #expect(ourHexUpper == "000FFFABCDEF")
        
        // Verify round-trip (decoding is case-insensitive)
        let decoded = [UInt8](hexEncoded: ourHexUpper)
        #expect(decoded == testBytes)
    }
}
#endif
