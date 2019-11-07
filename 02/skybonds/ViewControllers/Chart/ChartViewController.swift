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
    
    var identifierISIN: String?
    {
        didSet {
            if isViewLoaded {
                updateContentData()
            }
        }
    }
    
    private let chartView = CombinedChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(chartView)
        chartView.addConstaintsToSuperview()
        
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        
        let legend = chartView.legend
        legend.form = .line
        legend.font = UIFont(name: "HelveticaNeue-Light", size: 12)!
        legend.textColor = .darkGray
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 12)
        xAxis.labelTextColor = .darkGray
        xAxis.drawAxisLineEnabled = false
        xAxis.valueFormatter = self
        
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        leftAxis.axisMaximum = 300
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateContentData()
    }
    
    func updateContentData(){
        //
        chartView.animate(xAxisDuration: 1.5)
    }
    
}

extension ChartViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return ""
    }
}
