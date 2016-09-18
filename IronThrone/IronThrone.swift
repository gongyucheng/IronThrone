//
//  IronThrone.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//
import Foundation

public protocol IronThroneCompatible {
    associatedtype CompatibleType
    var irt: CompatibleType { get }
    static var irt: CompatibleType.Type { get }
}

public struct IronThrone<Base> {
    public let base: Base

    init(base: Base) {
        self.base = base
    }
}

public extension IronThroneCompatible {
    public var irt: IronThrone<Self> {
        return IronThrone(base: self)
    }

    public static var irt: IronThrone<Self>.Type {
        return IronThrone.self
    }
}

extension NSObject: IronThroneCompatible { }
