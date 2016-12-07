//
//  NetworkError.swift
//  IronThrone
//
//  Created by Carl Chen on 11/4/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

extension NetworkError.APIServerError {
    public static var serverInternalError: NetworkError.APIServerError {
        return NetworkError.APIServerError(code: 5000001)
    }

    public static var invalidParameter: NetworkError.APIServerError {
        return NetworkError.APIServerError(code: 4000001)
    }

    public static var wrongHttpMethod: NetworkError.APIServerError {
        return NetworkError.APIServerError(code: 4050001)
    }
}

public enum NetworkError: Int {

    public struct APIServerError: UserFriendlyError {
        public var showableString: String {
            /*
             用户可见的错误信息显示优先级：
             
                1. 服务器返回的用户显示错误信息
                2. App 中定义的错误码转换字典
                3. 默认错误信息： 未知错误
             */
            var result: String?

            result = displayMsg

            if result == nil {
                result = NetworkKit.errorCodeMapDic[errorCode]
            }

            return result ?? "未知错误"
        }

        public let errorCode: Int
        public let displayMsg: String?

        public init(code: Int) {
            self.init(code: code, displayMsg: nil)
        }

        public init(code: Int, displayMsg: String?) {
            self.errorCode = code
            self.displayMsg = displayMsg
        }
    }

    case dataFormatIncorrect = 9000001
    case multipartDataEncodingIncorrect = 9000002
    case noAvaliableNetwork = 9000003
}

extension NetworkError: UserFriendlyError {
    public var errorCode: Int {
        return rawValue
    }
}


public protocol UserFriendlyError: Error {
    var errorCode: Int { get }
    var showableString: String { get }
}

extension UserFriendlyError {
    public var showableString: String {
        return  NetworkKit.errorCodeMapDic[errorCode] ?? "未知错误"
    }
}

extension Error {
    public var irt: ErrorProxy {
        return ErrorProxy(base: self)
    }
}

public extension ErrorProxy {
    public var showableString: String {
        return (base as? UserFriendlyError)?.showableString ?? "未知错误"
    }
}

public struct ErrorProxy {
    let base: Error
    init(base: Error) {
        self.base = base
    }
}

