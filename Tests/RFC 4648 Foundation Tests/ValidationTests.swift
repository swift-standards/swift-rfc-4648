// ValidationTests.swift
// swift-rfc-4648
//
// Tests for String validation methods

import Testing
import Foundation
@testable import RFC_4648_Foundation

@Suite("String Validation Tests")
struct ValidationTests {

    // MARK: - Base64 Validation

    @Test("Valid Base64 strings", arguments: [
        "",
        "Zg==",
        "Zm8=",
        "Zm9v",
        "Zm9vYg==",
        "Zm9vYmE=",
        "Zm9vYmFy",
        "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw=="
    ])
    func testValidBase64(input: String) {
        #expect(input.isValidBase64(), "\(input) should be valid Base64")
    }

    @Test("Invalid Base64 strings", arguments: [
        "!@#$",
        "Zm9",      // Invalid length
        "====",     // Only padding
        "Z!9v",     // Invalid character
        "Zm9v===",  // Too much padding
    ])
    func testInvalidBase64(input: String) {
        #expect(!input.isValidBase64(), "\(input) should be invalid Base64")
    }

    @Test("Base64 validation with whitespace")
    func testBase64ValidationWithWhitespace() {
        // Our implementation allows whitespace
        #expect("Zm9v\nYmFy".isValidBase64())
        #expect("Zm9v YmFy".isValidBase64())
        #expect("Zm9v\tYmFy".isValidBase64())
    }

    // MARK: - Base64URL Validation

    @Test("Valid Base64URL strings", arguments: [
        "",
        "Zg",
        "Zm8",
        "Zm9v",
        "Zm9vYg",
        "Zm9vYmE",
        "Zm9vYmFy",
        "A-B_C"  // Base64URL uses - and _
    ])
    func testValidBase64URL(input: String) {
        #expect(input.isValidBase64URL(), "\(input) should be valid Base64URL")
    }

    @Test("Invalid Base64URL strings", arguments: [
        "!@#$",
        "A+B/C"  // Base64URL doesn't use + and /
    ])
    func testInvalidBase64URL(input: String) {
        #expect(!input.isValidBase64URL(), "\(input) should be invalid Base64URL")
    }

    // MARK: - Base32 Validation

    @Test("Valid Base32 strings", arguments: [
        "",
        "MZXW6===",
        "MZXW6YTBOI======",
        "JBSWY3DPEBLW64TMMQ======"
    ])
    func testValidBase32(input: String) {
        #expect(input.isValidBase32(), "\(input) should be valid Base32")
    }

    @Test("Base32 case insensitive validation")
    func testBase32CaseInsensitive() {
        #expect("MZXW6===".isValidBase32())
        #expect("mzxw6===".isValidBase32())
        #expect("MzXw6===".isValidBase32())
    }

    @Test("Invalid Base32 strings", arguments: [
        "189",      // Base32 doesn't use 0, 1, 8, 9
        "ABC!@#",   // Invalid characters
        "====",     // Only padding
    ])
    func testInvalidBase32(input: String) {
        #expect(!input.isValidBase32(), "\(input) should be invalid Base32")
    }

    // MARK: - Base32-HEX Validation

    @Test("Valid Base32-HEX strings", arguments: [
        "",
        "CPNMU===",
        "CPNMUOJ1",
        "91IMOR3F41BMUSJCCG======"
    ])
    func testValidBase32Hex(input: String) {
        #expect(input.isValidBase32Hex(), "\(input) should be valid Base32-HEX")
    }

    @Test("Base32-HEX case insensitive validation")
    func testBase32HexCaseInsensitive() {
        #expect("CPNMU===".isValidBase32Hex())
        #expect("cpnmu===".isValidBase32Hex())
        #expect("CpNmU===".isValidBase32Hex())
    }

