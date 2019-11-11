//
//  Codable.swift
//  skybonds
//
//  Created by Sergey Balalaev on 11.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation

extension Encodable
{
    
    func toJSONString() -> String? {
        let dataParameters = try! Services.encoder.encode(self)
        return String(data: dataParameters, encoding: .utf8)
    }
    
    func asDictionary() -> [String: Any] {
        let data = try! Services.encoder.encode(self)
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        return dictionary
    }
    
    var dictionary: [String: Any]? {
        guard let data = try? Services.encoder.encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

