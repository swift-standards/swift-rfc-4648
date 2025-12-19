//
//  Span+RFC4648.swift
//  swift-rfc-4648
//
//  Span extensions for zero-copy encoding from borrowed memory.
//
//  Enables encoding directly from stack-allocated buffers or borrowed memory
//  without intermediate Array allocation.
//
//  ## Usage
//
//  ```swift
//  withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 12) { buffer in
//      arc4random_buf(buffer.baseAddress!, 12)
//      let span = Span(_unsafeElements: buffer)
//      return span.hex.encoded()  // No intermediate Array allocation
//  }
//  ```

// MARK: - Base16 Span Support

extension RFC_4648.Base16 {
    /// Wrapper for Span-based hex encoding
    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Span<UInt8>

        @inlinable
        @_lifetime(copy span)
        init(_ span: Span<UInt8>) {
            self.span = span
        }
    }
}

extension RFC_4648.Base16.SpanWrapper {
    /// Encodes span bytes to hexadecimal string
    ///
    /// - Parameter uppercase: Whether to use uppercase hex digits (default: false)
    /// - Returns: Hexadecimal encoded string
    @inlinable
    public func encoded(uppercase: Bool = false) -> String {
        span.withUnsafeBufferPointer { buffer in
            String(decoding: RFC_4648.Base16.encode(buffer, uppercase: uppercase) as [UInt8], as: UTF8.self)
        }
    }

    /// Callable syntax for encoding
    @inlinable
    public func callAsFunction(uppercase: Bool = false) -> String {
        encoded(uppercase: uppercase)
    }
}

// MARK: - Base64 Span Support

extension RFC_4648.Base64 {
    /// Wrapper for Span-based Base64 encoding
    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Span<UInt8>

        @inlinable
        @_lifetime(copy span)
        init(_ span: Span<UInt8>) {
            self.span = span
        }
    }
}

extension RFC_4648.Base64.SpanWrapper {
    /// Encodes span bytes to Base64 string
    ///
    /// - Parameter padding: Whether to include padding characters (default: true)
    /// - Returns: Base64 encoded string
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        span.withUnsafeBufferPointer { buffer in
            String(decoding: RFC_4648.Base64.encode(buffer, padding: padding) as [UInt8], as: UTF8.self)
        }
    }

    /// Access to URL-safe Base64 encoding
    @inlinable
    public var url: RFC_4648.Base64.URL.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base64.URL.SpanWrapper(span)
        }
    }
}

// MARK: - Base64.URL Span Support

extension RFC_4648.Base64.URL {
    /// Wrapper for Span-based URL-safe Base64 encoding
    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Span<UInt8>

        @inlinable
        @_lifetime(copy span)
        init(_ span: Span<UInt8>) {
            self.span = span
        }
    }
}

extension RFC_4648.Base64.URL.SpanWrapper {
    /// Encodes span bytes to URL-safe Base64 string
    ///
    /// - Parameter padding: Whether to include padding characters (default: false)
    /// - Returns: URL-safe Base64 encoded string
    @inlinable
    public func encoded(padding: Bool = false) -> String {
        span.withUnsafeBufferPointer { buffer in
            String(decoding: RFC_4648.Base64.URL.encode(buffer, padding: padding) as [UInt8], as: UTF8.self)
        }
    }
}

// MARK: - Base32 Span Support

extension RFC_4648.Base32 {
    /// Wrapper for Span-based Base32 encoding
    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Span<UInt8>

        @inlinable
        @_lifetime(copy span)
        init(_ span: Span<UInt8>) {
            self.span = span
        }
    }
}

extension RFC_4648.Base32.SpanWrapper {
    /// Encodes span bytes to Base32 string
    ///
    /// - Parameter padding: Whether to include padding characters (default: true)
    /// - Returns: Base32 encoded string
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        span.withUnsafeBufferPointer { buffer in
            String(decoding: RFC_4648.Base32.encode(buffer, padding: padding) as [UInt8], as: UTF8.self)
        }
    }

    /// Access to Base32-HEX encoding
    @inlinable
    public var hex: RFC_4648.Base32.Hex.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base32.Hex.SpanWrapper(span)
        }
    }
}

// MARK: - Base32.Hex Span Support

extension RFC_4648.Base32.Hex {
    /// Wrapper for Span-based Base32-HEX encoding
    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Span<UInt8>

        @inlinable
        @_lifetime(copy span)
        init(_ span: Span<UInt8>) {
            self.span = span
        }
    }
}

extension RFC_4648.Base32.Hex.SpanWrapper {
    /// Encodes span bytes to Base32-HEX string
    ///
    /// - Parameter padding: Whether to include padding characters (default: true)
    /// - Returns: Base32-HEX encoded string
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        span.withUnsafeBufferPointer { buffer in
            String(decoding: RFC_4648.Base32.Hex.encode(buffer, padding: padding) as [UInt8], as: UTF8.self)
        }
    }
}

// MARK: - Span Extensions

extension Span where Element == UInt8 {
    /// Access to Base16/Hex encoding for Span
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let span: Span<UInt8> = ...
    /// span.hex.encoded()  // "deadbeef"
    /// span.hex.encoded(uppercase: true)  // "DEADBEEF"
    /// ```
    @inlinable
    public var hex: RFC_4648.Base16.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base16.SpanWrapper(self)
        }
    }

    /// Access to Base64 encoding for Span
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let span: Span<UInt8> = ...
    /// span.base64.encoded()  // Standard Base64
    /// span.base64.url.encoded()  // URL-safe Base64
    /// ```
    @inlinable
    public var base64: RFC_4648.Base64.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base64.SpanWrapper(self)
        }
    }

    /// Access to Base32 encoding for Span
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let span: Span<UInt8> = ...
    /// span.base32.encoded()  // Standard Base32
    /// span.base32.hex.encoded()  // Base32-HEX
    /// ```
    @inlinable
    public var base32: RFC_4648.Base32.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base32.SpanWrapper(self)
        }
    }
}
