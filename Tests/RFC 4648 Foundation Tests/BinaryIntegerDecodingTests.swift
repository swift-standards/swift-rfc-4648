// BinaryIntegerDecodingTests.swift
// swift-rfc-4648
//
// Tests for BinaryInteger decoding and round-trip encoding

import Testing
import Foundation
@testable import RFC_4648_Foundation

@Suite("BinaryInteger Decoding Tests")
struct BinaryIntegerDecodingTests {

    // MARK: - Base64 Decoding

    @Test("UInt32 Base64 decoding")
    func testUInt32Base64Decoding() {
        let value = UInt32(123456)
        let encoded = String(base64: value)

        let decoded = UInt32(base64Encoded: encoded)
        #expect(decoded == value)
    }

    @Test("UInt32 Base64 round-trip", arguments: [
        UInt32(0),
        UInt32(1),
        UInt32(255),
        UInt32(256),
        UInt32(65535),
        UInt32(123456),
        UInt32(0xDEADBEEF),
        UInt32.max
    ])
    func testUInt32Base64RoundTrip(value: UInt32) {
        let encoded = String(base64: value)
        let decoded = UInt32(base64Encoded: encoded)

        #expect(decoded == value, "Failed for \(value)")
    }

    @Test("UInt8 Base64 round-trip", arguments: [
        UInt8(0), UInt8(1), UInt8(127), UInt8(128), UInt8(255)
    ])
    func testUInt8Base64RoundTrip(value: UInt8) {
        let encoded = String(base64: value)
        let decoded = UInt8(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test("UInt16 Base64 round-trip", arguments: [
        UInt16(0), UInt16(255), UInt16(256), UInt16(0xABCD), UInt16.max
    ])
    func testUInt16Base64RoundTrip(value: UInt16) {
        let encoded = String(base64: value)
        let decoded = UInt16(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test("UInt64 Base64 round-trip", arguments: [
        UInt64(0),
        UInt64(UInt32.max),
        UInt64(0x123456789ABCDEF0),
        UInt64.max
    ])
    func testUInt64Base64RoundTrip(value: UInt64) {
        let encoded = String(base64: value)
        let decoded = UInt64(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test("Signed integer Base64 round-trip")
    func testSignedIntegerBase64RoundTrip() {
        let values: [Int32] = [-1, -128, 0, 127, Int32.max, Int32.min]

        for value in values {
            let encoded = String(base64: value)
            let decoded = Int32(base64Encoded: encoded)

            #expect(decoded == value, "Failed for \(value)")
        }
    }

    @Test("Wrong size Base64 decoding fails")
    func testWrongSizeBase64Decoding() {
        let uint32Value = UInt32(123456)
        let encoded = String(base64: uint32Value)

        // Try to decode 4 bytes as UInt8 (should fail)
        #expect(UInt8(base64Encoded: encoded) == nil)

        // Try to decode 4 bytes as UInt64 (should fail)
        #expect(UInt64(base64Encoded: encoded) == nil)
    }

    // MARK: - Base64URL Decoding

    @Test("UInt32 Base64URL round-trip", arguments: [
        UInt32(0), UInt32(123456), UInt32(0xDEADBEEF), UInt32.max
    ])
    func testUInt32Base64URLRoundTrip(value: UInt32) {
        let encoded = String(base64URL: value)
        let decoded = UInt32(base64URLEncoded: encoded)

        #expect(decoded == value)
    }

    // MARK: - Base32 Decoding

    @Test("UInt32 Base32 round-trip", arguments: [
        UInt32(0), UInt32(123456), UInt32.max
    ])
    func testUInt32Base32RoundTrip(value: UInt32) {
        let encoded = String(base32: value)
        let decoded = UInt32(base32Encoded: encoded)

        #expect(decoded == value)
    }

    @Test("Base32 case insensitive decoding")
    func testBase32CaseInsensitive() {
        let value = UInt32(123456)
        let upper = String(base32: value)  // Default uppercase
        let lower = upper.lowercased()

        #expect(UInt32(base32Encoded: upper) == value)
        #expect(UInt32(base32Encoded: lower) == value)
    }

    // MARK: - Base32-HEX Decoding

    @Test("UInt32 Base32-HEX round-trip", arguments: [
        UInt32(0), UInt32(123456), UInt32.max
    ])
    func testUInt32Base32HexRoundTrip(value: UInt32) {
        let encoded = String(base32Hex: value)
        let decoded = UInt32(base32HexEncoded: encoded)

        #expect(decoded == value)
    }

    // MARK: - Hexadecimal Decoding

    @Test("UInt32 hexadecimal decoding")
    func testUInt32HexDecoding() {
        #expect(UInt32(hexEncoded: "deadbeef") == 0xDEADBEEF)
        #expect(UInt32(hexEncoded: "0xdeadbeef") == 0xDEADBEEF)
        #expect(UInt32(hexEncoded: "0xDEADBEEF") == 0xDEADBEEF)
        #expect(UInt32(hexEncoded: "DEADBEEF") == 0xDEADBEEF)
    }

    @Test("UInt8 hexadecimal round-trip", arguments: [
        UInt8(0x00), UInt8(0x0F), UInt8(0xFF), UInt8(0xAB)
    ])
    func testUInt8HexRoundTrip(value: UInt8) {
        let encoded = String(hex: value, prefix: "")
        let decoded = UInt8(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test("UInt16 hexadecimal round-trip", arguments: [
        UInt16(0x0000), UInt16(0xABCD), UInt16(0xFFFF)
    ])
    func testUInt16HexRoundTrip(value: UInt16) {
        let encoded = String(hex: value, prefix: "")
        let decoded = UInt16(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test("UInt64 hexadecimal round-trip", arguments: [
        UInt64(0),
        UInt64(0x123456789ABCDEF0),
        UInt64.max
    ])
    func testUInt64HexRoundTrip(value: UInt64) {
        let encoded = String(hex: value, prefix: "")
        let decoded = UInt64(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test("Hexadecimal decoding with prefix")
    func testHexDecodingWithPrefix() {
        #expect(UInt32(hexEncoded: "0xDEADBEEF") == 0xDEADBEEF)
        #expect(UInt32(hexEncoded: "0XDEADBEEF") == 0xDEADBEEF)
        #expect(UInt32(hexEncoded: "deadbeef") == 0xDEADBEEF)
    }

    // MARK: - Convenience Properties

    @Test("UInt32 convenience properties")
    func testUInt32ConvenienceProperties() {
        let value = UInt32(123456)

        #expect(UInt32(base64Encoded: value.base64Encoded) == value)
        #expect(UInt32(base64URLEncoded: value.base64URLEncoded) == value)
        #expect(UInt32(base32Encoded: value.base32Encoded) == value)
        #expect(UInt32(base32HexEncoded: value.base32HexEncoded) == value)
        #expect(UInt32(hexEncoded: value.hexEncoded) == value)
    }

    @Test("UInt8 hex convenience property")
    func testUInt8HexProperty() {
        #expect(UInt8(0xFF).hexEncoded == "ff")
        #expect(UInt8(0x00).hexEncoded == "00")
        #expect(UInt8(0xAB).hexEncoded == "ab")
    }

    @Test("UInt16 hex convenience property")
    func testUInt16HexProperty() {
        #expect(UInt16(0xABCD).hexEncoded == "abcd")
        #expect(UInt16(0x0000).hexEncoded == "0000")
        #expect(UInt16(0xFFFF).hexEncoded == "ffff")
    }

    @Test("UInt32 hex convenience property")
    func testUInt32HexProperty() {
        #expect(UInt32(0xDEADBEEF).hexEncoded == "deadbeef")
    }

    @Test("UInt64 hex convenience property")
    func testUInt64HexProperty() {
        #expect(UInt64(0x123456789ABCDEF0).hexEncoded == "123456789abcdef0")
    }

    // MARK: - Invalid Input

    @Test("Invalid Base64 returns nil")
    func testInvalidBase64() {
        #expect(UInt32(base64Encoded: "invalid!@#$") == nil)
        #expect(UInt32(base64Encoded: "") == nil)
    }

    @Test("Invalid Base32 returns nil")
    func testInvalidBase32() {
        #expect(UInt32(base32Encoded: "189") == nil)
    }

    @Test("Invalid hexadecimal returns nil")
    func testInvalidHex() {
        #expect(UInt32(hexEncoded: "GHIJK") == nil)
        #expect(UInt32(hexEncoded: "xyz") == nil)
    }

    // MARK: - Edge Cases

    @Test("Zero value across all encodings")
    func testZeroValue() {
        let zero = UInt32(0)

        #expect(UInt32(base64Encoded: zero.base64Encoded) == zero)
        #expect(UInt32(base64URLEncoded: zero.base64URLEncoded) == zero)
        #expect(UInt32(base32Encoded: zero.base32Encoded) == zero)
        #expect(UInt32(base32HexEncoded: zero.base32HexEncoded) == zero)
        #expect(UInt32(hexEncoded: zero.hexEncoded) == zero)
    }

    @Test("Maximum value across all encodings")
    func testMaxValue() {
        let max = UInt32.max

        #expect(UInt32(base64Encoded: max.base64Encoded) == max)
        #expect(UInt32(base64URLEncoded: max.base64URLEncoded) == max)
        #expect(UInt32(base32Encoded: max.base32Encoded) == max)
        #expect(UInt32(base32HexEncoded: max.base32HexEncoded) == max)
        #expect(UInt32(hexEncoded: max.hexEncoded) == max)
    }

    // MARK: - All Integer Types

    @Test("All unsigned integer types supported")
    func testAllUnsignedTypes() {
        _ = UInt8(base64Encoded: UInt8(42).base64Encoded)
        _ = UInt16(base64Encoded: UInt16(42).base64Encoded)
        _ = UInt32(base64Encoded: UInt32(42).base64Encoded)
        _ = UInt64(base64Encoded: UInt64(42).base64Encoded)
        _ = UInt(base64Encoded: UInt(42).base64Encoded)
    }

    @Test("All signed integer types supported")
    func testAllSignedTypes() {
        _ = Int8(base64Encoded: Int8(42).base64Encoded)
        _ = Int16(base64Encoded: Int16(42).base64Encoded)
        _ = Int32(base64Encoded: Int32(42).base64Encoded)
        _ = Int64(base64Encoded: Int64(42).base64Encoded)
        _ = Int(base64Encoded: Int(42).base64Encoded)
    }
}
