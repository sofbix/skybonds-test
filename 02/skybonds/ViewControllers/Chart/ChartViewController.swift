//
//  ChartViewController.swift
//  skybonds
//
//  Created by Sergey Balalaev on 07.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import UIKit
import Charts


final class ChartViewController: UIViewController, ChartViewDelegate {
    
    /// входной идентификатор ISIN
    var identifierISIN: String?
    {
        didSet {
            if isViewLoaded {
                updateContentData()
            }
        }
    }
    /// можно управлять отображением
    var textFont = UIFont.systemFont(ofSize: 16)
    var textColor = UIColor.standartTextColor
    
    
    // график
    private let chartView = CombinedChartView()
    
    // все что касается периода
    private let periods: [ChartPeriod] = ChartPeriod.allCases
    private var currentPeriodIndex: Int {
        get{ periodSegmentControl.selectedSegmentIndex }
        set{ periodSegmentControl.selectedSegmentIndex = newValue }
    }
    private var currentPeriod: ChartPeriod? {
        guard currentPeriodIndex > -1 && currentPeriodIndex < periods.count else {
            return nil
        }
        return periods[currentPeriodIndex]
    }
    private let periodSegmentControl = UISegmentedControl()
    
    //
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(chartView)
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.noDataFont = textFont
        
        let legend = chartView.legend
        legend.form = .none
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = textFont
        xAxis.labelTextColor = textColor
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = false
        xAxis.valueFormatter = self

        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = textFont
        leftAxis.labelTextColor = textColor
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.valueFormatter = self
        
        chartView.rightAxis.enabled = false
        
        view.addSubview(periodSegmentControl)
        //periodSegmentController.addConstaintsToSuperview(leadingOffset: 20, trailingOffset: -20, topOffset: 200, bottomOffset: -200)
        for (index, period) in periods.enumerated(){
            periodSegmentControl.insertSegment(withTitle: period.label, at: index, animated: false)
        }
        if periods.count > 0 {
            currentPeriodIndex = 0
        }
        periodSegmentControl.setTitleTextAttributes([ NSAttributedString.Key.font : textFont ], for: .normal)
        periodSegmentControl.addTarget(self, action: #selector(changePeriod), for: .valueChanged)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        periodSegmentControl.translatesAutoresizingMaskIntoConstraints = false

        chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: chartView.trailingAnchor, constant: 0).isActive = true
        chartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        
        periodSegmentControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        chartView.bottomAnchor.constraint(equalTo: periodSegmentControl.topAnchor, constant: 0).isActive = true
        periodSegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: periodSegmentControl.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: periodSegmentControl.bottomAnchor, constant: 0).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateContentData()
    }
    
    func updateContentData(){
        guard
            let currentPeriod = currentPeriod,
            let identifierISIN = identifierISIN
        else {
            return
        }
        ApiService.getBond(with: identifierISIN, from: currentPeriod)
            .done{[weak self] bondEntity in
                guard let this = self else {return}
                this.updateChart(from: bondEntity)
            }.catch{ error in
                print("error: \(error)")
            }
    }
    
    func updateChart(from entity: BondEntity){
        var valueEntries: [ChartDataEntry] = []
        for price in entity.prices {
            let x = price.date.timeIntervalSinceReferenceDate
            let y = price.value
            valueEntries.append(ChartDataEntry(x: x, y: y))
        }
        // Формируем график
        let valueSet = LineChartDataSet(entries: valueEntries, label: "")
        valueSet.valueFont = textFont
        valueSet.axisDependency = .left
        
        valueSet.setColor(.red)
        valueSet.lineWidth = 2
        
        valueSet.setCircleColor(textColor)
        valueSet.circleRadius = 3
        
        valueSet.fillAlpha = 65/255
        valueSet.fillColor = .red
        
        valueSet.highlightColor = .red
        valueSet.drawCircleHoleEnabled = false
        valueSet.drawValuesEnabled = true
        valueSet.mode = .cubicBezier
        
        // Обновляем график
        let lineChart = LineChartData(dataSets: [valueSet])
        lineChart.setValueTextColor(textColor)
        lineChart.setDrawValues(true)
        lineChart.setValueFont(textFont)
        let combineData = CombinedChartData()
        combineData.lineData = lineChart
        chartView.data = combineData
        //
        chartView.animate(xAxisDuration: 0.5)
    }
    
    @objc func changePeriod(){
        updateContentData()
    }
    
}

extension ChartViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if axis == chartView.xAxis {
            var dateFormatter = Settings.dayDateFormatter
            if let currentPeriod = self.currentPeriod {
                dateFormatter = currentPeriod.trueDataFormatter
            }
            return dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: value))
        } else {
            return String(value)
        }
    }
}
