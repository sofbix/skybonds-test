//
//  BondsController.swift
//  App
//
//  Created by Sergey Balalaev on 11.11.2019.
//

import Vapor
import FluentSQLite

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
        
        let maxCount = 10
        
        let params = try request.query.decode(BondsInput.self)
        let period = params.from
        
        let startFromPeriodValue = Double.random(in: 30..<100)
        let startPrice = trunc(startFromPeriodValue - Double.random(in: 0..<20))
        
        //let prices = Self.getRandomPrices(startValue: startFromPeriodValue, startDate: period.startDate, daysPeriod: period.daysForTest )

            return PriceEntity.query(on: request).count().flatMap{ count in
                
                var initFuture : Future<[PriceEntity]> = request.future([])
                
                if count == 0 {
                    initFuture = Self.saveRandomPrices(request, startValue: startFromPeriodValue)
                }
                
                return initFuture.flatMap {_ in
                    return PriceEntity.query(on: request).filter(\.date >= period.startDate).sort(\.date).all().map{ entities in
                        // искуственная задержка
                        sleep(1)
                        var result = entities
                        
                        // прореживаем в соответствии с периодом:
                        if result.count > maxCount {
                            let size = entities.count
                            let ratio: Double = Double(size) / Double(maxCount)
                            result = []
                            var index : Double = 0
                            while(Int(round(index)) < size)
                            {
                                result.append(entities[Int(round(index))])
                                index += ratio
                            }
                        }

                        return BondEntity(startPrice: startPrice, yield: 8.7, prices: result)
                    }
                }
            }
    }
    
    private static func saveRandomPrices(_ request: Request, startValue: Double) -> Future<[PriceEntity]>
    {
        let period = BondPeriod.max
        let prices = Self.getRandomPrices(startValue: startValue, startDate: period.startDate, daysPeriod: 1 )
        
        return prices.map{ price in
            return price.create(on: request)
        }.flatten(on: request)
    }
    
    /// Генерирует случайную цену, отталкиваясь от цены на начало указанного периода
    private static func getRandomPrices(startValue: Double, startDate: Date, daysPeriod: Int) -> [PriceEntity]
    {
        var prices : [PriceEntity] = []
        
        let currentDate = Date()
        var nextDate = startDate
        let calendar = Calendar.current
        var dayForwardComponent = DateComponents()
        
        dayForwardComponent.day = daysPeriod
        
        var currentValue = startValue
        
        while currentDate.timeIntervalSince(nextDate) > 0 {
            currentValue += Double.random(in: -3..<5)
            prices.append(PriceEntity(id: UUID().uuidString, date: nextDate, value: currentValue))
            nextDate = calendar.date(byAdding: dayForwardComponent, to: nextDate)!
        }
        
        return prices
    }
    
}
