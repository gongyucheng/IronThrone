//
//  HttpResult.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//
import Foundation

public enum HttpResult<T> {
    case success(T)
    case failure(Error)
}

extension HttpResult {
    public func flatMap<U>(_ transform: (T) -> HttpResult<U>) -> HttpResult<U> {
        let result: HttpResult<U>
        switch self {
        case let .success(value):
            result = transform(value)
        case let .failure(error):
            result = .failure(error)
        }
        return result
    }

    public func map<U>(_ transform: (T) -> U) -> HttpResult<U> {
        let result: HttpResult<U>
        switch self {
        case let .success(value):
            result = .success(transform(value))
        case let .failure(error):
            result = .failure(error)
        }
        return result
    }

}

extension HttpResult where T: Collection {
    public func apiResultMap<U>(_ transform: (T) -> U?) -> HttpResult<U> {
        let result: HttpResult<U>
        switch self {
        case let .success(value):
            if let newValue = transform(value) {
                result = .success(newValue)
            } else {
                result = .failure(NetworkError.dataFormatIncorrect)
            }
        case let .failure(error):
            result = .failure(error)
        }
        return result
    }
}


extension HttpResult {
    @discardableResult
    public func successHandler(_ success: (T) -> Void) -> HttpResult<T> {
        if case let .success(value) = self {
            success(value)
        }
        return self
    }

    @discardableResult
    public func failureHandler(_ failure: (Error) -> Void) -> HttpResult<T> {
        if case let .failure(error) = self {
            failure(error)
        }
        return self
    }
}
