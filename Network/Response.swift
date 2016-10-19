//
//  Response.swift
//  IronThrone
//
//  Created by Carl Chen on 10/9/16.
//  Copyright © 2016 serious. All rights reserved.
//

import UIKit
import Alamofire

extension HttpMethod {
    fileprivate func convertToAlamofireHttpMethod() -> Alamofire.HTTPMethod {
        switch self {
        case .get:
            return Alamofire.HTTPMethod.get
        case .post:
            return Alamofire.HTTPMethod.post
        }
    }
}

extension HttpRequestable {

    public func response(completionHandler: @escaping (HttpResult<Any>) -> Void) {
        // TODO: mock feature

        // TODO: network check feature


        // request network
        let request = NetworkKit.shared.alamofireManager
            .request(urlString
                , method: method.convertToAlamofireHttpMethod()
                , parameters: parameters
                , encoding: URLEncoding.default
                , headers: headers)

        let apiNetworkGroup = (self as? APIRequestable)
            .flatMap{ type(of: $0) }?
            .networkGroup

        if let group = apiNetworkGroup {
            // API 请求，显示 status bar 上的网络请求菊花，并且请求结果类型是 JSON。
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            group.enter()

            request.responseJSON { (response) in
                group.leave()

                let result: HttpResult<Any>
                switch response.result {
                case let .success(json):
                    result = HttpResult.success(json)
                case let .failure(error):
                    if let serverErrorInfo = response.data?.irt.toJsonObject() as? [String: Any]
                    , let errorCode = serverErrorInfo["error_code"] as? Int {
                        let displayMsg = serverErrorInfo["display_msg"] as? String
                        let serverError = NetworkError.APIServerError(code: errorCode,
                                                                      displayMsg: displayMsg)
                        result = HttpResult.failure(serverError)
                    } else {
                        result = HttpResult.failure(error)
                    }
                }

                completionHandler(result)
            }

            group.notify(queue: DispatchQueue.main) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        } else {
            // 非 API 的 HTTP 请求
            request.response { (dataResponse) in

            }
        }

    }
}
