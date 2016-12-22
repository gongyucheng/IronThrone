//
//  Request.swift
//  IronThrone
//
//  Created by Carl Chen on 10/9/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation

public protocol HttpRequestable {
    var method: HttpMethod { get }
    var urlString: String { get }
    var parameters: [String: Any]? { get set }
    var headers: [String: String]? { get set }

    init(method: HttpMethod, urlString: String)
}

public protocol APIRequestable: HttpRequestable {
    var traceID: String? { get set }
    var extraInfo: [String: Any]? { get set }
    static var networkGroup: DispatchGroup { get }
}

class HttpRequest: HttpRequestable {
    let method: HttpMethod
    let urlString: String
    var parameters: [String : Any]?
    var headers: [String : String]?

    required init(method: HttpMethod, urlString: String) {
        self.method = method
        self.urlString = urlString
    }
}


class APIRequest: HttpRequest, APIRequestable {
    var traceID: String?
    var extraInfo: [String: Any]?
    static let networkGroup: DispatchGroup = DispatchGroup()

    static var requestSequence: Int = 0
}
