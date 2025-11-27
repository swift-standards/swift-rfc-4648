// RFC_4648+Validation.swift
// swift-rfc-4648
//
// Validation extensions for RFC 4648 encodings

extension RFC_4648.Base64 {
  /// Checks if the string is valid Base64 encoding (RFC 4648 Section 4)
  ///
  /// Validates the string without allocating memory for decoded output.
  /// This is more efficient than attempting to decode when you only need
  /// to check validity.
  ///
  /// - Parameter string: The string to validate
  /// - Returns: true if the string is valid Base64, false otherwise
  ///
  /// ## Examples
  ///
  /// ```swift
  /// RFC_4648.Base64.isValid("Zm9vYmFy")  // true
  /// RFC_4648.Base64.isValid("!!!invalid")  // false
  /// ```
  public static func isValid(_ string: String) -> Bool {
    [UInt8](base64Encoded: string) != nil
  }
}

extension RFC_4648.Base64.URL {
  /// Checks if the string is valid Base64URL encoding (RFC 4648 Section 5)
  ///
  /// Validates the string without allocating memory for decoded output.
  ///
  /// - Parameter string: The string to validate
  /// - Returns: true if the string is valid Base64URL, false otherwise
  ///
  /// ## Examples
  ///
  /// ```swift
  /// RFC_4648.Base64.URL.isValid("Zm9vYmFy")  // true
  /// RFC_4648.Base64.URL.isValid("A-B_")  // true (Base64URL uses - and _)
  /// ```
  public static func isValid(_ string: String) -> Bool {
    [UInt8](base64URLEncoded: string) != nil
  }
}

extension RFC_4648.Base32 {
  /// Checks if the string is valid Base32 encoding (RFC 4648 Section 6)
  ///
  /// Validates the string without allocating memory for decoded output.
  /// Base32 uses A-Z and 2-7, case-insensitive.
  ///
  /// - Parameter string: The string to validate
  /// - Returns: true if the string is valid Base32, false otherwise
  ///
  /// ## Examples
  ///
  /// ```swift
  /// RFC_4648.Base32.isValid("MZXW6YTBOI======")  // true
  /// RFC_4648.Base32.isValid("123@#$")  // false
  /// ```
  public static func isValid(_ string: String) -> Bool {
    [UInt8](base32Encoded: string) != nil
  }
}

extension RFC_4648.Base32.Hex {
  /// Checks if the string is valid Base32-HEX encoding (RFC 4648 Section 7)
  ///
  /// Validates the string without allocating memory for decoded output.
  /// Base32-HEX uses 0-9 and A-V, case-insensitive.
  ///
  /// - Parameter string: The string to validate
  /// - Returns: true if the string is valid Base32-HEX, false otherwise
  ///
  /// ## Examples
  ///
  /// ```swift
  /// RFC_4648.Base32.Hex.isValid("CPNMUOJ1")  // true
  /// RFC_4648.Base32.Hex.isValid("XYZ123")  // false (X, Y, Z not in alphabet)
  /// ```
  public static func isValid(_ string: String) -> Bool {
    [UInt8](base32HexEncoded: string) != nil
  }
}

extension RFC_4648.Base16 {
  /// Checks if the string is valid Base16 (hexadecimal) encoding (RFC 4648 Section 8)
  ///
  /// Validates the string without allocating memory for decoded output.
  /// Accepts both lowercase and uppercase hex digits. Accepts strings with
  /// or without "0x" prefix.
  ///
  /// - Parameter string: The string to validate
  /// - Returns: true if the string is valid hexadecimal, false otherwise
  ///
  /// ## Examples
  ///
  /// ```swift
  /// RFC_4648.Base16.isValid("deadbeef")  // true
  /// RFC_4648.Base16.isValid("0xDEADBEEF")  // true
  /// RFC_4648.Base16.isValid("ghijk")  // false
  /// ```
  public static func isValid(_ string: String) -> Bool {
    // Strip common prefixes
    let cleaned =
      string.hasPrefix("0x") || string.hasPrefix("0X")
      ? String(string.dropFirst(2))
      : string

    return [UInt8](hexEncoded: cleaned) != nil
  }
}
