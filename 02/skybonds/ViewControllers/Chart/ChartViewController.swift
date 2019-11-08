//
//  ChartViewController.swift
//  skybonds
//
//  Created by Sergey Balalaev on 07.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import UIKit
import Charts
import PromiseKit

final class ChartViewController: UIViewController, ChartViewDelegate {

    /// входной идентификатор ISIN
    @IBInspectable var identifierISIN: String?
    {
        didSet {
            if isViewLoaded {
                updateContentData()
            }
        }
    }
    /// режим отображения
    var currentMode: ChartMode = .price {
        didSet{
            if isViewLoaded {
                modeSegmentControl.setTitle(currentMode.label, forSegmentAt: 0)
                updateChart()
            }
        }
    }
    /// можно управлять отображением
    @IBInspectable var textFont : UIFont = .systemFont(ofSize: 16)
    @IBInspectable var textColor : UIColor = .standartTextColor
    @IBInspectable var actionColor : UIColor = .red
    
    // для отмены загрузки данных
    private var currentPromise: CancellablePromise<BondEntity>? = nil
    // для работы в офлайн с загруженными данными
    private var currentBond: BondEntity? = nil
    
    // график
    private let chartView = CombinedChartView()
    
    // все что касается периода
    private let periods: [BondPeriod] = BondPeriod.allCases
    private var currentPeriodIndex: Int {
        get{ periodSegmentControl.selectedSegmentIndex }
        set{ periodSegmentControl.selectedSegmentIndex = newValue }
    }
    private var currentPeriod: BondPeriod? {
        guard currentPeriodIndex > -1 && currentPeriodIndex < periods.count else {
            return nil
        }
        return periods[currentPeriodIndex]
    }
    private let periodSegmentControl = UISegmentedControl()
    
    // меняет режим
    private let modeSegmentControl = UISegmentedControl()
    
    // прогресс
    private let indicator = UIActivityIndicatorView()
    
    
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
        for (index, period) in periods.enumerated(){
            periodSegmentControl.insertSegment(withTitle: period.label, at: index, animated: false)
        }
        if periods.count > 0 {
            currentPeriodIndex = 0
        }
        periodSegmentControl.setTitleTextAttributes([ NSAttributedString.Key.font : textFont ], for: .normal)
        periodSegmentControl.addTarget(self, action: #selector(changePeriod), for: .valueChanged)
        
        if #available(iOS 13, *){
            indicator.style = .large
        } else {
            indicator.style = .whiteLarge
        }
        indicator.color = actionColor
        view.addSubview(indicator)
        
        view.addSubview(modeSegmentControl)
        modeSegmentControl.insertSegment(withTitle: currentMode.label, at: 0, animated: false)
        modeSegmentControl.isMomentary = true
        modeSegmentControl.setTitleTextAttributes([ NSAttributedString.Key.font : textFont ], for: .normal)
        modeSegmentControl.addTarget(self, action: #selector(changeMode), for: .valueChanged)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        periodSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        modeSegmentControl.translatesAutoresizingMaskIntoConstraints = false

        chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: chartView.trailingAnchor, constant: 0).isActive = true
        chartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        
        periodSegmentControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        chartView.bottomAnchor.constraint(equalTo: periodSegmentControl.topAnchor, constant: 0).isActive = true
        periodSegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: periodSegmentControl.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: periodSegmentControl.bottomAnchor, constant: 0).isActive = true
        
        modeSegmentControl.addConstaints(height: 44, width: 120)
        modeSegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60).isActive = true
        modeSegmentControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
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
        showProgress()
        updateChart(from: [])
        currentPromise?.cancel()
        let promise = ApiService.getBond(with: identifierISIN, from: currentPeriod)
        promise
            .done{[weak self] bondEntity in
                guard let this = self else {return}
                this.updateChart(from: bondEntity)
                this.stopUpdateContentData()
            }.catch{[weak self] error in
                if error.isCancelled == false {
                    self?.stopUpdateContentData()
                }
                print("error: \(error)")
            }
        currentPromise = promise
    }
    
    private func showProgress() {
        indicator.startAnimating()
        chartView.isHidden = true
        modeSegmentControl.isHidden = true
    }
    
    private func hideProgress() {
        indicator.stopAnimating()
        chartView.isHidden = false
        modeSegmentControl.isHidden = false
    }
    
    private func stopUpdateContentData() {
        self.hideProgress()
        self.currentPromise = nil
    }
    
    private func updateChart(){
        guard let bond = self.currentBond else {
            updateChart(from: [])
            return
        }
        var valueEntries: [ChartDataEntry] = []
        if currentMode == .price {
            valueEntries = bond.prices.map{ price in
                let x = price.date.timeIntervalSinceReferenceDate
                let y = price.value
                return ChartDataEntry(x: x, y: y)
            }
        } else if currentMode == .yield {
            let yieldPrice = bond.yield * bond.startPrice
            valueEntries = bond.prices.compactMap{ price in
                if price.value > 0 {
                    let x = price.date.timeIntervalSinceReferenceDate
                    let y = yieldPrice / price.value
                    return ChartDataEntry(x: x, y: y)
                }
                return nil
            }
        }
        updateChart(from: valueEntries)
    }
    
    private func updateChart(from bond: BondEntity){
        print("update Bond")
        currentBond = bond
        updateChart()
    }
    
    private func updateChart(from valueEntries: [ChartDataEntry]){
        // Формируем график
        let valueSet = LineChartDataSet(entries: valueEntries, label: "")
        valueSet.valueFont = textFont
        valueSet.axisDependency = .left
        
        valueSet.setColor(.red)
        valueSet.lineWidth = 2
        
        valueSet.setCircleColor(textColor)
        valueSet.circleRadius = 3
        
        valueSet.fillAlpha = 65/255
        valueSet.fillColor = actionColor
        
        valueSet.highlightColor = actionColor
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
    
    @objc func changeMode(){
        if currentMode == .price {
            currentMode = .yield
        } else {
            currentMode = .price
        }
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
