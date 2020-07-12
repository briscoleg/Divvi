//
//  AddTransactionViewController.swift
//  Balance
//
//  Created by Bo on 6/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift
import SwiftDate

class AddTransactionViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var incomeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var recurringButton: UIButton!
    @IBOutlet weak var recursLabel: UILabel!
    
    //MARK: - Properties
    let realm = try! Realm()
    public var buttonCounter = 1
    var amount = 0.0
    var name = ""
    var desc: String?
    lazy var datePicked = Date()
    var category = ""
    public var isExpense = true
    let darkRed = 0xc0392b
    let darkGreen = 0x2ecc71
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTextField.delegate = self
        calendar.delegate = self
        calendar.dataSource = self
        
        setupAmountView()
        roundButtonCorners()
        
        //        saveMultipleTransactions()
        
    }
    
    //MARK: - Methods
    
    func setupViews() {
        
        switch buttonCounter {
            
        case 1:
            setupAmountView()
        case 2:
            setupNameView()
            
        case 3:
            
            setupDateView()
            
        case 4:
            saveMultipleTransactions()
            
        default:
            print("Error")
        }
        
    }
    
    func convertCurrency() {
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        let number = formatter.number(from: currencyTextField.text!)
        let doubleValue = number?.doubleValue
        amount = doubleValue!
        
    }
    
    func roundButtonCorners() {
        
        backButton.roundCorners()
        nextButton.roundCorners()
        recurringButton.roundCorners()
        
    }
    
    func setupAmountView() {
        
        currencyTextField.isHidden = false
        currencyTextField.becomeFirstResponder()
        currencyTextField.keyboardType = .decimalPad
        descriptionTextField.isHidden = true
        nameTextField.isHidden = true
        calendar.isHidden = true
        backButton.isHidden = true
        nextButton.isHidden = false
        instructionsLabel.text = "Amount:"
        incomeSegmentedControl.isHidden = false
        recurringButton.isHidden = true
        recursLabel.isHidden = true
        if isExpense {
            currencyTextField.textColor = UIColor(rgb: darkRed)
        }
        
    }
    
    func setupExpenseIncomeView() {
        
        instructionsLabel.text = "Income or Expense?"
        nextButton.isHidden = true
        backButton.isHidden = false
        currencyTextField.resignFirstResponder()
        nameTextField.isHidden = true
        descriptionTextField.isHidden = true
        currencyTextField.isHidden = false
    }
    
    func setupNameView() {
        
        //        convertCurrency()
        
        incomeSegmentedControl.isHidden = true
        instructionsLabel.isHidden = false
        instructionsLabel.text = "Name:"
        nameTextField.placeholder = "Starbucks"
        currencyTextField.reloadInputViews()
        descriptionTextField.isHidden = false
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Add description (optional)",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        currencyTextField.isHidden = true
        nameTextField.isHidden = false
        backButton.isHidden = false
        nextButton.isHidden = false
        nameTextField.becomeFirstResponder()
        calendar.isHidden = true
        recurringButton.isHidden = true
        recursLabel.isHidden = true
        nextButton.setTitle("Next", for: .normal)
        
        
    }
    
    func setupDateView() {
        
        instructionsLabel.text = "Select a Date:"
        recursLabel.text = "Is this a recurrring transaction?"
        
        name = nameTextField.text!
        desc = descriptionTextField.text!
        
        currencyTextField.isHidden = true
        descriptionTextField.isHidden = true
        nameTextField.isHidden = true
        calendar.isHidden = false
        recurringButton.isHidden = false
        recursLabel.isHidden = false
        nextButton.setTitle("Done", for: .normal)
        UIApplication.shared.hideKeyboard()
        
    }
    
    func saveTransaction() {
        
        let newTransaction = Transaction()
        
        newTransaction.transactionAmount = amount
        newTransaction.transactionName = name
        newTransaction.transactionDescription = desc
        newTransaction.transactionDate = datePicked
        newTransaction.transactionCategory = category
        
        try! realm.write {
            realm.add(newTransaction)
        }
        
        DataManager.shared.firstVC.tableView.reloadData()
        DataManager.shared.summaryVC.viewDidLoad()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func saveMultipleTransactions() {
        
        var transactionArray:[Transaction] = []
        let numberOfTransactionsToAdd = 2
        
        for _ in 1...numberOfTransactionsToAdd {
            
            let addedTransaction = Transaction()
            
            addedTransaction.transactionAmount = amount
            addedTransaction.transactionName = name
            addedTransaction.transactionDescription = desc
            addedTransaction.transactionDate = datePicked
            addedTransaction.transactionCategory = category
            
            transactionArray.append(addedTransaction)
            
            datePicked = datePicked + 1.months
            
        }
        
        let transactionList = List<Transaction>()
        
        
        for transaction in transactionArray {
            
            transactionList.append(transaction)
            
        }
        
        try! realm.write {
            realm.add(transactionList)
        }
        
        DataManager.shared.firstVC.tableView.reloadData()
        DataManager.shared.summaryVC.viewDidLoad()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: - IBActions
    @IBAction func nextPressed(_ sender: UIButton) {
        
        
        if currencyTextField.text == "" {
            print("Invalid amount")
        } else {
            buttonCounter += 1
        }
        print(buttonCounter)
        setupViews()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func incomeSegmentedControlPressed(_ sender: UISegmentedControl) {
        
        switch incomeSegmentedControl.selectedSegmentIndex {
            
        case 0:
            
            isExpense = true
            if isExpense && currencyTextField.text != ""{
                currencyTextField.addMinus()
            }
            instructionsLabel.text = "Expense"
            currencyTextField.textColor = UIColor(rgb: darkRed)
            
        case 1:
            
            if isExpense {
                currencyTextField.dropMinus()
            }
            isExpense = false
            
            instructionsLabel.text = "Income"
            currencyTextField.textColor = UIColor(rgb: darkGreen)
            
        default:
            break
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        buttonCounter -= 1
        
        setupViews()
        
        print(buttonCounter)
        setupViews()
        
    }
    
    @IBAction func recurringButtonPressed(_ sender: UIButton) {
        
        
        
    }
    
    
    //MARK: - Calendar Delegate Methods
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        datePicked = date
        
    }
}
//MARK: - Extensions
extension UIButton {
    func roundCorners(){
        
        let radius = bounds.maxX / 16
        
        layer.cornerRadius = radius
        
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UITextField {
    func addMinus() {
        
        if text?.hasPrefix("-") == false {
            self.text = "-\(text!)"
        }
    }
}

extension UITextField {
    func dropMinus() {
        
        if let text = self.text {
            if text.hasPrefix("-") {
                self.text = String(text.dropFirst())
            }
        }
    }
}

extension UIViewController: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let dotString = "."
        let dollarSign = "$"
        let minusSign = "-$"
        
        if let text = textField.text{
            if !text.contains(dollarSign){
                textField.text = "-\(dollarSign)\(text)"
            }

            let backSpace = string.isEmpty
            if backSpace && text == minusSign {
                textField.text = ""
            }
            if !backSpace {
                if text.contains(dotString) {
                    if text.components(separatedBy: dotString)[1].count == 2 || string == "."  {
                        return false
                    }
                }
            }
        }
        return true
    }
}
