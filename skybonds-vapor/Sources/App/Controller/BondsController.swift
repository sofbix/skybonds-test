//
//  BondsController.swift
//  App
//
//  Created by Sergey Balalaev on 11.11.2019.
//

import Vapor

extension BondPeriod : Content, Parameter
{
    
}

final class BondsController {
    
    struct BondsInput : Codable, Content {
        var id: String
        var from: BondPeriod
    }
    
    func getBonds(_ request: Request) throws -> Future<BondEntity>
    {
        
        let params = try request.query.decode(BondsInput.self)
        return request.future().map{
            
            // искуственная задержка
            sleep(1)

            let startFromPeriodValue = Double.random(in: 30..<100)
            let startPrice = trunc(startFromPeriodValue - Double.random(in: 0..<20))
            let prices = Self.getRandomPrices(period: params.from, startValue: startFromPeriodValue)
            
            return BondEntity(startPrice: startPrice, yield: 8.7, prices: prices)
        }
    }
    
    /// Генерирует случайную цену, отталкиваясь от цены на начало указанного периода
    private static func getRandomPrices(period: BondPeriod, startValue: Double) -> [PriceEntity]
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
