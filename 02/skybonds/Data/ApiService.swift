//
//  ApiService.swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

struct ApiService {
    
    static let requestHeaders = [
        "Content-Type" : "application/json",
        "Accept" : "application/json"
    ]
        
    static let sessionManager = { () -> SessionManager in
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let result =  Alamofire.SessionManager(configuration: configuration)
        return result
    }()
        
    // На тот случай если захотим подсадить заглушку: вместо сервиса - локальный JSON
    static let mockupResources : [String : String] = [:]
        
    static func getURL(_ serviceMethod: Services.Methods) -> URLConvertible
    {
        if let mockupFile = mockupResources[serviceMethod.rawValue] {
            if let resourceURL = Bundle.main.resourceURL?.absoluteString {
                let result = resourceURL + mockupFile
                print("USING the MOCKUP '\(mockupFile)' for loading data from '\(serviceMethod)'\n\(result)")
                return result
            }
        }
        let result = Services.domain + serviceMethod.rawValue
        print("USING the real SERVICE '\(result)'")
        return result
    }
    
    static func getHeaders(_ requestHeaders: HTTPHeaders) -> HTTPHeaders {
        // for updating
        return requestHeaders
    }
        
    static func call<T:Codable>(_ serviceMethod: Services.Methods,
                                    method: HTTPMethod = .get,
                                    parameters: Parameters? = nil,
                                    requestHeaders: HTTPHeaders = getHeaders(requestHeaders),
                                    encoding: ParameterEncoding = JSONEncoding.default,
                                    queue: DispatchQueue? = nil,
                                    keyPath: String? = nil) -> CancellablePromise<T>
    {
        return sessionManager.request(getURL(serviceMethod), method: method, parameters: parameters, encoding: encoding, headers: requestHeaders).validate().responseObject(queue: queue, keyPath: keyPath)
    }
    
    static func callArray<T:Codable>(_ serviceMethod: Services.Methods,
                                         method: HTTPMethod = .get,
                                         parameters: Parameters? = nil,
                                         requestHeaders: HTTPHeaders = getHeaders(requestHeaders),
                                         encoding: ParameterEncoding = JSONEncoding.default,
                                         queue: DispatchQueue? = nil,
                                         keyPath: String? = nil) -> CancellablePromise<[T]>
    {
        return sessionManager.request(getURL(serviceMethod), method: method, parameters: parameters, encoding: encoding, headers: requestHeaders).validate().responseArray(queue: queue, keyPath: keyPath)
    }
    
    static func getObject<T:Codable>(_ serviceMethod: Services.Methods,
                                         parameters: Parameters? = nil,
                                         keyPath: String? = nil) -> CancellablePromise<T>
    {
        
        return call(serviceMethod, method: .get, parameters: parameters, encoding: URLEncoding.default, keyPath: keyPath)
    }
    
    static func getObject<T:Codable, Object: Codable>(_ serviceMethod: Services.Methods,
                                         with object: Object,
                                         keyPath: String? = nil) -> CancellablePromise<T>
    {
        let parameters = object.asDictionary()
        return call(serviceMethod, method: .get, parameters: parameters, encoding: URLEncoding.default, keyPath: keyPath)
    }
    
    private struct BondsInput : Codable {
        var id: String
        var from: BondPeriod
    }

    static func getBond(with id: String, from period: BondPeriod) -> CancellablePromise<BondEntity>
    {
        return getObject(.bonds, with: BondsInput(id: id, from: period))
    }
    

    
}
