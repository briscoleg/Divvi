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
import GTProgressBar

protocol DateSwitcherDelegate {
    func getDate(with date: Date)
}

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var cashFlowProgressBar: GTProgressBar!
    
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self)}()
    lazy var plannedTransactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    
    var dateSwitcherDelegate: DateSwitcherDelegate!
    
    var category: Category?
    
    var selectedDate = Date()
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    var graphCenterText = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pieChart.delegate = self
        updateMonthYearLabel()
        
//        configureProgressBar()
        
        
    }
    
 
        
    private func configureProgressBar() {
        
//        let totalIncome = transactions.filter(NSPredicate(format: "transactionCategory == %@", "Income")).filter(selectedMonthPredicate()).sum(ofProperty: "transactionAmount")
        

        

    }
    
    func configureHeader() {
        
        let totalIncome: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@", categories[0])).filter(selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
                let totalExpenses: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory != %@", categories[0])).filter(selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
                print(totalIncome)
                print(totalExpenses)
                let incomeToExpenseRatio = totalExpenses / totalIncome
                cashFlowProgressBar.progress = CGFloat(incomeToExpenseRatio)
                if incomeToExpenseRatio > 1 {
                    cashFlowProgressBar.barFillColor = UIColor(rgb: Constants.red)
                } else if incomeToExpenseRatio == 1 {
                    cashFlowProgressBar.barFillColor = UIColor(rgb: Constants.blue)
                } else {
                    cashFlowProgressBar.barFillColor = UIColor(rgb: Constants.green)
                }
        //        cashFlowProgressBar.barBackgroundColor = UIColor(rgb: Constants.blue)
                cashFlowProgressBar.barBorderColor = .clear
                
                incomeLabel.text = "Income:\n\(totalIncome.toCurrency())"
                expensesLabel.text = "Expenses:\n\(totalExpenses.toCurrency())"
        
        pieChart.delegate = self
        pieChart.legend.enabled = false
        pieChart.centerText = graphCenterText
        pieChart.holeRadiusPercent = 0.5
        
        let expenseCategories = categories.dropFirst()
        
        var entries = [PieChartDataEntry]()
        
        
        for category in expenseCategories {
            let totalCategoryValue = abs(plannedTransactions.filter(NSPredicate(format: "transactionCategory == %@", category)).filter(selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
            if totalCategoryValue > 0 {
                entries.append(PieChartDataEntry(value: Double(totalCategoryValue), label: nil))
            }
        }
        
        let expenseDataSet = PieChartDataSet(entries: entries, label: "Planned Expenses")
        
        expenseDataSet.colors.removeAll()
        expenseDataSet.sliceSpace = 2
        expenseDataSet.yValuePosition = .insideSlice
        expenseDataSet.valueColors = [.clear]
        expenseDataSet.valueLineColor = .clear
        expenseDataSet.entryLabelColor = UIColor.black
        
        for category in expenseCategories {
            let totalCategoryValue = abs(plannedTransactions.filter(NSPredicate(format: "transactionCategory == %@", category)).filter(selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
            
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
        
        pieChart.data = data
        
        
        
    }
    
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
    
    func currentMonthPredicate(date: Date) -> NSPredicate {
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: selectedDate)
        
        components.day = 01
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.day = 31
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }
    
    func selectedMonthPredicate() -> NSPredicate {
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: MonthToAdjust.date)
        
        components.day = 01
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.day = 31
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }
    
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
        
        monthYearLabel.text = formatter.string(from: selectedDate)
        
    }
    
    //    private func setGraphCenterText(index: Int, amount: Double) {
    //
    //        graphCenterText = "\(index)\n\(amount)"
    //        print(graphCenterText)
    //
    //    }
    
    //MARK: - IBActions
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
        MonthToAdjust.decreaseDateByAMonth()
        monthYearLabel.text = formatter.string(from: selectedDate)
        configureProgressBar()
//        dateSwitcherDelegate.getDate(with: selectedDate)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!

        MonthToAdjust.increaseDateByAMonth()
        monthYearLabel.text = formatter.string(from: selectedDate)
        configureProgressBar()

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)
        
    }
    
    @IBAction func chartSwitcherPressed(_ sender: UIButton) {
        
        
        
    }
    
    
}

//MARK: - ChartView Delegate
extension HeaderView: ChartViewDelegate {
    
    
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


