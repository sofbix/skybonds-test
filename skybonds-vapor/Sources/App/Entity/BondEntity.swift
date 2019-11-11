//
//  BondEntity.swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation
import Vapor


struct PriceEntity: Codable, Content
{
    let date: Date
    let value: Double
}

struct BondEntity: Codable, Content
{
    let startPrice: Double
    /// in procent from startPrice
    let yield : Double
    let prices : [PriceEntity]
}
