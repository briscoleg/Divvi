//
//  HeaderView.swift
//  Balance
//
//  Created by Bo on 8/20/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

protocol DateSwitcherDelegate {
    func getDate(with date: Date)
}

class BudgetHeader: UICollectionReusableView {
    
//    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var lineChartButton: UIButton!

    static let identifier = "HeaderView"
    
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self)}()
    lazy var plannedTransactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    
    var dateSwitcherDelegate: DateSwitcherDelegate!
    
    var category: Category?
    
//    var selectedDate = Date()
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    var graphCenterText = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLayout()
        
        updateMonthYearLabel()


    }
    
    private func configureLayout() {
        
        leftButton.layer.cornerRadius = 10
        rightButton.layer.cornerRadius = 10

        leftButton.tintColor = .white
        leftButton.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
        rightButton.tintColor = .white
        rightButton.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
        lineChartButton.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
        
        lineChartButton.makeCircular()


    }
    
    
    
    private func configureProgressBar() {
        
        //        let totalIncome = transactions.filter(NSPredicate(format: "transactionCategory == %@", "Income")).filter(selectedMonthPredicate()).sum(ofProperty: "transactionAmount")
        
    }
    
//    func configureHeader() {
//
//    }
    
//    private func configureLineChart() {
//
//        let objects = transactions.filter(SelectedMonth.shared.selectedMonthPredicate()).sorted(byKeyPath: "transactionDate", ascending: true)
//
//        let xAxis = lineChart.xAxis
//        xAxis.labelPosition = .bottom
//        xAxis.labelCount = 6
//                xAxis.drawLabelsEnabled = true
//
//        var referenceTimeInterval: TimeInterval = 0
//        if let minTimeInterval = (objects.map { $0.transactionDate.timeIntervalSince1970 }).min() {
//            referenceTimeInterval = minTimeInterval
//        }
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM d"
//
//        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)
//
//        var entries = [ChartDataEntry]()
//        for object in objects {
//            let timeInterval = object.transactionDate.timeIntervalSince1970
//            let xValue = (timeInterval - referenceTimeInterval) / (3600 * 24)
//
//            let balanceAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", object.transactionDate).sum(ofProperty: "transactionAmount")
//            let yValue = balanceAtDate
//            let entry = ChartDataEntry(x: xValue, y: yValue)
//
//            entries.append(entry)
//        }
//
//        lineChart.xAxis.valueFormatter = xValuesNumberFormatter
//
//        let dataSet = LineChartDataSet(entries: entries, label: "")
//        let data = LineChartData(dataSet: dataSet)
//
//        let format = NumberFormatter()
//        format.numberStyle = .currency
//
//        let currency = DefaultValueFormatter(formatter: format)
//        data.setValueFormatter(currency)
//
//        dataSet.circleHoleRadius = 0
//        dataSet.circleRadius = 3
//        dataSet.mode = .cubicBezier
//
//        lineChart.data = data
//
//    }
    
    private func setGraphCenterText(index: Int, amount: Double) {
        
        let expenseCategoryName = categories[index + 1].categoryName
        
        print(index)
        
        graphCenterText = amount.toCurrency()
        
        print(graphCenterText)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chartSliceSelected"), object: nil)
        
        
        
    }
    
    //    private func beginningOfMonthToTodayPredicate(date: Date) -> NSPredicate {
    //
    //        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    //
    //        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    //
    //        components.day = 01
    //        components.hour = 00
    //        components.minute = 00
    //        components.second = 00
    //
    //        let startDate = calendar.date(from: components)
    //
    //        components.day = Date().day
    //        components.hour = 23
    //        components.minute = 59
    //        components.second = 59
    //
    //        let endDate = calendar.date(from: components)
    //
    //        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    //    }
    
