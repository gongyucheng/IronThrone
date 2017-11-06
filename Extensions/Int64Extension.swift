//
//  Int64Extension.swift
//  IronThrone
//
//  Created by Carl Chen on 11/7/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension Int64: NamespaceWrappable {}
extension NamespaceWrapper where T == Int64 {
    public var base36String: String {
        var charArray: [Character] = []

        let base36 = "0123456789abcdefghijklmnopqrstuvwxyz"
        let mod = Int64(base36.count)
        var loopValue = wrappedValue
        repeat {
            let index = base36.index(base36.startIndex, offsetBy: Int(loopValue % mod))
            let value = base36[index]
            charArray.insert(value, at: 0)
            loopValue /= mod
        } while loopValue > 0

        return String(charArray)
    }
}


