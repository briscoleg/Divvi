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

class AddTransactionViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var expenseButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: - Properties
    let realm = try! Realm()
    public var buttonCounter = 0
    var amount = 0.0
    var name = ""
    var desc: String?
    var datePicked = Date()
    var isExpense = true
    let darkRed = 0xD93D24
    let darkGreen = 0x59C13B
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTextField.delegate = self
        calendar.delegate = self
        calendar.dataSource = self
        
        setupAmountView()
        
    }
    
    //MARK: - Methods
    
    func setupAmountView() {
        
        currencyTextField.becomeFirstResponder()
        currencyTextField.keyboardType = .decimalPad
        currencyTextField.textColor = UIColor(rgb: darkRed)
        descriptionTextField.isHidden = true
        nameTextField.isHidden = true
        calendar.isHidden = true
        instructionsLabel.text = "Enter Expense:"
        
        nextButton.roundCorners()
        incomeButton.roundCorners()
        incomeButton.backgroundColor = .gray
        expenseButton.roundCorners()
        
        
    }
    
    func convertCurrency() {

        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        let number = formatter.number(from: currencyTextField.text!)
        let doubleValue = number?.doubleValue
        amount = doubleValue!

    }
    
    func setupNameView() {
        
        convertCurrency()
        
        instructionsLabel.text = "Enter Name:"
        nameTextField.placeholder = "e.g. Starbucks"
        currencyTextField.reloadInputViews()
        descriptionTextField.isHidden = false
        incomeButton.isHidden = true
        expenseButton.isHidden = true
        currencyTextField.isHidden = true
        nameTextField.isHidden = false
        nameTextField.becomeFirstResponder()
        
    }
    
    func setupDateView() {
        
        instructionsLabel.text = "Select a Date:"
        
        name = nameTextField.text!
        desc = descriptionTextField.text!

        currencyTextField.isHidden = true
        descriptionTextField.isHidden = true
        nameTextField.isHidden = true
        calendar.isHidden = false
        nextButton.setTitle("Done", for: .normal)
        UIApplication.shared.hideKeyboard()
        
    }
    
    func saveTransaction() {
        
        let newTransaction = Transaction()
        
        newTransaction.transactionAmount = amount
        newTransaction.transactionName = name
        newTransaction.transactionDescription = desc
        newTransaction.transactionDate = datePicked
        
        try! realm.write {
            realm.add(newTransaction)
        }
        
        DataManager.shared.firstVC.tableView.reloadData()
        DataManager.shared.summaryVC.viewDidLoad()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: - IBActions
    @IBAction func nextPressed(_ sender: UIButton) {
        
        buttonCounter += 1
        
        switch buttonCounter {
            
        case 1:
            
            setupNameView()
            
        case 2:
            
            setupDateView()
            
        case 3:
            
            saveTransaction()
            
        default:
            print("Error")
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func incomeButtonPressed(_ sender: UIButton) {
        
        if isExpense == true {
            currencyTextField.dropMinus()
        }
        isExpense = false
        expenseButton.backgroundColor = .gray
        incomeButton.backgroundColor = UIColor(rgb: darkGreen)
        instructionsLabel.text = "Enter Income:"
        currencyTextField.textColor = UIColor(rgb: darkGreen)
        
        
    }
    
    @IBAction func expenseButtonPressed(_ sender: UIButton) {
        
        if isExpense == false {
            currencyTextField.addMinus()
        }
        isExpense = true
        expenseButton.backgroundColor = UIColor(rgb: darkRed)
        incomeButton.backgroundColor = .gray
        instructionsLabel.text = "Enter Expense:"
        currencyTextField.textColor = UIColor(rgb: darkRed)
        
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
        let character = "$"

        if let text = textField.text{
            if !text.contains(character){
                textField.text = "-\(character)\(text)"
            }
            let isDeleteKey = string.isEmpty

            if !isDeleteKey {
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
