//
//  CollectionTypeExtension.swift
//  IronThrone
//
//  Created by Carl on 30/3/2017.
//  Copyright © 2017 serious. All rights reserved.
//

import Foundation

//private let jsonToData: (Any) -> Data? = {
//    do {
//        let jsonData = try JSONSerialization.data(withJSONObject: $0
//            , options: JSONSerialization.WritingOptions())
//        return jsonData
//    } catch {
//        return nil
//    }
//}

public struct DictionaryWrapper<Key: Hashable & ExpressibleByStringLiteral, Value> {
    fileprivate let base: Dictionary<Key, Value>
    init(base: Dictionary<Key, Value>) {
        self.base = base
    }
}

public struct ArrayWrapper {
    fileprivate let base: Array<Any>
    init(base: Array<Any>) {
        self.base = base
    }
}

public protocol JsonConvertible {
    var jsonSerializationObject: Any { get }
}
extension DictionaryWrapper: JsonConvertible {
    public var jsonSerializationObject: Any {
        return base
    }
}
extension ArrayWrapper: JsonConvertible {
    public var jsonSerializationObject: Any {
        return base
    }
}

extension JsonConvertible {
    public func toJsonData() -> Data? {
        let jsonObject = self.jsonSerializationObject
        guard JSONSerialization.isValidJSONObject(jsonObject) else { return nil }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject
                , options: JSONSerialization.WritingOptions())
            return jsonData
        } catch {
            return nil
        }
    }

    public func toJsonString() -> String? {
        return toJsonData().flatMap { String(data: $0, encoding: String.Encoding.utf8) }
    }
}

extension Dictionary where Key == String, Value: Any {
    public var irt: DictionaryWrapper<Key, Value> {
        return DictionaryWrapper(base: self)
    }
}

extension Array {
    public var irt: ArrayWrapper {
        return ArrayWrapper(base: self)
    }
}

//extension NamespaceWrapper where T == Dictionary<String, Any> {
//    public func toJsonData() -> Data? {
//        return jsonToData(wrappedValue)
//    }
//
//    public func toJsonString() -> String? {
//        return toJsonData().flatMap { String(data: $0, encoding: String.Encoding.utf8) }
//    }
//}
//
//extension NamespaceWrapper where T == Array<Any> {
//    public func toJsonData() -> Data? {
//        return jsonToData(wrappedValue)
//    }
//
//    public func toJsonString() -> String? {
//        return toJsonData().flatMap { String(data: $0, encoding: String.Encoding.utf8) }
//    }
//
//}