    @Test("Invalid Base32-HEX strings", arguments: [
        "XYZ",      // Base32-HEX doesn't use W-Z
        "ABC!@#",   // Invalid characters
        "====",     // Only padding
    ])
    func testInvalidBase32Hex(input: String) {
        #expect(!input.isValidBase32Hex(), "\(input) should be invalid Base32-HEX")
    }

    // MARK: - Hexadecimal Validation

    @Test("Valid hexadecimal strings", arguments: [
        "",
        "00",
        "ff",
        "FF",
        "deadbeef",
        "DEADBEEF",
        "0xdeadbeef",
        "0xDEADBEEF",
        "0XDEADBEEF",
        "0123456789abcdef",
        "0123456789ABCDEF"
    ])
    func testValidHex(input: String) {
        #expect(input.isValidHex(), "\(input) should be valid hexadecimal")
    }

    @Test("Invalid hexadecimal strings", arguments: [
        "ghijk",    // Invalid characters
        "xyz",      // Invalid characters
        "fff",      // Odd length
        "0x",       // Empty after prefix
        "!@#$",     // Invalid characters
    ])
    func testInvalidHex(input: String) {
        #expect(!input.isValidHex(), "\(input) should be invalid hexadecimal")
    }

    @Test("Hexadecimal validation with prefix")
    func testHexValidationWithPrefix() {
        #expect("0xdeadbeef".isValidHex())
        #expect("0xDEADBEEF".isValidHex())
        #expect("0XDEADBEEF".isValidHex())
        #expect("deadbeef".isValidHex())
    }

    // MARK: - Performance

    @Test("Validation is efficient for large strings")
    func testValidationPerformance() {
        let largeValid = String(repeating: "Zm9vYmFy", count: 1000)
        let largeInvalid = String(repeating: "!!!!", count: 1000)

        #expect(largeValid.isValidBase64())
        #expect(!largeInvalid.isValidBase64())
    }

    // MARK: - Validation vs Decoding

    @Test("Validation matches decoding for Base64")
    func testBase64ValidationMatchesDecoding() {
        let testCases = [
            "Zm9vYmFy",  // valid
            "!@#$",      // invalid
            "Zm9",       // invalid length
            ""           // empty
        ]

        for test in testCases {
            let isValid = test.isValidBase64()
            let canDecode = Data(base64Encoded: test) != nil

            #expect(isValid == canDecode,
                    "Validation and decoding disagree for '\(test)'")
        }
    }

    @Test("Validation matches decoding for Base32")
    func testBase32ValidationMatchesDecoding() {
        let testCases = [
            "MZXW6===",  // valid
            "189",       // invalid
            ""           // empty
        ]

        for test in testCases {
            let isValid = test.isValidBase32()
            let canDecode = Data(base32Encoded: test) != nil

            #expect(isValid == canDecode,
                    "Validation and decoding disagree for '\(test)'")
        }
    }

    @Test("Validation matches decoding for hexadecimal")
    func testHexValidationMatchesDecoding() {
        let testCases = [
            "deadbeef",  // valid
            "0xdeadbeef",// valid with prefix
            "ghijk",     // invalid
            "fff",       // odd length
            ""           // empty
        ]

        for test in testCases {
            let isValid = test.isValidHex()
            let canDecode = Data(hexEncoded: test) != nil

            #expect(isValid == canDecode,
                    "Validation and decoding disagree for '\(test)'")
        }
    }

    // MARK: - Edge Cases

    @Test("Empty string validation across all encodings")
    func testEmptyStringValidation() {
        let empty = ""

        #expect(empty.isValidBase64())
        #expect(empty.isValidBase64URL())
        #expect(empty.isValidBase32())
        #expect(empty.isValidBase32Hex())
        #expect(empty.isValidHex())
    }

    @Test("Unicode characters in validation")
    func testUnicodeInValidation() {
        // Non-ASCII characters should fail validation
        #expect(!"Zm9v🚀".isValidBase64())
        #expect(!"MZXW6😀".isValidBase32())
        #expect(!"dead你好".isValidHex())
    }
}
