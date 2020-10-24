//
//  Add2VC.swift
//  Balance
//
//  Created by Bo on 8/10/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift
import FSCalendar
import SwiftDate

class AddTransactionVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var categoryImage: UIImageView!
    
    //MARK: - Properties
    let amountFieldAccessory: UIView = {
        let accessoryView = UIView(frame: .zero)
        accessoryView.backgroundColor = UIColor(red: 204, green: 207, blue: 214)
        accessoryView.alpha = 0.8
        return accessoryView
    }()
    
    let descriptionFieldAccessory: UIView = {
        let accessoryView = UIView(frame: .zero)
        accessoryView.backgroundColor = UIColor(red: 204, green: 207, blue: 214)
        accessoryView.alpha = 0.8
        return accessoryView
    }()
    
    let keyboardDismissButton: UIButton = {
        
        let keyboardDismissButton = UIButton(type: .custom)
        keyboardDismissButton.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        keyboardDismissButton.addTarget(self, action: #selector(keyboardDismissButtonTapped), for: .touchUpInside)
        keyboardDismissButton.showsTouchWhenHighlighted = true
        return keyboardDismissButton
        
    }()
    
    let plusMinusButton: UIButton = {
        let plusMinusButton = UIButton(type: .custom)
        plusMinusButton.setTitle("+/-", for: .normal)
        plusMinusButton.setTitleColor(UIColor.link, for: .normal)
        plusMinusButton.addTarget(self, action: #selector(plusMinusButtonTapped), for: .touchUpInside)
        plusMinusButton.showsTouchWhenHighlighted = true
        return plusMinusButton
    }()
    
    let nextAccessoryButton: UIButton! = {
        let nextAccessoryButton = UIButton(type: .custom)
        nextAccessoryButton.setTitleColor(.link, for: .normal)
        nextAccessoryButton.setTitle("Category", for: .normal)
        nextAccessoryButton.setTitleColor(.white, for: .disabled)
        nextAccessoryButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextAccessoryButton.showsTouchWhenHighlighted = true
        nextAccessoryButton.isEnabled = true
        return nextAccessoryButton
    }()
    
    let realm = try! Realm()
    
    var transaction: Transaction?
    
    var amount = 0.0
    var categoryPicked: Category?
    var subcategoryPicked: SubCategory?
    var datePicked = Date()
    var repeatInterval = "Never"
    var isExpense = true
    var newTransaction = true
    var numberOfTransactionsToAdd = 1
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repeatButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if categoryPicked != nil {
            getCategory(from: categoryPicked!)
        }
        amountTextField.delegate = self
        descriptionTextField.delegate = self
        
        
        setEditFields()
        
        
        amountTextField.becomeFirstResponder()
        
        addAmountFieldAccessory()
        
        navigationBar.setValue(true, forKey: "hidesShadow")
        
        
        //                addDescriptionFieldAccessory()
        
        saveButton.roundCorners()
        
        if categoryPicked?.categoryName == "Income" {
            amountTextField.textColor = UIColor(rgb: SystemColors.green)
        } else {
            amountTextField.textColor = UIColor(rgb: SystemColors.red)
        }
        
        addInputAccessoryForTextFields(textFields: [descriptionTextField], dismissable: true, previousNextable: false)
        
    }
    
    //MARK: - Methods
    
    private func setEditFields() {
        
        guard transaction != nil  else { return }
        
        if let transaction = transaction {
            
            amountTextField.text = String(format: "%.2f", transaction.transactionAmount)
            categoryPicked = transaction.transactionCategory
            subcategoryPicked = transaction.transactionSubCategory
            categoryImage.tintColor = UIColor(rgb: categoryPicked!.categoryColor)
            
            displaySelectedDate(transaction.transactionDate)
            displayRepeatInterval(transaction.transactionDate)
            
            repeatButton.setTitle("Repeats: \(repeatInterval)", for: .normal)
            
            categoryButton.setTitle(subcategoryPicked?.subCategoryName, for: .normal)
            categoryButton.setTitleColor(UIColor(rgb: categoryPicked!.categoryColor), for: .normal)
            categoryButton.tintColor = UIColor(rgb: categoryPicked!.categoryColor)
            
            
            
            descriptionTextField.text = transaction.transactionDescription
            
            navigationBar.topItem?.title = "Edit Transaction"
        }
        
    }
    
    @objc func hideKeyboard() {
        descriptionTextField.resignFirstResponder()
    }
    
    func convertAmountToCurrency() {
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        let number = formatter.number(from: amountTextField.text!)
        let doubleValue = number?.doubleValue
        amount = doubleValue!
        
    }
    
    func setNumberOfTransactions() {
        
        switch repeatInterval {
        
        case "Yearly":
            numberOfTransactionsToAdd = 5
        case "Monthly":
            numberOfTransactionsToAdd = 60
        case "Every Two Weeks":
            numberOfTransactionsToAdd = 120
        case "Weekly":
            numberOfTransactionsToAdd = 240
        case "Daily":
            numberOfTransactionsToAdd = 3000
        case "Never":
            numberOfTransactionsToAdd = 1
        default:
            break
        }
    }
    @objc func objcSaveTransaction() {
        saveTransaction()
    }
    private func saveEdit() {
        
        try! realm.write {
            transaction!.transactionAmount = amountTextField.text!.toDouble()
            transaction!.transactionDescription = descriptionTextField.text!
            transaction!.transactionDate = datePicked
            transaction!.transactionCategory = categoryPicked
            transaction!.transactionSubCategory = subcategoryPicked
            transaction!.repeatInterval = repeatInterval
            
        }
    }
    
    func saveTransaction() {
        
        guard amountTextField.text != "" else { amountTextField.placeholder = "Enter an Amount"; return }
        guard subcategoryPicked != nil else { categoryButton.setTitle("Select a Category", for: .normal); return }
        
        if !newTransaction {
            
            setNumberOfTransactions()
            saveEdit()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionEdited"), object: nil)
            
        } else {
            
            setNumberOfTransactions()
            
                for _ in 1...self.numberOfTransactionsToAdd {
                    
                    let newTransaction = Transaction()
                    
                    var timeAdded = 1.months
                    //                var timeAdded = Calendar.Component.month
                    newTransaction.transactionAmount = self.amountTextField.text!.toDouble()
                    newTransaction.transactionDescription = self.descriptionTextField.text
                    newTransaction.transactionDate = self.datePicked
                    newTransaction.transactionCategory = self.categoryPicked
                    newTransaction.repeatInterval = self.repeatInterval
                    newTransaction.transactionSubCategory = self.subcategoryPicked
                    newTransaction.subCategoryName = self.subcategoryPicked!.subCategoryName
                    
                    switch self.repeatInterval {
                    case "Yearly":
                        timeAdded = 1.years
                    case "Monthly":
                        timeAdded = 1.months
                    case "Every Two Weeks":
                        timeAdded = 2.weeks
                    case "Weekly":
                        timeAdded = 1.weeks
                    case "Daily":
                        timeAdded = 1.days
                    default:
                        break
                    }
                    
                    try! self.realm.write {
                        self.realm.add(newTransaction)
                    }
                    
                    self.datePicked = self.datePicked + timeAdded

            }

        }
        
        
    }
    
    func displayRepeatInterval(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM d"
        
        let dateString = formatter.string(from: date)
        
        if repeatInterval != "Never" && datePicked.day == Date().day {
            dateButton.setTitle("Starts Today", for: .normal)
        } else if repeatInterval != "Never" {
            dateButton.setTitle("Starts \(dateString)", for: .normal)
        } else if repeatInterval == "Never" && datePicked.day == Date().day {
            dateButton.setTitle("Today", for: .normal)
        } else {
            dateButton.setTitle(dateString, for: .normal)
        }
    }
    
    func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        
        if dateString == formatter.string(from: Date()) {
            dateButton.setTitle("Today", for: .normal)
        } else {
            dateButton.setTitle(dateString, for: .normal)
        }
        
    }
    
    @objc func plusMinusButtonTapped() {
        
        if isExpense {
            amountTextField.dropMinus()
            amountTextField.textColor = UIColor(rgb: SystemColors.green)
            isExpense = false
        } else {
            amountTextField.addMinus()
            amountTextField.textColor = UIColor(rgb: SystemColors.red)
            isExpense = true
        }
        
    }
    
    
    
    func addAmountFieldAccessory() {
        
        amountFieldAccessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        amountFieldAccessory.translatesAutoresizingMaskIntoConstraints = false
        
        keyboardDismissButton.translatesAutoresizingMaskIntoConstraints = false
        nextAccessoryButton.translatesAutoresizingMaskIntoConstraints = false
        plusMinusButton.translatesAutoresizingMaskIntoConstraints = false
        
        amountTextField.inputAccessoryView = amountFieldAccessory
        
        amountFieldAccessory.addSubview(keyboardDismissButton)
        amountFieldAccessory.addSubview(plusMinusButton)
        amountFieldAccessory.addSubview(nextAccessoryButton)
        
        
        NSLayoutConstraint.activate([
            
            keyboardDismissButton.leadingAnchor.constraint(equalTo:
                                                            amountFieldAccessory.leadingAnchor, constant: 30),
            keyboardDismissButton.centerYAnchor.constraint(equalTo:
                                                            amountFieldAccessory.centerYAnchor),
            
            //            keyboardDismissButton.centerXAnchor.constraint(equalTo: accessory.leadingAnchor, constant: 40),
            //            keyboardDismissButton.centerYAnchor.constraint(equalTo: accessory.centerYAnchor),
            
            plusMinusButton.centerXAnchor.constraint(equalTo:
                                                        amountFieldAccessory.centerXAnchor),
            plusMinusButton.centerYAnchor.constraint(equalTo:
                                                        amountFieldAccessory.centerYAnchor),
            
            nextAccessoryButton.trailingAnchor.constraint(equalTo: amountFieldAccessory.trailingAnchor, constant: -30),
            nextAccessoryButton.centerYAnchor.constraint(equalTo: amountFieldAccessory.centerYAnchor),
            
        ])
    }
    
    func addDescriptionFieldAccessory() {
        
        descriptionFieldAccessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        descriptionFieldAccessory.translatesAutoresizingMaskIntoConstraints = false
        
        keyboardDismissButton.translatesAutoresizingMaskIntoConstraints = false
        nextAccessoryButton.translatesAutoresizingMaskIntoConstraints = false
        plusMinusButton.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextField.inputAccessoryView = amountFieldAccessory
        
        descriptionFieldAccessory.addSubview(keyboardDismissButton)
        descriptionFieldAccessory.addSubview(plusMinusButton)
        descriptionFieldAccessory.addSubview(nextAccessoryButton)
        
        NSLayoutConstraint.deactivate([
            
            keyboardDismissButton.leadingAnchor.constraint(equalTo:
                                                            amountFieldAccessory.leadingAnchor, constant: 30),
            keyboardDismissButton.centerYAnchor.constraint(equalTo:
                                                            amountFieldAccessory.centerYAnchor),
            
            //            keyboardDismissButton.centerXAnchor.constraint(equalTo: accessory.leadingAnchor, constant: 40),
            //            keyboardDismissButton.centerYAnchor.constraint(equalTo: accessory.centerYAnchor),
            
            plusMinusButton.centerXAnchor.constraint(equalTo:
                                                        amountFieldAccessory.centerXAnchor),
            plusMinusButton.centerYAnchor.constraint(equalTo:
                                                        amountFieldAccessory.centerYAnchor),
            
            nextAccessoryButton.trailingAnchor.constraint(equalTo: amountFieldAccessory.trailingAnchor, constant: -30),
            nextAccessoryButton.centerYAnchor.constraint(equalTo: amountFieldAccessory.centerYAnchor),
            
        ])
        NSLayoutConstraint.activate([
            
            keyboardDismissButton.leadingAnchor.constraint(equalTo:
                                                            descriptionFieldAccessory.leadingAnchor, constant: 30),
            keyboardDismissButton.centerYAnchor.constraint(equalTo:
                                                            descriptionFieldAccessory.centerYAnchor),
            
            //            keyboardDismissButton.centerXAnchor.constraint(equalTo: accessory.leadingAnchor, constant: 40),
            //            keyboardDismissButton.centerYAnchor.constraint(equalTo: accessory.centerYAnchor),
            
            plusMinusButton.centerXAnchor.constraint(equalTo:
                                                        descriptionFieldAccessory.centerXAnchor),
            plusMinusButton.centerYAnchor.constraint(equalTo:
                                                        descriptionFieldAccessory.centerYAnchor),
            
            nextAccessoryButton.trailingAnchor.constraint(equalTo: amountFieldAccessory.trailingAnchor, constant: -30),
            nextAccessoryButton.centerYAnchor.constraint(equalTo: amountFieldAccessory.centerYAnchor),
            
        ])
    }
    
    //MARK: - IBActions
    
    @objc func nextButtonTapped() {
        
        let categoryVC = storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        
        categoryVC.categoryDelegate = self
        
        amountTextField.resignFirstResponder()
        
        present(categoryVC, animated: true, completion: nil)
        
    }
    
    @objc func keyboardDismissButtonTapped() {
        
        amountTextField.resignFirstResponder()
        
    }
    
    @IBAction func categoryButtonPressed(_ sender: UIButton) {
        
        let categoryVC = storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        
        categoryVC.categoryDelegate = self
        
        amountTextField.resignFirstResponder()
        
        present(categoryVC, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        
        let calendarVC = storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarVC
        
        calendarVC.dateDelegate = self
        
        present(calendarVC, animated: true, completion: nil)
        
    }
    
    @IBAction func repeatButtonPressed(_ sender: UIButton) {
        
        let calendarVC = storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarVC
        
        calendarVC.dateDelegate = self
        
        present(calendarVC, animated: true, completion: nil)
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        self.saveTransaction()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


//MARK: - Extensions
extension AddTransactionVC: UITextFieldDelegate {
    
    //    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    //        if amountTextField.isEditing {
    //            addAmountFieldAccessory()
    //        }
    //        if descriptionTextField.isEditing {
    //            addDescriptionFieldAccessory()
    //        }
    //        return true
    //    }
    
    //    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    //        textField.resignFirstResponder()
    //    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == descriptionTextField {
            // get the current text, or use an empty string if that failed
            guard let textFieldText = textField.text,
                    let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                        return false
                }
                let substringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - substringToReplace.count + string.count
                return count <= 30
        }
        
        if textField == amountTextField {
            
            if let text = textField.text{
                let dotString = "."
                let minusSign = "-$"
                if !text.contains("-") && isExpense {
                    textField.text = "-\(text)"
                }
                if !isExpense {
                    textField.text = "\(text)"
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
        }
        return true
    }
}

extension AddTransactionVC: CategoryDelegate {
    func getSubcategory(from subcategory: SubCategory) {
        subcategoryPicked = subcategory
        categoryButton.setTitle(subcategory.subCategoryName, for: .normal)
        descriptionTextField.becomeFirstResponder()
        categoryImage.image = UIImage(named: categoryPicked!.categoryName)
        categoryImage.tintColor = UIColor(rgb: categoryPicked!.categoryColor)
        categoryButton.setTitleColor(UIColor(rgb: categoryPicked!.categoryColor), for: .normal)
        categoryButton.tintColor = UIColor(rgb: categoryPicked!.categoryColor)
        
        if categoryPicked?.categoryName == "Income" {
            amountTextField.dropMinus()
            isExpense = false
            amountTextField.textColor = UIColor(rgb: SystemColors.green)
        }
    }
    
    func getCategory(from category: Category) {
        categoryPicked = category
    }
}

extension AddTransactionVC: DateDelegate {
    func getCalendarDate(from date: Date) {
        datePicked = date
        displaySelectedDate(date)
        displayRepeatInterval(date)
    }
    func getRepeatInterval(interval: String) {
        repeatInterval = interval
        repeatButton.setTitle("Repeats: \(repeatInterval)", for: .normal)
        displayRepeatInterval(datePicked)
    }
}


