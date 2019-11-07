//
//  ApiService.swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation

struct ApiService {
    
    static func getValues(from period: ChartPeriod) -> [ChartValue]
    {
        let currentDate = Date()
        var nextDate = period.startDate
        let calendar = Calendar.current
        var dayForwardComponent = DateComponents()
        
        dayForwardComponent.day = period.daysForTest

        var result : [ChartValue] = []
        var currentValue = Double.random(in: 0..<100)
        
        while currentDate.timeIntervalSince(nextDate) > 0 {
            currentValue += Double.random(in: -3..<5)
            result.append(ChartValue(date: nextDate, value: currentValue))
            nextDate = calendar.date(byAdding: dayForwardComponent, to: nextDate)!
        }
        
        return result
    }
    
}
