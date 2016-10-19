//
//  DataExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension DataProxy {
    /**
     按位异或

     - parameter key: 加密 key

     - returns: 异或结果
     */
    public func xor(key: UInt8) -> Data {
        let dataByte = base.withUnsafeBytes {
            (bytes: UnsafePointer<UInt8>) -> UnsafePointer<UInt8> in
            return bytes
        }

        let dataLength = base.count / MemoryLayout<UInt8>.size

        let resultByte = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLength)

        for i in 0 ..< dataLength {
            let tmpByte = dataByte[i]

            let xorByte = tmpByte ^ key

            resultByte[i] = xorByte
        }
        let result = Data(bytes: resultByte, count: dataLength)
        resultByte.deallocate(capacity: dataLength)

        return result
    }

    public func toJsonObject() -> Any? {
        do {
            let object = try JSONSerialization.jsonObject(with: base
                , options: JSONSerialization.ReadingOptions())
            return object
        } catch {
            return nil
        }
    }
}

extension Data: IronThroneCompatible {
    public typealias IronThroneCompatibleType = DataProxy
    public var irt: IronThroneCompatibleType {
        return DataProxy(base: self)
    }

    public static var irt: IronThroneCompatibleType.Type {
        return DataProxy.self
    }
}


public struct DataProxy {
    fileprivate let base: Data
    init(base: Data) {
        self.base = base
    }
}
