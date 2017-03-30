//
//  IronThrone.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//
import Foundation

public protocol NamespaceWrappable {
    associatedtype WrapperType
    var irt: WrapperType { get }
    static var irt: WrapperType.Type { get }
}

public extension NamespaceWrappable {
    var irt: NamespaceWrapper<Self> {
        return NamespaceWrapper(value: self)
    }

    static var irt: NamespaceWrapper<Self>.Type {
        return NamespaceWrapper.self
    }
}

public struct NamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