//    func currentMonthPredicate(date: Date) -> NSPredicate {
//
//        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//
//        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: selectedDate)
//
//        components.day = 01
//        components.hour = 00
//        components.minute = 00
//        components.second = 00
//
//        let startDate = calendar.date(from: components)
//
//        components.day = 31
//        components.hour = 23
//        components.minute = 59
//        components.second = 59
//
//        let endDate = calendar.date(from: components)
//
//        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
//    }
    
//    func selectedMonthPredicate() -> NSPredicate {
//
//        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//
//        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: SelectedMonth.shared.date)
//
//        components.day = 01
//        components.hour = 00
//        components.minute = 00
//        components.second = 00
//
//        let startDate = calendar.date(from: components)
//
//        components.day = 31
//        components.hour = 23
//        components.minute = 59
//        components.second = 59
//
//        let endDate = calendar.date(from: components)
//
//        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
//    }
    
    //    func getPredicateForSelectedMonth(date: Date) -> NSPredicate {
    //
    //        let selectedYear = selectedDate.year
    //        let selectedMonth = selectedDate.month
    //
    //        var components = DateComponents()
    //        components.month = selectedMonth
    //        components.year = selectedYear
    //        let startDateOfMonth = Calendar.current.date(from: components)
    //
    //        //Now create endDateOfMonth using startDateOfMonth
    //        components.year = 0
    //        components.month = 1
    //        components.day = -1
    //
    //        let endDateOfMonth = Calendar.current.date(byAdding: components, to: startDate)
    //
    //        let predicate = NSPredicate(format: "%K >= %@ && %K <= %@", "DateAttribute", startDateOfMonth! as NSDate, "DateAttribute", endDateOfMonth! as NSDate)
    //
    //        return predicate
    //    }
    
    private func updateMonthYearLabel() {
        
        monthYearLabel.text = formatter.string(from: SelectedMonth.shared.date)
        
    }
    
    //        private func setGraphCenterText(index: Int, amount: Double) {
    //
    //            graphCenterText = "\(index)\n\(amount)"
    //            print(graphCenterText)
    //
    //        }
    
    //MARK: - IBActions
    @IBAction func leftButtonPressed(_ sender: UIButton) {
//        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
        SelectedMonth.shared.decreaseDateByAMonth()
        monthYearLabel.text = formatter.string(from: SelectedMonth.shared.date)
        configureProgressBar()
//        configureLineChart()
        //        dateSwitcherDelegate.getDate(with: selectedDate)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
//        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
        
        SelectedMonth.shared.increaseDateByAMonth()
//        configureLineChart()
        monthYearLabel.text = formatter.string(from: SelectedMonth.shared.date)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
        
        configureProgressBar()

        
    }
    
    @IBAction func chartSwitcherPressed(_ sender: UIButton) {
        
        
    }
    
    
}

//MARK: - ChartView Delegate
extension BudgetHeader: ChartViewDelegate {
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let selectedCategoryAmount = highlight.y
        
        let selectedCategoryIndex = highlight.dataSetIndex
        
        if let dataSet = chartView.data?.dataSets[ highlight.dataSetIndex] {
            
            let sliceIndex: Int = dataSet.entryIndex( entry: entry)
            let sliceAmount: Double = highlight.y
            
            setGraphCenterText(index: sliceIndex, amount: sliceAmount)
            
        }
        
        let animator = Animator()
        
        animator.updateBlock = {
            // Usually the phase is a value between 0.0 and 1.0
            // Multiply it so you get the final phaseShift you want
            let phaseShift = 10 * animator.phaseX
            
            let dataSet = chartView.data?.dataSets.first as? PieChartDataSet
            // Set the selectionShift property to actually change the selection over time
            dataSet?.selectionShift = CGFloat(phaseShift)
            
            // In order to see the animation, trigger a redraw every time the selectionShift property was changed
            chartView.setNeedsDisplay()
        }
        
        // Start the animation by triggering the animate function with any timing function you like
        animator.animate(xAxisDuration: 0.2, easingOption: ChartEasingOption.easeInCubic)
        
    }
    
}


