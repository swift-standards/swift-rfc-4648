// String+Validation.swift
// swift-rfc-4648
//
// String validation extensions for RFC 4648 encodings

import Foundation
import RFC_4648

extension String {
    /// Checks if the string is valid Base64 encoding (RFC 4648 Section 4)
    ///
    /// Validates the string without allocating memory for decoded output.
    /// This is more efficient than attempting to decode when you only need
    /// to check validity.
    ///
    /// - Returns: true if the string is valid Base64, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "Zm9vYmFy".isValidBase64()  // true
    /// "!!!invalid".isValidBase64()  // false
    /// ```
    public func isValidBase64() -> Bool {
        [UInt8](base64Encoded: self) != nil
    }

    /// Checks if the string is valid Base64URL encoding (RFC 4648 Section 5)
    ///
    /// Validates the string without allocating memory for decoded output.
    ///
    /// - Returns: true if the string is valid Base64URL, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "Zm9vYmFy".isValidBase64URL()  // true
    /// "A-B_C".isValidBase64URL()  // true (Base64URL uses - and _)
    /// ```
    public func isValidBase64URL() -> Bool {
        [UInt8](base64URLEncoded: self) != nil
    }

    /// Checks if the string is valid Base32 encoding (RFC 4648 Section 6)
    ///
    /// Validates the string without allocating memory for decoded output.
    /// Base32 uses A-Z and 2-7, case-insensitive.
    ///
    /// - Returns: true if the string is valid Base32, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "MZXW6YTBOI======".isValidBase32()  // true
    /// "123@#$".isValidBase32()  // false
    /// ```
    public func isValidBase32() -> Bool {
        [UInt8](base32Encoded: self) != nil
    }

    /// Checks if the string is valid Base32-HEX encoding (RFC 4648 Section 7)
    ///
    /// Validates the string without allocating memory for decoded output.
    /// Base32-HEX uses 0-9 and A-V, case-insensitive.
    ///
    /// - Returns: true if the string is valid Base32-HEX, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "CPNMUOJ1".isValidBase32Hex()  // true
    /// "XYZ123".isValidBase32Hex()  // false (X, Y, Z not in alphabet)
    /// ```
    public func isValidBase32Hex() -> Bool {
        [UInt8](base32HexEncoded: self) != nil
    }

    /// Checks if the string is valid hexadecimal encoding (RFC 4648 Section 8)
    ///
    /// Validates the string without allocating memory for decoded output.
    /// Accepts both lowercase and uppercase hex digits. Accepts strings with
    /// or without "0x" prefix.
    ///
    /// - Returns: true if the string is valid hexadecimal, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "deadbeef".isValidHex()  // true
    /// "0xDEADBEEF".isValidHex()  // true
    /// "ghijk".isValidHex()  // false
    /// ```
    public func isValidHex() -> Bool {
        // Strip common prefixes
        let cleaned = self.hasPrefix("0x") || self.hasPrefix("0X")
            ? String(self.dropFirst(2))
            : self

        return [UInt8](hexEncoded: cleaned) != nil
    }
}
