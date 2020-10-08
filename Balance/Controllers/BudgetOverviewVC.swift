//
//  BudgetOverviewVC.swift
//  Balance
//
//  Created by Bo on 8/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class BudgetOverviewVC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var prevMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    
    
    //MARK: - Properties
    
    let realm = try! Realm()
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureLineChart()
        configureLandscapeView()
        
        monthYearLabel.text = formatter.string(from: SelectedMonth.shared.date)
        lineChartView?.animate(yAxisDuration: 1)


                
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParent) {
          UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }

    }
    
    @objc func isLandscape() -> Void {}

    
    //MARK: - Methods
    
    private func configureLandscapeView() {
        
        self.tabBarController?.tabBar.isHidden = true
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

        
    }
    
    private func configureLineChart() {
        
        
        let objects = transactions.filter(SelectedMonth.shared.selectedMonthPredicate()).sorted(byKeyPath: "transactionDate", ascending: true)
        
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelCount = 11
        xAxis.drawLabelsEnabled = true
        
        var referenceTimeInterval: TimeInterval = 0
        if let minTimeInterval = (objects.map { $0.transactionDate.timeIntervalSince1970 }).min() {
            referenceTimeInterval = minTimeInterval
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)
        
        var entries = [ChartDataEntry]()
        for object in objects {
            let timeInterval = object.transactionDate.timeIntervalSince1970
            let xValue = (timeInterval - referenceTimeInterval) / (3600 * 24)
            
            let balanceAtDate: Double = transactions.filter("transactionDate <= %@", object.transactionDate).sum(ofProperty: "transactionAmount")
            let yValue = balanceAtDate
            let entry = ChartDataEntry(x: xValue, y: yValue)
        
            entries.append(entry)
        }
        
        lineChartView.xAxis.valueFormatter = xValuesNumberFormatter
        lineChartView.xAxis.labelRotationAngle = -45
        lineChartView.extraRightOffset = 20
        
        let dataSet = LineChartDataSet(entries: entries, label: "")
        let data = LineChartData(dataSet: dataSet)
        
        let format = NumberFormatter()
        format.numberStyle = .currency

        let currency = DefaultValueFormatter(formatter: format)
        data.setValueFormatter(currency)
                
        dataSet.circleHoleRadius = 0
        dataSet.circleRadius = 3
        dataSet.mode = .horizontalBezier
        
        let valFormatter = NumberFormatter()
        valFormatter.numberStyle = .currency
        valFormatter.maximumFractionDigits = 0
        valFormatter.currencySymbol = "$"

        lineChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: valFormatter)
        lineChartView.rightAxis.enabled = false
        
        lineChartView.data = data
        
        
    }
    
//    func updatePlannedBudget() {
//
//        let incomePlannedTotal = categories[0].categoryAmountBudgeted
//
//
//        let expensesPlannedTotal: Double = abs(categories.filter(NSPredicate(format: "categoryName != %@", "Income")).sum(ofProperty: "categoryAmountBudgeted"))
//
//        expenseAmountLabel.text = expensesPlannedTotal.toCurrency()
//
//        let incomeMinusExpenseAmount = incomePlannedTotal - expensesPlannedTotal
//
//        let incomeToExpenseRatio =  expensesPlannedTotal / incomePlannedTotal
//
//        if incomePlannedTotal == 0.0 {
//            percentLabel.text = "0%"
//        } else {
//            percentLabel.text = String(format: "%.0f%%", incomeToExpenseRatio * 100)
//        }
//
//        if incomePlannedTotal == 0.0 {
//            netAmountLabel.text = "No income planned for \(monthYearLabel.text!).\nTap Edit Budget to get started."
//        } else if incomeMinusExpenseAmount > 0 {
//            netAmountLabel.text = "\(incomeMinusExpenseAmount.toCurrency())\nleft to budget"
//        } else if incomeMinusExpenseAmount < 0 {
//            netAmountLabel.text = "\(incomeMinusExpenseAmount.toCurrency()) over budget"
//        } else {
////            progressView.progressLayerStrokeColor = UIColor(rgb: Constants.blue)
////            progressView.trackLayerStrokeColor = .clear
//            netAmountLabel.text = "Budget balanced!"
//        }
//
//        progressView.animateProgress(duration: 0.75, value: incomeToExpenseRatio)
//
//
//    }
    
//    func updateSpentBudget() {
//
//        progressView.trackLayerStrokeColor = UIColor(rgb: Constants.green)
//        progressView.progressLayerStrokeColor = UIColor(rgb: Constants.red)
//
//        let incomePlannedTotal = categories[0].categoryAmountBudgeted
//        incomeAmountLabel.text = incomePlannedTotal.toCurrency()
//
//        let expensesSpentTotal: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory != %@", categories[0])).filter(predicateForMonthFromDate(date: Date())).sum(ofProperty: "transactionAmount"))
//
//        expenseAmountLabel.text = expensesSpentTotal.toCurrency()
//
//        let incomeMinusExpenseAmount = incomePlannedTotal - expensesSpentTotal
//
//        let incomeToExpenseRatio =  expensesSpentTotal / incomePlannedTotal
//
//        if incomePlannedTotal == 0.0 {
//            percentLabel.text = "0%"
//        } else {
//            percentLabel.text = String(format: "%.0f%%", incomeToExpenseRatio * 100)
//        }
//
//        if incomePlannedTotal == 0.0 {
//                    netAmountLabel.text = "No income planned for \(monthYearLabel.text!).\nTap Edit Budget to get started."
//                } else if incomeMinusExpenseAmount > 0 {
//                    netAmountLabel.text = "\(incomeMinusExpenseAmount.toCurrency())\nleft to spend."
//                } else if incomeMinusExpenseAmount < 0 {
//                    netAmountLabel.text = "\(incomeMinusExpenseAmount.toCurrency()) over spent."
//                } else {
//        //            progressView.progressLayerStrokeColor = UIColor(rgb: Constants.blue)
//        //            progressView.trackLayerStrokeColor = .clear
//                    netAmountLabel.text = "Spent all of budget."
//                }
//
//                progressView.animateProgress(duration: 0.75, value: incomeToExpenseRatio)
//
//
//    }
    
    
    
    //MARK: - IBActions

//    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
//
//        switch plannedActualSegmentedControl.selectedSegmentIndex {
//        case 0:
//            updatePlannedBudget()
//        case 1:
//            updateSpentBudget()
//        default:
//            return
//        }
//
//    }
    @IBAction func prevMonthPressed(_ sender: UIButton) {
        
        SelectedMonth.shared.decreaseDateByAMonth()
        configureLineChart()
        monthYearLabel.text = formatter.string(from: SelectedMonth.shared.date)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
    }
    
    @IBAction func nextMonthPressed(_ sender: UIButton) {
        
        SelectedMonth.shared.increaseDateByAMonth()
        configureLineChart()
        monthYearLabel.text = formatter.string(from: SelectedMonth.shared.date)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
    }
    
    
}

//MARK: - Extensions
