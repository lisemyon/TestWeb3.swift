//
//  UnsignedInteger+BytesConvertible.swift
//  Web3
//
//  Created by Koray Koska on 06.04.18.
//

import Foundation

extension UInt8: BytesConvertible {}
extension UInt16: BytesConvertible {}
extension UInt32: BytesConvertible {}
extension UInt64: BytesConvertible {}

extension UnsignedInteger {

    /**
     * Bytes are concatenated to make an UnsignedInteger Object (expected to be big endian)
     *
     * [0b1111_1011, 0b0000_1111]
     * =>
     * 0b1111_1011_0000_1111
     *
     * - parameter bytes: The bytes to be converted
     *
     */
    public init(_ bytes: Bytes) {
        // 8 bytes in UInt64, etc. clips overflow
        let prefix = bytes.suffix(MemoryLayout<Self>.size)
        var value: UInt64 = 0
        prefix.forEach { byte in
            value <<= 8 // 1 byte is 8 bits
            value |= (UInt64(exactly: byte) ?? 0)
        }

        self.init(value)
    }

    /**
     *
     * Convert an UnsignedInteger into its collection of bytes (big endian)
     *
     * 0b1111_1011_0000_1111
     * =>
     * [0b1111_1011, 0b0000_1111]
     * ... etc.
     *
     * - returns: The generated Byte array.
     *
     */
    public func makeBytes() -> Bytes {
        let byteMask: Self = 0b1111_1111
        let size = MemoryLayout<Self>.size
        var copy = self
        var bytes: [Byte] = []
        (1...size).forEach { _ in
            let next = copy & byteMask
            #if swift(>=4)
            let byte = (Byte(exactly: UInt64(next)) ?? 0)
            #else
            let byte = Byte(next.toUIntMax())
            #endif
            bytes.insert(byte, at: 0)
            copy.shiftRight(8)
        }
        return bytes
    }
}
