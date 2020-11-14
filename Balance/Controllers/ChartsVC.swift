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

enum ChartView {
    case lineChart
    case pieChart
}

class ChartsVC: UIViewController, ChartViewDelegate {

    //MARK: - IBOutlets
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var prevMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var lineChartButton: UIButton!
    @IBOutlet weak var pieChartButton: UIButton!
    
    
    //MARK: - Properties
    
    let realm = try! Realm()
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var chartView: ChartView = .lineChart
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureLineChart()
//        configurePieChart()
        configureLandscapeView()
        
        pieChartView.isHidden = true
        nextMonthButton.tintColor = .label
        prevMonthButton.tintColor = .label
        
        monthYearLabel.text = "\(formatter.string(from: SelectedMonth.shared.date)) Balances"

        lineChartView?.animate(yAxisDuration: 1)
        
                
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")

    }
    
    //MARK: - Methods
    
    @objc private func isLandscape() -> Void {}
    
    private func configureLandscapeView() {
        
        self.tabBarController?.tabBar.isHidden = true
        
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        
    }
    
    private func configureCharts() {
        
        switch chartView {
        
        case ChartView.lineChart:
            configureLineChart()
            
        case ChartView.pieChart:
            configurePieChart()
            
        }
    }
    
    private func configurePieChart() {
        
        monthYearLabel.text = "\(formatter.string(from: SelectedMonth.shared.date)) Expenses"
        
//        let totalIncome: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@", categories[0])).filter(SelectedMonth.shared.selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
//        let totalExpenses: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory != %@", categories[0])).filter(SelectedMonth.shared.selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))

//        let incomeToExpenseRatio = totalExpenses / totalIncome



//        incomeLabel.text = "Income:\n\(totalIncome.toCurrency())"
//        expensesLabel.text = "Expenses:\n\(totalExpenses.toCurrency())"

//        pieChartView.delegate = self
        pieChartView.legend.enabled = true
//        pieChartView.centerText = graphCenterText
        pieChartView.holeRadiusPercent = 0.5

        let expenseCategories = categories.dropFirst()

        var entries = [PieChartDataEntry]()

        for category in expenseCategories {
            let totalCategoryValue = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@", category)).filter(SelectedMonth.shared.selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
            if totalCategoryValue > 0 {
                entries.append(PieChartDataEntry(value: Double(totalCategoryValue), label: category.categoryName))
            }
        }

        let expenseDataSet = PieChartDataSet(entries: entries)

        expenseDataSet.colors.removeAll()
        expenseDataSet.sliceSpace = 2
        expenseDataSet.yValuePosition = .outsideSlice
        expenseDataSet.xValuePosition = .outsideSlice
        expenseDataSet.valueLinePart1Length = 0.5
        expenseDataSet.valueLineVariableLength = true
        expenseDataSet.valueColors = [.label]
        expenseDataSet.valueLineColor = .label
        expenseDataSet.entryLabelColor = .label
        expenseDataSet.label = .none

        for category in expenseCategories {
            let totalCategoryValue = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@", category)).filter(SelectedMonth.shared.selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))

            if totalCategoryValue > 0 {
                expenseDataSet.colors.append(NSUIColor(rgb: category.categoryColor))

            }

        }

        let data = PieChartData(dataSet: expenseDataSet)

        let format = NumberFormatter()
        format.numberStyle = .currency
        format.multiplier = 1

        let formatter = DefaultValueFormatter(formatter: format)
        data.setValueFormatter(formatter)

        pieChartView.data = data
        
    }
    
    private func configureLineChart() {
        
        monthYearLabel.text = "\(formatter.string(from: SelectedMonth.shared.date)) Balances"
        
//        lineChartView.delegate = self
        
        let objects = transactions.filter(SelectedMonth.shared.selectedMonthPredicate()).sorted(byKeyPath: "transactionDate", ascending: true)
        
        
        
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelCount = 30
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
        
        let lineChartDataSet = LineChartDataSet(entries: entries)
        
        let data = LineChartData(dataSet: lineChartDataSet)
        
        let format = NumberFormatter()
        format.numberStyle = .currency

        let currency = DefaultValueFormatter(formatter: format)
        data.setValueFormatter(currency)
                
        lineChartDataSet.circleHoleRadius = 0
        lineChartDataSet.circleRadius = 3
        lineChartDataSet.mode = .horizontalBezier
        lineChartDataSet.label = .none
        
        let valFormatter = NumberFormatter()
        valFormatter.numberStyle = .currency
        valFormatter.maximumFractionDigits = 0
        valFormatter.currencySymbol = "$"

        lineChartView.xAxis.valueFormatter = xValuesNumberFormatter
        lineChartView.xAxis.labelRotationAngle = -45
        lineChartView.extraRightOffset = 20
        lineChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: valFormatter)
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        
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
        configureCharts()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
    }
    
    @IBAction func nextMonthPressed(_ sender: UIButton) {
        
        SelectedMonth.shared.increaseDateByAMonth()
        configureCharts()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
    }
    
    @IBAction func pieChartButtonPressed(_ sender: UIButton) {
        
        pieChartView.isHidden = false
        lineChartView.isHidden = true
        
        chartView = ChartView.pieChart
        
        configureCharts()
                
    }
    
    
    @IBAction func lineChartButtonPressed(_ sender: UIButton) {
        
        lineChartView.isHidden = false
        pieChartView.isHidden = true
        
        chartView = ChartView.lineChart
        
        configureCharts()
    }
    
    
    
}

//MARK: - Extensions
