//
//  Int64Extension.swift
//  IronThrone
//
//  Created by Carl Chen on 11/7/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension Int64Proxy {
    var base36String: String {
        var charArray: [Character] = []

        let base36 = "0123456789abcdefghijklmnopqrstuvwxyz"
        let mod = Int64(base36.characters.count)
        var loopValue = base
        repeat {
            let index = base36.characters.index(base36.startIndex, offsetBy: Int(loopValue % mod))
            let value = base36[index]
            charArray.insert(value, at: 0)
            loopValue /= mod
        } while loopValue > 0

        return String(charArray)
    }
}

extension Int64: IronThroneCompatible {
    public typealias IronThroneCompatibleType = Int64Proxy
    public var irt: IronThroneCompatibleType {
        return Int64Proxy(base: self)
    }

    public static var irt: IronThroneCompatibleType.Type {
        return Int64Proxy.self
    }
}

public struct Int64Proxy {
    fileprivate let base: Int64
    init(base: Int64) {
        self.base = base
    }
}
