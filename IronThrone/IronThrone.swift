//
//  IronThrone.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//
import Foundation

public protocol IronThroneCompatible {
    associatedtype IronThroneCompatibleType
    var irt: IronThroneCompatibleType { get }
    static var irt: IronThroneCompatibleType.Type { get }
}

public struct IronThronePrefix<Base> {
    public let base: Base

    init(base: Base) {
        self.base = base
    }
}

public extension IronThroneCompatible where Self: NSObjectProtocol {
    public var irt: IronThronePrefix<Self> {
        return IronThronePrefix(base: self)
    }

    public static var irt: IronThronePrefix<Self>.Type {
        return IronThronePrefix.self
    }
}

extension NSObject: IronThroneCompatible { }
