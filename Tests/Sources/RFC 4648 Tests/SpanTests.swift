//
//  SpanTests.swift
//  swift-rfc-4648
//
//  Tests for Span-based encoding

import Testing
@testable import RFC_4648

@Suite("Span Encoding")
struct SpanTests {

    // MARK: - Base16 (Hex)

    @Test("Span hex encoding matches Array encoding")
    func spanHexEncoding() {
        let bytes: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.hex.encoded() == bytes.hex.encoded())
            #expect(span.hex.encoded(uppercase: true) == bytes.hex.encoded(uppercase: true))
        }
    }

    @Test("Span hex callable syntax")
    func spanHexCallable() {
        let bytes: [UInt8] = [0xCA, 0xFE]
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.hex() == "cafe")
            #expect(span.hex(uppercase: true) == "CAFE")
        }
    }

    @Test("Empty span hex encoding")
    func emptySpanHex() {
        let bytes: [UInt8] = []
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.hex.encoded().isEmpty)
        }
    }

    // MARK: - Base64

    @Test("Span base64 encoding matches Array encoding")
    func spanBase64Encoding() {
        let bytes: [UInt8] = [72, 101, 108, 108, 111]  // "Hello"
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base64.encoded() == bytes.base64.encoded())
            #expect(span.base64.encoded(padding: false) == bytes.base64.encoded(padding: false))
        }
    }

    @Test("Span base64 URL encoding matches Array encoding")
    func spanBase64URLEncoding() {
        let bytes: [UInt8] = [0xFB, 0xFF, 0xBF]  // Bytes that produce +/ in standard Base64
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base64.url.encoded() == bytes.base64.url.encoded())
            #expect(span.base64.url.encoded(padding: true) == bytes.base64.url.encoded(padding: true))
        }
    }

    @Test("Empty span base64 encoding")
    func emptySpanBase64() {
        let bytes: [UInt8] = []
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base64.encoded().isEmpty)
        }
    }

    // MARK: - Base32

    @Test("Span base32 encoding matches Array encoding")
    func spanBase32Encoding() {
        let bytes: [UInt8] = [72, 101, 108, 108, 111]  // "Hello"
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base32.encoded() == bytes.base32.encoded())
            #expect(span.base32.encoded(padding: false) == bytes.base32.encoded(padding: false))
        }
    }

    @Test("Span base32 hex encoding matches Array encoding")
    func spanBase32HexEncoding() {
        let bytes: [UInt8] = [72, 101, 108, 108, 111]
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base32.hex.encoded() == bytes.base32.hex.encoded())
            #expect(span.base32.hex.encoded(padding: false) == bytes.base32.hex.encoded(padding: false))
        }
    }

    @Test("Empty span base32 encoding")
    func emptySpanBase32() {
        let bytes: [UInt8] = []
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base32.encoded().isEmpty)
        }
    }

    // MARK: - Temporary Allocation

    @Test("Span encoding from temporary allocation")
    func temporaryAllocationEncoding() {
        let result = withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 4) { buffer in
            buffer[0] = 0xCA
            buffer[1] = 0xFE
            buffer[2] = 0xBA
            buffer[3] = 0xBE
            let span = Span(_unsafeElements: UnsafeBufferPointer(buffer))
            return span.hex.encoded()
        }
        #expect(result == "cafebabe")
    }

    @Test("Span base64 from temporary allocation")
    func temporaryAllocationBase64() {
        let result = withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 3) { buffer in
            buffer[0] = 0x48  // H
            buffer[1] = 0x69  // i
            buffer[2] = 0x21  // !
            let span = Span(_unsafeElements: UnsafeBufferPointer(buffer))
            return span.base64.encoded()
        }
        #expect(result == "SGkh")
    }
}
