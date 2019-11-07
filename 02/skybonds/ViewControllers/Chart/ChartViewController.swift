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
    
    // входной идентификатор ISIN
    var identifierISIN: String?
    {
        didSet {
            if isViewLoaded {
                updateContentData()
            }
        }
    }
    
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
        
        let legend = chartView.legend
        legend.form = .none
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 12)
        xAxis.labelTextColor = .darkGray
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = false
        xAxis.valueFormatter = self
        
        
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        //leftAxis.axisMaximum = 300
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.valueFormatter = self
        
        view.addSubview(periodSegmentControl)
        //periodSegmentController.addConstaintsToSuperview(leadingOffset: 20, trailingOffset: -20, topOffset: 200, bottomOffset: -200)
        for (index, period) in periods.enumerated(){
            periodSegmentControl.insertSegment(withTitle: period.label, at: index, animated: false)
        }
        if periods.count > 0 {
            currentPeriodIndex = 0
        }
        periodSegmentControl.tintColor = .systemBlue
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
        guard let currentPeriod = currentPeriod else {
            return
        }
        let values = ApiService.getValues(from: currentPeriod)
        var valueEntries: [ChartDataEntry] = []
        for value in values {
            let x = value.date.timeIntervalSinceReferenceDate
            let y = value.value
            valueEntries.append(ChartDataEntry(x: x, y: y))
        }
        // Формируем график
        let valueSet = LineChartDataSet(entries: valueEntries, label: "")
        valueSet.axisDependency = .left
        valueSet.setColor(.red)
        valueSet.setCircleColor(.gray)
        valueSet.lineWidth = 2
        valueSet.circleRadius = 3
        valueSet.fillAlpha = 65/255
        valueSet.fillColor = .red
        valueSet.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        valueSet.drawCircleHoleEnabled = false
        valueSet.drawValuesEnabled = false
        valueSet.mode = .cubicBezier
        // Обновляем график
        let lineChart = LineChartData(dataSets: [valueSet])
        lineChart.setValueTextColor(.gray)
        lineChart.setValueFont(.systemFont(ofSize: 9))
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
