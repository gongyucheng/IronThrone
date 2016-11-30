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


public struct ModelTransformer<T: APIModelConvertible> {
    public static var dicToAPIModel: ([String: Any]) -> HttpResult<T> {
        return { dic in
            guard let model = T.toModel(dic: dic) else {
                return HttpResult.failure(NetworkError.dataFormatIncorrect)
            }

            return HttpResult.success(model)
        }
    }

    public static var dicArrayToAPIModelArray: ([[String: Any]]) -> HttpResult<[T]> {
        return { dicArray in
            let modelArray = dicArray.flatMap { T.toModel(dic: $0) }

            return HttpResult.success(modelArray)
        }
    }
}

public struct Transformer {
    public static var jsonToDic: (Any) -> HttpResult<[String: Any]> {
        return { json in
            guard let dic = json as? [String: Any] else {
                return HttpResult.failure(NetworkError.dataFormatIncorrect)
            }
            return HttpResult.success(dic)
        }
    }

    public static var jsonToDicArray: (Any) -> HttpResult<[[String: Any]]> {
        return { json in
            guard let dicArray = json as? [[String: Any]] else {
                return HttpResult.failure(NetworkError.dataFormatIncorrect)
            }
            return HttpResult.success(dicArray)
        }
    }

    public static var dicToStandardResult:
        ([String: Any]) -> HttpResult<(isSuccess: Bool, responseDic: [String: Any])> {
        return { dic in
            guard let resultDic = dic["result"] as? [String: Any]
                , let isSuccess = (resultDic["is_success"] as? NSNumber)?.boolValue else {
                    return HttpResult.failure(NetworkError.dataFormatIncorrect)
            }

            return HttpResult.success((isSuccess: isSuccess, responseDic: resultDic))
        }
    }
}
