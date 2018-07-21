//
//  NetworkKit.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Public Interface
extension NetworkKit {

    public static func requestHttp(url: URL
        , method: HttpMethod
        , parameters: [String: Any]? = nil
        , headers: [String: String]? = nil) -> HttpRequestable {

        let request = HttpRequest(method: method, urlString: url.absoluteString)
        request.headers = headers
        request.parameters = parameters

        return request
    }

    public static func requestHttpWithJsonEncoding(url: URL
        , method: HttpMethod
        , parameters: [String: Any]? = nil
        , headers: [String: String]? = nil) -> HttpRequestable {

        let request = HttpRequest(method: method, urlString: url.absoluteString)
        request.headers = headers
        request.parameters = parameters
        request.parameterEncodingType = .json

        return request
    }

    public static func httpDownload(sourceHttpUrl: URL
        , destinationFileURL: URL
        , method: HttpMethod
        , parameters: [String: Any]? = nil
        , headers: [String: String]? = nil
        , downloadProgress: @escaping (Int64, Int64) -> Void = {_,_ in } ) -> HttpRequestable {

        let downloadInfo = HttpDownloadRequestInfo(destinationFileURL: destinationFileURL
            , downloadProgress: downloadProgress)

        let request = HttpRequest(method: method, urlString: sourceHttpUrl.absoluteString)
        request.headers = headers
        request.parameters = parameters
        request.requestType = .httpDownload(downloadInfo)

        return request

    }

    public static func httpUpload(data: Data
        , to url: URL
        , method: HttpMethod
        , headers: [String: String]? = nil) -> HttpRequestable {
        let request = HttpRequest(method: method, urlString: url.absoluteString)
        request.headers = headers
        request.requestType = .upload(data)
        
        return request
    }

    public static func requestAPI(apiHost host: String
        , apiName: String
        , method: HttpMethod
        , parameters: [String: Any]? = nil
        , headers: [String: String]? = nil
        , extraInfo: [String: Any]? = nil) -> HttpRequestable {

        let requestInfo = p_generateAPIRequestInfo(host: host, apiName: apiName)

        let apiInfo = APIRequestInfo(extraInfo: extraInfo)

        let request = HttpRequest(method: method, urlString: requestInfo.wholeURLString)
        request.headers = requestInfo.httpHeaders
        request.parameters = parameters
        request.requestType = .api(apiInfo)

        return request
    }


    public static func requestAPIByMultipart(apiHost host: String
        , apiName: String
        , multipartParameters: [String: Multipartable]
        , fileListDic: [String: [Multipartable]] = [:]
        , headers: [String: String]? = nil ) -> HttpRequestable {

        let multipartInfo = APIMultipartRequestInfo(multipartParameters: multipartParameters
            , fileListDic: fileListDic)

        let requestInfo = p_generateAPIRequestInfo(host: host, apiName: apiName)
        let request = HttpRequest(method: .post, urlString: requestInfo.wholeURLString)
        request.headers = requestInfo.httpHeaders
        request.requestType = .apiMultipart(multipartInfo)

        return request
    }
}


public class NetworkKit {

    public static let shared = NetworkKit()
    private init() {
        
    }

    var alamofireManager = SessionManager()
    static let networkGroup: DispatchGroup = DispatchGroup()

    /// API 配置相关
    public struct APIConfiguration {

        public struct ResponseData {
            public let request: HttpRequestable
            public let result: HttpResult<Any>
            public let response: HTTPURLResponse?
            /// 请求耗时，单位毫秒
            public let requestTimeSpent: Int64
            public let cURLRepresentation: String
        }

        static var requestSequence: Int = 0

        /// API 接口请求的统一回调处理
        public static var generalResponseCallback: ((ResponseData) -> Void)? = nil

