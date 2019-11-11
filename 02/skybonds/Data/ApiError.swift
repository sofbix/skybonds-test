//
//  ApiError.swift
//  skybonds
//
//  Created by Sergey Balalaev on 11.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation

struct ApiError : LocalizedError {
    fileprivate(set) var status : Int
    fileprivate(set) var code: Int
    fileprivate(set) var message: String
    
    init(status : Int = 0, code: Int = 0, message: String = "Internal service error") {
        self.status = status
        self.code = code
        self.message = message
    }
    
    init(response: HTTPURLResponse?, error: Error?) {
        self.init()
        if let response = response {
            status = response.statusCode
            message = HTTPURLResponse.localizedString(forStatusCode: status) + " (\(status))"
        }
        if let error = error {
            let currentError = error as NSError
            message = currentError.localizedDescription
            code = currentError.code
        }
    }
    
    init(_ error: Error) {
        if let error = error as? ApiError{
            self.init(status : error.status, code: error.code, message: error.message)
        } else {
            self.init(response: nil, error: error)
        }
    }
    
    init(status: Int = 0, error: NSError) {
        self.status = status
        self.code = error.code
        self.message = error.localizedDescription
    }
    
    var localizedDescription: String {
        return message
    }
    
    var errorDescription: String? {
        return message
    }

}

extension Error {
    var message: String {
        if let this = self as? ApiError {
            return this.message
        }
        return localizedDescription
    }
    
    var status : Int {
        if let this = self as? ApiError {
            return this.status
        }
        return 0
    }
    
    var code : Int {
        if let this = self as? ApiError {
            return this.code
        }
        return 0
    }
}
