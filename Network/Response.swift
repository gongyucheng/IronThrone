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

        // Network check feature
        if !isNetworkReachable() {
            completionHandler(.failure(NetworkError.noAvaliableNetwork))
            return
        }

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

extension NetworkKit {
    public static func requestAPIByMultipart(apiHost host: String
    , apiName: String
    , multipartParameters: [String: Multipartable]
    , fileListDic: [String: [Multipartable]] = [:]
    , headers: [String: String]? = nil
    , completionHandler: @escaping (HttpResult<Any>) -> Void) {
        let hostAttributes: HostAttributes? = APIConfiguration.hostsAttributes[host]

        let supportHttps = hostAttributes?.supportHttps ?? true
        let httpDNSIP: String?
        if let httpDNSType = hostAttributes?.httpDNSType, case let .httpDNS(ip) = httpDNSType {
            httpDNSIP = ip
        } else {
            httpDNSIP = nil
        }

        let port = hostAttributes?.port ?? 80

        let urlString = (supportHttps ? "https://" : "http://")
            + (httpDNSIP == nil ? host : httpDNSIP! )
            + (port == 80 ? "" : ":\(port)")
            + "/"
            + apiName

        var finalHeaders = APIConfiguration.generalHttpHeader
        if httpDNSIP != nil {
            finalHeaders["HOST"] = host
        }

        // handle http header of trace ID.
        if let traceIDFixedPart = APIConfiguration.traceIDFixedPart, !traceIDFixedPart.isEmpty {

            let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
            let randomNum: Int64 = timestamp * 10000 + Int64(APIRequest.requestSequence % 10000)

            finalHeaders["x-ricebook-trace"] = traceIDFixedPart + "-" + randomNum.irt.base36String

            APIRequest.requestSequence += 1
            if APIRequest.requestSequence >= 10000 {
                APIRequest.requestSequence %= 10000
            }
        }


        let group = APIRequest.networkGroup
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        group.enter()

        shared.alamofireManager
            .upload(multipartFormData: { (multipartFormData) in
                for (key, value) in multipartParameters {
                    let packetAttribute = value.packetAttribute()
                    if let fileName = packetAttribute.fileName {
                        if let mimeType = packetAttribute.mimeType {
                            multipartFormData.append(packetAttribute.data
                                , withName: key, fileName: fileName, mimeType: mimeType)
                        }
                    }else if let mimeType = packetAttribute.mimeType {
                        multipartFormData.append(packetAttribute.data
                            , withName: key, mimeType: mimeType)
                    }else {
                        multipartFormData.append(packetAttribute.data, withName: key)
                    }

                }

                for (key, value) in fileListDic {
                    for (index, item) in value.enumerated() {
                        let packetAttribute = item.packetAttribute()
                        let fileName = packetAttribute.fileName ?? "\(index)"
                        let mimeType = packetAttribute.mimeType ?? "text/plain"
                        multipartFormData.append(packetAttribute.data, withName: key
                            , fileName: fileName, mimeType: mimeType)
                    }
                }
            }, to: urlString, headers: finalHeaders) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _ , _):
                    upload.responseJSON { (response) in
                        group.leave()

                        let result: HttpResult<Any>
                        switch response.result {
                        case let .success(json):
                            result = HttpResult.success(json)
                        case let .failure(error):
                            if let serverErrorInfo = response.data?.irt.toJsonObject()
                                as? [String: Any]
                            , let errorCode = serverErrorInfo["error_code"] as? Int {
                                let displayMsg = serverErrorInfo["display_msg"] as? String
                                let serverError = NetworkError.APIServerError(code: errorCode
                                    , displayMsg: displayMsg)
                                result = HttpResult.failure(serverError)
                            } else {
                                result = HttpResult.failure(error)
                            }
                        }

                        completionHandler(result)

                    }
                case .failure(_):
                    group.leave()

                    let error = HttpResult<Any>.failure(NetworkError.multipartDataEncodingIncorrect)
                    completionHandler(error)
                }
            }


        group.notify(queue: DispatchQueue.main) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
