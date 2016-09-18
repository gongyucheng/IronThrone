//
//  DateExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension DateProxy {

}

extension Date: IronThroneCompatible {
    public typealias CompatibleType = DateProxy
    public var irt: CompatibleType {
        return DateProxy(base: self)
    }

    public static var irt: CompatibleType.Type {
        return DateProxy.self
    }
}

public struct DateProxy {
    fileprivate let base: Date
    init(base: Date) {
        self.base = base
    }
}
