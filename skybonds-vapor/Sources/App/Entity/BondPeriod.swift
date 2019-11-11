//
//  BondPeriod.swift
//  App
//
//  Created by Sergey Balalaev on 11.11.2019.
//

import Foundation

enum BondPeriod : String, CaseIterable, Codable {
    case week
    case month
    case threeMonth
    case sixMonth
    case year
    case twoYear
    
    static let max: Self = {
        return allCases.last!
    }()
}

extension BondPeriod {
    
    var label: String {
        switch self {
        case .week:
            return "1W"
        case .month:
            return "1M"
        case .threeMonth:
            return "3M"
        case .sixMonth:
            return "6M"
        case .year:
            return "1Y"
        case .twoYear:
            return "2Y"
        }
    }
    
    static let sixMonthInterval : TimeInterval = 180 * 24 * 3600
    
    // используется исключительно для тестов
    var daysForTest: Int {
        let interval = Date().timeIntervalSince(startDate)
            
        if interval > Self.sixMonthInterval {
            return 20
        } else if interval > 32 * 24 * 3600 {
            return 5
        }
        return 1
    }
    
    var startDate: Date {
        
        let calendar = Calendar.current
        var dayForwardComponent = DateComponents()

        switch self {
        case .week:
            dayForwardComponent.day = -7
        case .month:
            dayForwardComponent.month = -1
        case .threeMonth:
            dayForwardComponent.month = -3
        case .sixMonth:
            dayForwardComponent.month = -6
        case .year:
            dayForwardComponent.year = -1
        case .twoYear:
            dayForwardComponent.year = -2
        }
        
        return calendar.date(byAdding: dayForwardComponent, to: Date())!
    }
    
}
