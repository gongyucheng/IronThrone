//
//  APIResultTransformer.swift
//  IronThrone
//
//  Created by Carl Chen on 10/11/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

public protocol APIModelConvertible {
    static func toModel(dic: [String: Any]) -> Self?
}

/**
 由于没有找到办法写泛型的闭包，所以还是以静态函数形式来组织转换组件
 **/
public struct APIResultTransformer {

    public static func jsonToDic(_ json: Any) -> HttpResult<[String: Any]> {
        guard let dic = json as? [String: Any] else {
            return HttpResult.failure(NetworkKitError.dataFormatIncorrect)
        }
        return HttpResult.success(dic)
    }

    public static func dicToAPIModel<T: APIModelConvertible>(_ dic: [String: Any])
    -> HttpResult<T> {
        guard let model = T.toModel(dic: dic) else {
            return HttpResult.failure(NetworkKitError.dataFormatIncorrect)
        }

        return HttpResult.success(model)
    }

    public static func jsonToDicArray(_ json: Any) -> HttpResult<[[String: Any]]> {
        guard let dicArray = json as? [[String: Any]] else {
            return HttpResult.failure(NetworkKitError.dataFormatIncorrect)
        }
        return HttpResult.success(dicArray)
    }

    public static func dicArrayToAPIModelArray<T: APIModelConvertible>(_ dicArray: [[String: Any]])
    -> HttpResult<[T]> {
        let modelArray = dicArray.flatMap { T.toModel(dic: $0) }

        return HttpResult.success(modelArray)
    }
}
