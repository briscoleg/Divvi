//
//  BudgetOverviewVC.swift
//  Balance
//
//  Created by Bo on 8/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class BudgetOverviewVC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var prevMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var plannedActualSegmentedControl: UISegmentedControl!
    @IBOutlet weak var expenseAmountLabel: UILabel!
    @IBOutlet weak var incomeAmountLabel: UILabel!
    @IBOutlet weak var netInstructionsLabel: UILabel!
    @IBOutlet weak var netAmountLabel: UILabel!
    @IBOutlet weak var progressView: CircularGraph!
    @IBOutlet weak var editBudgetButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    
    //MARK: - Properties
    
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self)}()
    
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.lineWidth = 35.0
        editBudgetButton.roundCorners()
        updatePlannedBudget()
        
        expenseAmountLabel.textColor = UIColor(rgb: Constants.red)
        
        incomeAmountLabel.textColor = UIColor(rgb: Constants.green)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "planningAmountAdded"), object: nil)

    }
    
    //MARK: - Methods
    
    @objc func refresh() {
        updatePlannedBudget()
    }
    
    func predicateForMonthFromDate(date: Date) -> NSPredicate {
                
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.day = 01
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.day = Date().day
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }
    
    func updatePlannedBudget() {

        
        progressView.trackLayerStrokeColor = .clear
        progressView.progressLayerStrokeColor = UIColor(rgb: Constants.blue)


        let incomePlannedTotal = categories[0].categoryAmountBudgeted

        incomeAmountLabel.text = incomePlannedTotal.toCurrency()

        let expensesPlannedTotal: Double = abs(categories.filter(NSPredicate(format: "categoryName != %@", "Income")).sum(ofProperty: "categoryAmountBudgeted"))

        expenseAmountLabel.text = expensesPlannedTotal.toCurrency()

        let incomeMinusExpenseAmount = incomePlannedTotal - expensesPlannedTotal

        let incomeToExpenseRatio =  expensesPlannedTotal / incomePlannedTotal

        if incomePlannedTotal == 0.0 {
            percentLabel.text = "0%"
        } else {
            percentLabel.text = String(format: "%.0f%%", incomeToExpenseRatio * 100)
        }
        
        if incomePlannedTotal == 0.0 {
            netAmountLabel.text = "No income planned for \(monthYearLabel.text!).\nTap Edit Budget to get started."
        } else if incomeMinusExpenseAmount > 0 {
            netAmountLabel.text = "\(incomeMinusExpenseAmount.toCurrency())\nleft to budget"
        } else if incomeMinusExpenseAmount < 0 {
            netAmountLabel.text = "\(incomeMinusExpenseAmount.toCurrency()) over budget"
        } else {
//            progressView.progressLayerStrokeColor = UIColor(rgb: Constants.blue)
//            progressView.trackLayerStrokeColor = .clear
            netAmountLabel.text = "Budget balanced!"
        }

        progressView.animateProgress(duration: 0.75, value: incomeToExpenseRatio)


    }
    
    func updateSpentBudget() {
        
        progressView.trackLayerStrokeColor = UIColor(rgb: Constants.green)
        progressView.progressLayerStrokeColor = UIColor(rgb: Constants.red)
        
        let incomePlannedTotal = categories[0].categoryAmountBudgeted
        incomeAmountLabel.text = incomePlannedTotal.toCurrency()
                
        let expensesSpentTotal: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory != %@", categories[0])).filter(predicateForMonthFromDate(date: Date())).sum(ofProperty: "transactionAmount"))
        
        expenseAmountLabel.text = expensesSpentTotal.toCurrency()
        
        let incomeMinusExpenseAmount = incomePlannedTotal - expensesSpentTotal

        let incomeToExpenseRatio =  expensesSpentTotal / incomePlannedTotal
        
        if incomePlannedTotal == 0.0 {
            percentLabel.text = "0%"
        } else {
            percentLabel.text = String(format: "%.0f%%", incomeToExpenseRatio * 100)
        }
        
        if incomePlannedTotal == 0.0 {
                    netAmountLabel.text = "No income planned for \(monthYearLabel.text!).\nTap Edit Budget to get started."
                } else if incomeMinusExpenseAmount > 0 {
                    netAmountLabel.text = "\(incomeMinusExpenseAmount.toCurrency())\nleft to spend."
                } else if incomeMinusExpenseAmount < 0 {
                    netAmountLabel.text = "\(incomeMinusExpenseAmount.toCurrency()) over spent."
                } else {
        //            progressView.progressLayerStrokeColor = UIColor(rgb: Constants.blue)
        //            progressView.trackLayerStrokeColor = .clear
                    netAmountLabel.text = "Spent all of budget."
                }

                progressView.animateProgress(duration: 0.75, value: incomeToExpenseRatio)
        

    }
    
    
    
    //MARK: - IBActions

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {

        switch plannedActualSegmentedControl.selectedSegmentIndex {
        case 0:
            updatePlannedBudget()
        case 1:
            updateSpentBudget()
        default:
            return
        }

    }
    @IBAction func prevMonthPressed(_ sender: UIButton) {
    }
    
    @IBAction func nextMonthPressed(_ sender: UIButton) {
    }
    
    @IBAction func editBudgetPressed(_ sender: UIButton) {
    }
    
    
}

//MARK: - Extensions