        /// 通用 API 请求 HTTP Header
        public static var generalHttpHeader: [String: String] = [:]
        /// API 请求头部附带 trace 信息的固定部分。对 Daenerys 来说就是 deviceID
        public static var traceIDFixedPart: String?
        public static var traceIDRandomPart: String {
            let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
            let randomNum: Int64 =
                timestamp * 10000 + Int64(NetworkKit.APIConfiguration.requestSequence % 10000)
            return randomNum.irt.base36String
        }
        /// API 服务器属性信息
        public static var hostsAttributes: [String: HostAttributes] = [:] {
            didSet {
                var policies: [String: ServerTrustPolicy] = [:]

                hostsAttributes
                    .map { (host, attributes) -> String? in
                        if case let .httpDNS(ip) = attributes.httpDNSType, !ip.isEmpty {
                            return ip
                        }
                        return nil
                    }
                    .forEach { (host) in
                        guard let diableHost = host else {
                            return
                        }

                        policies[diableHost] = ServerTrustPolicy.disableEvaluation
                }

                let serverTrustPolicyMananger = ServerTrustPolicyManager(policies: policies)

                NetworkKit.shared.alamofireManager.session.finishTasksAndInvalidate()
                let manager = SessionManager(serverTrustPolicyManager: serverTrustPolicyMananger)
                manager.delegate.taskWillPerformHTTPRedirection = {
                    session, task, response, request in
                    var redirectRequest = request

                    if let redirectURL = request.url {
                        // 去掉所有的 redirect 请求中带有的原始请求里自定义的 http header
                        redirectRequest = URLRequest(url: redirectURL)
                    }

                    return redirectRequest
                }
                NetworkKit.shared.alamofireManager = manager

            }
        }
    }


    /// 错误码转换字典
    public static var errorCodeMapDic: [Int: String] = [
        NetworkError.dataFormatIncorrect.rawValue: "sorry~ 服务器返回数据异常",
        NetworkError.multipartDataEncodingIncorrect.rawValue: "multipart 数据 encode 错误",
        NetworkError.noAvaliableNetwork.rawValue: "网络更新失败，请稍候重试",
        NetworkError.APIServerError.serverInternalError.errorCode: "sorry~ 服务器好像有点问题",
        NetworkError.APIServerError.invalidParameter.errorCode: "参数错误",
        NetworkError.APIServerError.wrongHttpMethod.errorCode: "接口请求方式错误",
    ]

}

extension NetworkKit {

    static func handleAlamofireAPIResponse(jsonResponse: DataResponse<Any>) -> HttpResult<Any> {
        let result: HttpResult<Any>
        switch jsonResponse.result {
        case let .success(json):
            if jsonResponse.response?.statusCode == 200 {
                // 成功
                result = .success(json)
            } else {
                print("IronThrone log: Request failure, do you need more info??")

                if let serverErrorInfo = jsonResponse.data?.irt.toJsonObject() as? [String: Any]
                , let errorCode = serverErrorInfo["error_code"] as? Int {
                    let displayMsg = serverErrorInfo["display_msg"] as? String
                    let serverError = NetworkError.APIServerError(code: errorCode,
                                                                  displayMsg: displayMsg)
                    result = .failure(serverError)
                } else {
                    result = .failure(NetworkError.dataFormatIncorrect)
                }

            }
        case let .failure(error):
            // 服务器返回数据非 json 格式
            result = .failure(NetworkError.dataFormatIncorrect)

            print("IronThrone log: The response data of API is not Json format. \(error.localizedDescription)")
        }

        return result
    }

    fileprivate static func p_generateAPIRequestInfo(host: String, apiName: String)
    -> (wholeURLString: String, httpHeaders:[String: String]) {
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
            finalHeaders["x-ricebook-trace"] = traceIDFixedPart
                + "-"
                + APIConfiguration.traceIDRandomPart

            NetworkKit.APIConfiguration.requestSequence += 1
            if NetworkKit.APIConfiguration.requestSequence >= 10000 {
                NetworkKit.APIConfiguration.requestSequence %= 10000
            }
        }

        return (urlString, finalHeaders)
    }
}

/// 判断网络状态
public let reachability = Reachability()

public func isNetworkReachable() -> Bool {
    // Default is true in case of can not initialize the reachability.
    var result = true

    if let tmp = reachability {
        if tmp.connection == .none {
            result = false
        }
    }else {
        print("IronThrone Log: Reachability is not initialized.")
    }

    return result
}
