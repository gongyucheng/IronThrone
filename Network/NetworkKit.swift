//
//  NetworkKit.swift
//  IronThrone
//
//  Created by Carl Chen on 9/18/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation
import Alamofire

extension NetworkKit {

    @discardableResult
    public static func requestHttp(url: URL
        , method: HttpMethod
        , parameters: [String: Any]? = nil
        , headers: [String: String]? = nil) -> HttpRequestable {

        // TODO: 检查是否 http 或者 https


        let result = HttpRequest(method: method, urlString: url.absoluteString)
        result.headers = headers
        result.parameters = parameters

        return result
    }

    @discardableResult
    public static func requestAPI(apiHost host: String
        , apiName: String
        , method: HttpMethod
        , parameters: [String: Any]? = nil
        , headers: [String: String]? = nil) -> APIRequestable {

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

        let result = APIRequest(method: method, urlString: urlString)
        result.headers = finalHeaders
        result.parameters = parameters
        
        return result
    }
}

public class NetworkKit {

    public static let shared = NetworkKit()
    private init() {
        
    }

    var alamofireManager = SessionManager()

    /// API 配置相关
    public struct APIConfiguration {
        /// 通用 API 请求 HTTP Header
        public static var generalHttpHeader: [String: String] = [:]
        /// API 请求头部附带 trace 信息的固定部分。对 Daenerys 来说就是 deviceID
        public static var traceIDFixedPart: String?
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

/// 判断网络状态
public let reachability = Reachability()

public func isNetworkReachable() -> Bool {
    // Default is true in case of can not initialize the reachability.
    var result = true

    if let tmp = reachability {
        if !tmp.isReachable {
            result = false
        }
    }else {
        print("IronThrone Log: Reachability is not initialized.")
    }

    return result
}
