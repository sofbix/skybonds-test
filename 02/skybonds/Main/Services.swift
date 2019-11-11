//
//  Services.swift
//  skybonds
//
//  Created by Sergey Balalaev on 11.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation

public struct Services {
    
    //static var domain = "http://192.168.1.8:8080"
    static var domain = "http://localhost:8080"
    
    static var authErrorCode = 401
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    enum Methods: String {
        case bonds = "/api/bonds"

    }
    
    public static var decoder: JSONDecoder
    {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(iso8601)
        return decoder
    }
    
    public static var encoder: JSONEncoder
    {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(iso8601)
        return encoder
    }
    
    
}
