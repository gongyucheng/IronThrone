//
//  NetworkEnums.swift
//  IronThrone
//
//  Created by Carl Chen on 10/9/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

/**
 Http 请求方式
 */
public enum HttpMethod {
    case get
    case post
}


/**
 HTTP DNS 支持
 */
public enum HttpDNSType {
    /// 一般类型。IP 或者域名。使用系统的 DNS 解析服务
    case none
    /// httpDNS，关联值为域名解析后的 IP 地址
    case httpDNS(String)
}

/**
 *  主机的相关属性配置
 */
public struct HostAttributes {
    /// HTTP DNS 类型(默认没有 HttpDNS)
    public var httpDNSType: HttpDNSType = .none
    /// 支持 https (默认支持)
    public var supportHttps: Bool = true
    /// 端口号，默认 80
    public var port: UInt16 = 80

    public init(port: UInt16 = 80
        , isSupportHttps: Bool = true
        , httpDNSType: HttpDNSType = .none) {
        self.port = port
        self.supportHttps = isSupportHttps
        self.httpDNSType = httpDNSType
    }
}



