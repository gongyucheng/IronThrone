//
//  StringExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension String: NamespaceWrappable { }
extension NamespaceWrapper where T == String {

    public func toJsonObject() -> Any? {
        return wrappedValue
            .data(using: String.Encoding.utf8)?
            .irt.toJsonObject()
    }

    public func match(regex: String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", argumentArray:[regex])
        return pred.evaluate(with: wrappedValue)
    }

    public func index(by: Int) -> String.Index {
        return wrappedValue.index(wrappedValue.startIndex, offsetBy: by)
    }

    public func substring(from: Int) -> String {
        return String(wrappedValue[index(by: from)...])
    }

    public func substring(to: Int) -> String {
        return String(wrappedValue[..<index(by: to)])
    }

    public func substring(with: Range<Int>) -> String {
        let startIndex = index(by: with.lowerBound)
        let endIndex = index(by: with.upperBound)
        return String(wrappedValue[startIndex..<endIndex])
    }
    
    public func substring(with: CountableClosedRange<Int>) -> String {
        let startIndex = index(by: with.lowerBound)
        let endIndex = index(by: with.upperBound)
        return String(wrappedValue[startIndex...endIndex])
    }
}
