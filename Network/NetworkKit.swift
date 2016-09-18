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
    public static func requestAPI(apiHost host: String
        , apiName: String
        , method: HttpMethod
        , parameters: [String: Any]? = nil
        , headers: [String: String]? = nil) -> APIRequestable {

        let hostAttributes: HostAttributes? = shared.hostsConfiguration[host]

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

        var finalHeaders = headers
        if httpDNSIP != nil {
            finalHeaders?["HOST"] = host
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

    public var hostsConfiguration: [String: HostAttributes] = [:]
}

