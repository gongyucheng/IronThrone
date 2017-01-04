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

public class HttpBaseResponse {
    public let request: URLRequest?
    public let response: HTTPURLResponse?

    public init(request: URLRequest?, response: HTTPURLResponse?) {
        self.request = request
        self.response = response
    }
}

public class HttpResponseSuccess: HttpBaseResponse {
    public let data: Data?

    public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?) {
        self.data = data
        super.init(request: request, response: response)
    }
}

public class HttpResponseError: HttpBaseResponse, Error {
    public let data: Data?
    public let error: Error?

    public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) {
        self.error = error
        self.data = data
        super.init(request: request, response: response)
    }
}

extension HttpMethod {
    func convertToAlamofireHttpMethod() -> Alamofire.HTTPMethod {
        switch self {
        case .get:
            return Alamofire.HTTPMethod.get
        case .post:
            return Alamofire.HTTPMethod.post
        }
    }
}

extension HttpParameterEncodingType {
    fileprivate func convertToAlamofireEncoding() -> ParameterEncoding {
        let alamofireEncoding: ParameterEncoding
        switch self {
        case .url:
            alamofireEncoding = URLEncoding.default
        case .json:
            alamofireEncoding = JSONEncoding.default
        }

        return alamofireEncoding
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

        // send network request
        let networkGroup = NetworkKit.networkGroup
        if requestType.hasStatusBarNetworkIndicator {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            networkGroup.enter()
        }

        let handleNetworkGroup: () -> Void = { _ in
            if self.requestType.hasStatusBarNetworkIndicator {
                networkGroup.leave()
            }
        }
        switch requestType {
        case .http:
            let request = Alamofire.request(urlString
                , method: method.convertToAlamofireHttpMethod()
                , parameters: parameters
                , encoding: parameterEncodingType.convertToAlamofireEncoding()
                , headers: headers)
            request.response { (dataResponse) in
                handleNetworkGroup()
                let httpResult = self.convertAlamofireResponse(request: dataResponse.request
                    , response: dataResponse.response
                    , data: dataResponse.data
                    , error: dataResponse.error)
                completionHandler(httpResult)
            }
        case .api:

            let request = NetworkKit.shared.alamofireManager
                .request(urlString
                    , method: method.convertToAlamofireHttpMethod()
                    , parameters: parameters
                    , encoding: parameterEncodingType.convertToAlamofireEncoding()
                    , headers: headers)
            request.responseJSON { (response) in
                handleNetworkGroup()
                let result = NetworkKit.handleAlamofireAPIResponse(jsonResponse: response)
                completionHandler(result)

                NetworkKit.APIConfiguration
                    .generalResponseCallback?(self, result, response.response)
            }
        case let .apiMultipart(multipartInfo):

            NetworkKit.shared.alamofireManager
                .upload(multipartFormData: { (multipartFormData) in
                    for (key, value) in multipartInfo.multipartParameters {
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

                    for (key, value) in multipartInfo.fileListDic {
                        for (index, item) in value.enumerated() {
                            let packetAttribute = item.packetAttribute()
                            let fileName = packetAttribute.fileName ?? "\(index)"
                            let mimeType = packetAttribute.mimeType ?? "text/plain"
                            multipartFormData.append(packetAttribute.data, withName: key
                                , fileName: fileName, mimeType: mimeType)
                        }
                    }
                }
                , to: urlString
                , headers: headers) { (encodingResult) in
                    switch encodingResult {
                    case .success(let upload, _ , _):
                        upload.responseJSON { (response) in
                            handleNetworkGroup()

                            let result =
                                NetworkKit.handleAlamofireAPIResponse(jsonResponse: response)
                            completionHandler(result)
                        }
                    case .failure(_):
                        handleNetworkGroup()
                        
                        let error =
                            HttpResult<Any>.failure(NetworkError.multipartDataEncodingIncorrect)
                        completionHandler(error)
                    }
                }

        case let .httpDownload(downloadInfo):
            let destination: DownloadRequest.DownloadFileDestination = { (_) in
                return (downloadInfo.destinationFileURL
                    , [.removePreviousFile, .createIntermediateDirectories])
            }

            Alamofire.download(urlString
                , method: method.convertToAlamofireHttpMethod()
                , parameters: parameters
                , encoding: parameterEncodingType.convertToAlamofireEncoding()
                , headers: headers
                , to: destination)
                .downloadProgress { progress in
                    downloadInfo.downloadProgress(progress.completedUnitCount
                        , progress.totalUnitCount)
                }
                .response { (response) in
                    handleNetworkGroup()
                    let result = self.convertAlamofireResponse(request: response.request
                        , response: response.response
                        , data: nil
                        , error: response.error)
                    completionHandler(result)
                }

        case let .upload(data):
            Alamofire.upload(data
                , to: urlString
                , method: method.convertToAlamofireHttpMethod()
                , headers: headers)
                .response { (response) in
                    handleNetworkGroup()
                    let result = self.convertAlamofireResponse(request: response.request
                        , response: response.response
                        , data: response.data
                        , error: response.error)
                    completionHandler(result)
                }
        }

        networkGroup.notify(queue: DispatchQueue.main) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

    }
}



extension HttpRequestable {
    fileprivate func convertAlamofireResponse(request: URLRequest?
        , response: HTTPURLResponse?
        , data: Data?
        , error: Error?) -> HttpResult<Any> {

        let httpResult: HttpResult<Any>
        if let responseCode = response?.statusCode, responseCode == 200 && error == nil {
            let response = HttpResponseSuccess(request: request
                , response: response
                , data: data)
            httpResult = .success(response)
        } else {
            let errorResponse = HttpResponseError(request: request
                , response: response
                , data: data, error: error)
            httpResult = .failure(errorResponse)
        }

        return httpResult
        
    }
}


