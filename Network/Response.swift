//
//  Response.swift
//  IronThrone
//
//  Created by Carl Chen on 10/9/16.
//  Copyright © 2016 serious. All rights reserved.
//

import UIKit
import Alamofire

public struct HttpDataResponse {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let error: Error?
}

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

        // Network check feature
        if !isNetworkReachable() {
            completionHandler(.failure(NetworkError.noAvaliableNetwork))
            return
        }

        // request network
        let apiNetworkGroup = (self as? APIRequestable)
            .flatMap{ type(of: $0) }?
            .networkGroup

        if let group = apiNetworkGroup {
            // API 请求，显示 status bar 上的网络请求菊花，并且请求结果类型是 JSON。
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            group.enter()

            let request = NetworkKit.shared.alamofireManager
                .request(urlString
                    , method: method.convertToAlamofireHttpMethod()
                    , parameters: parameters
                    , encoding: URLEncoding.default
                    , headers: headers)
            request.responseJSON { (response) in
                group.leave()
                let result = NetworkKit.handleAlamofireAPIResponse(jsonResponse: response)
                completionHandler(result)

                if let apiRequest = self as? APIRequestable {
                    NetworkKit.APIConfiguration
                        .generalResponseCallback?(apiRequest, result, response.response)
                }
            }

            group.notify(queue: DispatchQueue.main) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        } else {
            // 非 API 的 HTTP 请求
            let request = Alamofire.request(urlString
                , method: method.convertToAlamofireHttpMethod()
                , parameters: parameters
                , encoding: URLEncoding.default
                , headers: headers)
            request.response { (dataResponse) in
                let response = HttpDataResponse(request: dataResponse.request
                    , response: dataResponse.response
                    , data: dataResponse.data
                    , error: dataResponse.error)
                completionHandler(.success(response))
            }
        }

    }
}

public struct MultipartDataPacketAttribute {
    var data: Data
    var mimeType: String?
    var fileName: String?

    init(data: Data) {
        self.data = data
    }
}

public protocol Multipartable {
    func packetAttribute() -> MultipartDataPacketAttribute
}

extension UIImage: Multipartable {

    public func packetAttribute() -> MultipartDataPacketAttribute {
        var result = MultipartDataPacketAttribute(data: UIImageJPEGRepresentation(self, 0.8)!)
        result.mimeType = "image/jpeg"

        return result
    }

}

extension String: Multipartable {

    public func packetAttribute() -> MultipartDataPacketAttribute {
        return MultipartDataPacketAttribute(data: self.data(using: String.Encoding.utf8)!)
    }

}
