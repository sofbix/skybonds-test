//
//  ChartMode.swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation

enum ChartMode : String, CaseIterable {
    case yield
    case price
}

extension ChartMode {
    
    var label: String {
        switch self {
        case .yield:
            return "Доходность %"
        case .price:
            return "Цена"
        }
    }

}
