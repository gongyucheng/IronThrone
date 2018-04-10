//
//  DataExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension Data: NamespaceWrappable {}
extension NamespaceWrapper where T == Data {
    /**
     按位异或

     - parameter key: 加密 key

     - returns: 异或结果
     */
    public func xor(key: UInt8) -> Data {
        let dataByte = wrappedValue.withUnsafeBytes {
            (bytes: UnsafePointer<UInt8>) -> UnsafePointer<UInt8> in
            return bytes
        }

        let dataLength = wrappedValue.count / MemoryLayout<UInt8>.size

        let resultByte = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLength)

        for i in 0 ..< dataLength {
            let tmpByte = dataByte[i]

            let xorByte = tmpByte ^ key

            resultByte[i] = xorByte
        }
        let result = Data(bytes: resultByte, count: dataLength)
        resultByte.deallocate()

        return result
    }

    public func toJsonObject() -> Any? {
        do {
            let object = try JSONSerialization.jsonObject(with: wrappedValue
                , options: JSONSerialization.ReadingOptions())
            return object
        } catch {
            return nil
        }
    }

    public func toBytes() -> UnsafePointer<UInt8> {
        return wrappedValue
            .withUnsafeBytes({ (data: UnsafePointer<UInt8>) -> UnsafePointer<UInt8> in
                return data
            })
    }
}
