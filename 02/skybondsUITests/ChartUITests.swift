//
//  ChartUITests.swift
//  skybondsUITests
//
//  Created by Sergey Balalaev on 07.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import XCTest

class ChartUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// смотрим чтобы не было лишних обновлений графика, проверка отмены загрузки
    func testPeriod() {
        let app = XCUIApplication()
        app.buttons["1Y"].tap()
        app.buttons["1M"].tap()
        app.buttons["3M"].tap()
        app.buttons["2Y"].tap()
        app.buttons["1W"].tap()
        app.buttons["6M"].tap()
        sleep(2)
    }
    
    /// смотрим что лишний раз не грузятся данные
    func testMode() {
        let app = XCUIApplication()
        app.buttons["Цена"].tap()
        sleep(1)
        app.buttons["Доходность %"].tap()
        app.buttons["Цена"].tap()
        app.buttons["Доходность %"].tap()
        sleep(1)
        app.buttons["Цена"].tap()
        app.buttons["Доходность %"].tap()
        app.buttons["Цена"].tap()
    }
    
    /// проверка совместной работы переключателей в асинхронном режиме
    func testAll() {
        let app = XCUIApplication()
        app.buttons["1M"].tap()
        app.buttons["3M"].tap()
        app.buttons["2Y"].tap()
        app.buttons["Цена"].tap()
        app.buttons["Доходность %"].tap()
        sleep(2)
        app.buttons["1W"].tap()
        app.buttons["Цена"].tap()
        app.buttons["Доходность %"].tap()
        app.buttons["Цена"].tap()
        app.buttons["6M"].tap()
        sleep(2)
        app.buttons["Доходность %"].tap()
        app.buttons["Цена"].tap()
        app.buttons["2Y"].tap()
        app.buttons["1W"].tap()
        sleep(2)
    }
}
