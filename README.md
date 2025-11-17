# swift-rfc-4648

Pure Swift implementation of **RFC 4648**: The Base16, Base32, and Base64 Data Encodings

## Standard Reference

- **RFC**: 4648
- **Title**: The Base16, Base32, and Base64 Data Encodings
- **Status**: Standards Track
- **Published**: October 2006

## Features

- ✅ Pure Swift with no Foundation dependencies
- ✅ Swift Embedded compatible (no existentials, no runtime features)
- ✅ Comprehensive data encoding implementations
- ✅ All RFC 4648 encoding variants

## Encodings Provided

### Base64 (Section 4)
Standard Base64 encoding with padding.

### Base64URL (Section 5)
URL and filename safe variant of Base64 (no padding by default).

### Base32 (Section 6)
Case-insensitive encoding suitable for human entry.

### Base32-HEX (Section 7)
Extended Hex Alphabet variant of Base32.

### Base16/Hex (Section 8)
Hexadecimal encoding (base 16).

## API Overview

```swift
// Base64
let encoded = String(base64Encoding: [72, 101, 108, 108, 111])  // "SGVsbG8="
let decoded = [UInt8](base64Encoded: "SGVsbG8=")  // [72, 101, 108, 108, 111]

// Base64URL (URL-safe, no padding)
let encoded = String(base64URLEncoding: [72, 101, 108, 108, 111])  // "SGVsbG8"
let decoded = [UInt8](base64URLEncoded: "SGVsbG8")  // [72, 101, 108, 108, 111]

// Base32
let encoded = String(base32Encoding: [72, 101, 108, 108, 111])  // "JBSWY3DP"
let decoded = [UInt8](base32Encoded: "JBSWY3DP")  // [72, 101, 108, 108, 111]

// Hex
let encoded = String(hexEncoding: [72, 101, 108, 108, 111])  // "48656c6c6f"
let decoded = [UInt8](hexEncoded: "48656c6c6f")  // [72, 101, 108, 108, 111]
```

## Architecture

This package is part of the swift-standards ecosystem:

**Tier 0: swift-standards** (Foundation)
- Truly generic, standard-agnostic utilities
- Collection safety, clamping, byte serialization, etc.

**Tier 1: swift-rfc-4648** (This package - Standard implementation)
- Implements RFC 4648 data encodings
- Depends only on swift-standards

**Tier 2+: Other RFC packages**
- Use RFC 4648 encodings as needed
- Examples: JWT (RFC 7519) uses Base64URL, TOTP (RFC 6238) uses Base32

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-rfc-4648.git", from: "0.1.0")
]
```

## License

Licensed under Apache 2.0.

## Related Packages

- [swift-standards](../swift-standards) - Foundation utilities
- [swift-incits-4-1986](../swift-incits-4-1986) - ASCII standard
- [swift-rfc-3986](../swift-rfc-3986) - URI parsing
