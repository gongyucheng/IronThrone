//
//  IntExtension.swift
//  IronThrone
//
//  Created by Carl on 30/3/2017.
//  Copyright © 2017 serious. All rights reserved.
//

import Foundation

extension Int: NamespaceWrappable {}
extension NamespaceWrapper where T == Int {
    /**
     返回一个范围内的随机数

     - parameter range: 随机数范围

     - returns: 随机数
     */
    public static func randomInRange(_ range: Range<Int>) -> Int {
        let count = UInt32(range.upperBound - range.lowerBound)
        return Int(arc4random_uniform(count)) + range.lowerBound
    }
}
