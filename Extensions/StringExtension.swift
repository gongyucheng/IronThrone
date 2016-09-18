//
//  StringExtension.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension StringProxy {

}

extension String: IronThroneCompatible {
    public typealias CompatibleType = StringProxy
    public var irt: CompatibleType {
        return StringProxy(base: self)
    }

    public static var irt: CompatibleType.Type {
        return StringProxy.self
    }
}

public struct StringProxy {
    fileprivate let base: String
    init(base: String) {
        self.base = base
    }
}
