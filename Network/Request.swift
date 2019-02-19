//
//  Request.swift
//  IronThrone
//
//  Created by Carl Chen on 10/9/16.
//  Copyright © 2016 serious. All rights reserved.
//

import Foundation
import Alamofire

public enum HttpParameterEncodingType {
    case json
    case url
}

public enum HttpRequestType {
    case api(APIRequestInfo)
    case apiMultipart(APIMultipartRequestInfo)

    case http
    case httpDownload(HttpDownloadRequestInfo)
    case upload(Data)

    var hasStatusBarNetworkIndicator: Bool {
        switch self {
        case .api, .apiMultipart:
            return true
        default:
            return false
        }
    }
}

public struct APIRequestInfo {
    var extraInfo: [String: Any]?
}

public struct APIMultipartRequestInfo {
    var multipartParameters: [String: Multipartable]
    var fileListDic: [String: [Multipartable]]
}

public struct HttpDownloadRequestInfo {
    var destinationFileURL: URL
    var downloadOptions: DownloadOptions?
    var downloadProgress: (Int64, Int64) -> Void
    
    public struct DownloadOptions : OptionSet {
        
        /// Returns the raw bitmask value of the option and satisfies the `RawRepresentable` protocol.
        public let rawValue: UInt
        
        /// A `DownloadOptions` flag that creates intermediate directories for the destination URL if specified.
        public static let createIntermediateDirectories = DownloadOptions(rawValue: 1 << 0)
        
        /// A `DownloadOptions` flag that removes a previous file from the destination URL if specified.
        public static let removePreviousFile = DownloadOptions(rawValue: 1 << 1)
        
        /// Creates a `DownloadFileDestinationOptions` instance with the specified raw value.
        ///
        /// - parameter rawValue: The raw bitmask value for the option.
        ///
        /// - returns: A new log level instance.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
}


public protocol HttpRequestable {
    var method: HttpMethod { get }
    var urlString: String { get }
    var parameters: [String: Any]? { get set }
    var headers: [String: String]? { get set }
    var parameterEncodingType: HttpParameterEncodingType { get set }
    var requestType: HttpRequestType { get set }
    
    init(method: HttpMethod, urlString: String)
    
    /// cancel request when already trigger reponse func,
    /// Note: apiMultipart not support cancel func
    func cancel()
}


class HttpRequest: HttpRequestable {
    let method: HttpMethod
    let urlString: String
    var parameters: [String : Any]?
    var headers: [String : String]?
    var parameterEncodingType: HttpParameterEncodingType = .url
    var requestType: HttpRequestType = .http

    var alamofireRequest: Request?
    
    required init(method: HttpMethod, urlString: String) {
        self.method = method
        self.urlString = urlString
    }
    
    func cancel() {
        alamofireRequest?.cancel()
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
        var result = MultipartDataPacketAttribute(data: self.jpegData(compressionQuality: 0.8)!)
        result.mimeType = "image/jpeg"

        return result
    }

}

extension String: Multipartable {

    public func packetAttribute() -> MultipartDataPacketAttribute {
        return MultipartDataPacketAttribute(data: self.data(using: .utf8)!)
    }
    
}


