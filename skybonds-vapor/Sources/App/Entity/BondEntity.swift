//
//  BondEntity.swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation
import Vapor
import FluentSQLite


struct PriceEntity: Codable, SQLiteStringModel
{
    var id: String?
    
    let date: Date
    let value: Double
}

extension PriceEntity: Migration { }
extension PriceEntity: Content { }
extension PriceEntity: Parameter { }

struct BondEntity: Codable, Content
{
    let startPrice: Double
    /// in procent from startPrice
    let yield : Double
    let prices : [PriceEntity]
}
