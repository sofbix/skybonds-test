//
//  ApiService.swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation
import PromiseKit

struct ApiService {

    static func getBond(with id: String, from period: ChartPeriod) -> CancellablePromise<BondEntity>
    {
        return CancellablePromise<BondEntity>.init(resolver: { seal in
            DispatchQueue.global().async{
                sleep(1)

                let startFromPeriodValue = Double.random(in: 30..<100)
                let startPrice = trunc(startFromPeriodValue - Double.random(in: 0..<20))
                let prices = getRandomPrices(period: period, startValue: startFromPeriodValue)
                
                seal.fulfill(BondEntity(startPrice: startPrice, yield: 8.7, prices: prices))
            }
        })
    }
    
    /// Генерирует случайную цену, отталкиваясь от цены на начало указанного периода
    private static func getRandomPrices(period: ChartPeriod, startValue: Double) -> [PriceEntity]
    {
        var prices : [PriceEntity] = []
        
        let currentDate = Date()
        var nextDate = period.startDate
        let calendar = Calendar.current
        var dayForwardComponent = DateComponents()
        
        dayForwardComponent.day = period.daysForTest
        
        var currentValue = startValue
        
        while currentDate.timeIntervalSince(nextDate) > 0 {
            currentValue += Double.random(in: -3..<5)
            prices.append(PriceEntity(date: nextDate, value: currentValue))
            nextDate = calendar.date(byAdding: dayForwardComponent, to: nextDate)!
        }
        
        return prices
    }
    
}
