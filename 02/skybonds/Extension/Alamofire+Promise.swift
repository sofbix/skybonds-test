//
//  Alamofire+Promise.swift
//  skybonds
//
//  Created by Sergey Balalaev on 11.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

extension DataRequest {
    
    enum ErrorCode: Int {
        case noData = 1
        case dataSerializationFailed = 2
    }
    
    internal static func newError(_ code: ErrorCode, failureReason: String) -> ApiError {
        return ApiError(status: 0, code: code.rawValue, message: failureReason)
    }
    
    /// Utility function for checking for errors in response
    internal static func checkResponseForError(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) -> Error?
    {
        print("response :\(response.debugDescription)")
        if let error = error {
            return ApiError(response: response, error: error)
        }
        guard let _ = data else {
            let failureReason = "Data could not be serialized. Input data was nil."
            let error = newError(.noData, failureReason: failureReason)
            return error
        }
        return nil
    }
    
    /// Checking of JSON result
    internal static func checkJSONForError(value: Any?, status: Int) -> ApiError?
    {
        if let dict = value as? [String: Any] {
            if let errorCode = dict["errorCode"] as? Int, let errorMessage = dict["errorMessage"] as? String {
                if status == 200 && errorCode == 0 {
                    return nil
                }
                return ApiError(status: status, code: errorCode, message: errorMessage)
            }
            if let isError = dict["error"] as? Bool, isError,
                let errorMessage = dict["reason"] as? String
            {
                return ApiError(status: status, code: status, message: errorMessage)
            }
        }
        return nil
    }
    
    
    /// Checking of status
    internal static func checkStatus(response: HTTPURLResponse?) -> ApiError? {
        if let statusCode = response?.statusCode, statusCode != 200 {
            return ApiError(response: response, error: nil)
        }
        return nil
    }
    
    static func logout()
    {
        //
    }
    
    internal static func processResponse(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?, keyPath: String?) -> Any? {
        let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
        let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)
        
        if let statusCode = response?.statusCode {
            if statusCode == 401 { // это сессия утратила доступ
                DispatchQueue.main.sync {
                    logout()
                }
            }
            // logout не делаем если нет прав
//            else if statusCode == 403 { // а это нет прав для данного доступа к данному ресурсу
//                DispatchQueue.main.sync {
//                    logout()
//                }
//            }
        }
        
        if let error = checkJSONForError(value: result.value, status: response?.statusCode ?? 400) {
            return error
        }
        
        if let statusCode = response?.statusCode {
            if statusCode == 401 {
                return ApiError(status: 401, code: 401, message: "Your session expired, please login again")
            } else if statusCode == 403 {
                return ApiError(status: 403, code: 403, message: "You don't have permissions.")
            }
        }
        
        if let error = checkStatus(response: response) {
            return error
        }
        
        if let error = checkResponseForError(request: request, response: response, data: data, error: error){
            return error
        }
        
        let JSON: Any?
        if let keyPath = keyPath , keyPath.isEmpty == false {
            JSON = (result.value as AnyObject?)?.value(forKeyPath: keyPath)
        } else {
            JSON = result.value
        }
        
        return JSON
    }
    
    internal static func serializationError() -> ApiError
    {
        let failureReason = "Decoder failed to serialize response."
        return newError(.dataSerializationFailed, failureReason: failureReason)
    }
    
    public static func DecodableSerializer<T: Codable>(_ keyPath: String?, decoder: JSONDecoder) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            
            let JSONObject = processResponse(request: request, response: response, data: data, error: error, keyPath: keyPath)
            
            if let error = JSONObject as? ApiError {
                return .failure(error)
            } else {
                do {
                    if let _ = keyPath {
                        if let object = JSONObject {
                            let data = try JSONSerialization.data(withJSONObject: object)
                            let parsedObject = try decoder.decode(T.self, from: data)
                            return .success(parsedObject)
                        }
                    } else if let data = data {
                        let parsedObject = try decoder.decode(T.self, from: data)
                        return .success(parsedObject)
                    }
                } catch let error {
                    return .failure(newError(.dataSerializationFailed, failureReason: error.message))
                }
            }
            
            return .failure(serializationError())
        }
    }
    
    @discardableResult
    func responseObject<T: Codable>(queue: DispatchQueue? = nil, keyPath: String? = nil, decoder: JSONDecoder = Services.decoder) -> CancellablePromise<T> {
        return CancellablePromise<T>.init(resolver:  { seal in
            let responseSerializer : DataResponseSerializer<T> = DataRequest.DecodableSerializer(keyPath, decoder: decoder)
            response(queue: queue, responseSerializer: responseSerializer)
            { (response: DataResponse<T>) in
                switch response.result {
                case .success(let value):
                    seal.fulfill(value)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        })
    }
    
    func responseArray<T: Codable>(queue: DispatchQueue? = nil, keyPath: String? = nil, decoder: JSONDecoder = Services.decoder) -> CancellablePromise<[T]> {
        return responseObject(queue: queue, keyPath: keyPath, decoder: decoder)
    }
    
}
