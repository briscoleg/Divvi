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
    
    //VC Identifier
    static let identifier = "AddTransactionVC"
    
    //MARK: - IBOutlets
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var categoryImage: UIImageView!
    
    //MARK: - Properties
    
    let realm = try! Realm()
    var transaction: Transaction?
    var categoryPicked: Category?
    
    lazy var allTransactions: Results<Transaction> = {realm.objects(Transaction.self)}()
    lazy var unclearedTransactionsToDate: Results<Transaction> = { allTransactions.filter("transactionDate <= %@", Date()).filter("isCleared == %@", false).sorted(byKeyPath: "transactionDate", ascending: true) }()
       
    //Default transaction values
    var amount = 0.0
    let summaryVC = SummaryVC()

    var datePicked = SummaryVC.dateForNewTransaction

    var repeatInterval = "Never"
    var isExpense = true
    var newTransaction = true
    var numberOfTransactionsToAdd = 1
    var transactionName = ""
    
    // Keyboard Accessory Views
    let amountFieldAccessory: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemGray4
        view.alpha = 0.8
        return view
    }()
    
    let descriptionFieldAccessory: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemGray4
        view.alpha = 0.8
        return view
    }()
    
    let chooseDateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Choose Date", for: .normal)
        button.setTitleColor(UIColor.link, for: .normal)
        button.addTarget(self, action: #selector(chooseDateTapped), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    let keyboardDismissButton: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        button.addTarget(self, action: #selector(keyboardDismissButtonTapped), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        return button
        
    }()
    
    let plusMinusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("+/-", for: .normal)
        button.setTitleColor(UIColor.link, for: .normal)
        button.addTarget(self, action: #selector(plusMinusButtonTapped), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    let accessorySaveButton: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(accessorySaveButtonTapped), for: .touchUpInside)
//        button.tintColor = UIColor(rgb: SystemColors.shared.blue)
        button.showsTouchWhenHighlighted = true
        return button
        
    }()
    
    let categoryAccessoryButton: UIButton! = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Category", for: .normal)
        button.setTitleColor(.white, for: .disabled)
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        button.isEnabled = true
        return button
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
                
        amountTextField.delegate = self
        descriptionTextField.delegate = self
        
        amountTextField.becomeFirstResponder()

        customizeAppearance()
        setEditFields()
        setAmountTextfieldColor()
        setTitle()
        setCategoryNameAndColor()
        
//        datePicked = SummaryVC.dateForNewTransaction
        
//        dateButton.setTitle(datePicked.dateToString(), for: .normal)
        
        print(datePicked)
                
        //Add keyboard accessories
//        addAmountFieldAccessory()
//        addDescriptionFieldAccessory()
//        addInputAccessoryForTextFields(textFields: [descriptionTextField], dismissable: true, previousNextable: false)
        
    }
    
    //MARK: - Methods
    
    private func customizeAppearance() {
        
        saveButton.roundCorners()
        displaySelectedDate(datePicked)
        navigationBar.setValue(true, forKey: "hidesShadow")
        UINavigationBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        UINavigationBar.appearance().isTranslucent = false

    }
    
    private func setCategoryNameAndColor() {
        
        if let categoryPicked = categoryPicked {
            categoryImage.image = UIImage(named: categoryPicked.categoryName)
            categoryImage.tintColor = UIColor(rgb: categoryPicked.categoryColor)
            categoryButton.setTitleColor(UIColor(rgb: categoryPicked.categoryColor), for: .normal)
            categoryButton.tintColor = UIColor(rgb: categoryPicked.categoryColor)
        }
        
    }
      
    private func setAmountTextfieldColor() {
        
        if categoryPicked?.categoryName == "Income" {
            amountTextField.textColor = UIColor(rgb: SystemColors.shared.green)
        } else {
            amountTextField.textColor = UIColor(rgb: SystemColors.shared.red)
        }
    }
    
    private func setTitle() {
        if newTransaction {
            navigationBar.topItem?.title = "New Transaction"
        } else {
            navigationBar.topItem?.title = "Edit Transaction"
        }
    }
    
    private func setEditFields() {
                
        if let transaction = transaction {
                        
            transactionName = transaction.transactionName
            datePicked = transaction.transactionDate
            repeatInterval = transaction.repeatInterval
            
            amountTextField.text = String(format: "%.2f", transaction.transactionAmount)
            categoryPicked = transaction.transactionCategory
            displaySelectedDate(transaction.transactionDate)
            displayRepeatInterval(with: transaction.transactionDate)
            categoryButton.setTitle(transaction.transactionName, for: .normal)
            descriptionTextField.text = transaction.transactionDescription
//            dateButton.setTitle("\(transaction.transactionDate.toString(style: .long))\n\("Repeats: \(transaction.repeatInterval)")", for: .normal)

        }
        
    }
    
    @objc func hideKeyboard() {
        descriptionTextField.resignFirstResponder()
    }
    
    private func setNumberOfTransactions() {
        
        switch repeatInterval {
        
        case RepeatInterval.yearly.rawValue:
            numberOfTransactionsToAdd = 5
        case RepeatInterval.monthly.rawValue:
            numberOfTransactionsToAdd = 60
        case RepeatInterval.twoWeeks.rawValue:
            numberOfTransactionsToAdd = 120
        case RepeatInterval.weekly.rawValue:
            numberOfTransactionsToAdd = 240
        case RepeatInterval.daily.rawValue:
            numberOfTransactionsToAdd = 480
        case RepeatInterval.never.rawValue:
            numberOfTransactionsToAdd = 1
        default:
            break
        }
    }

    private func saveEdit() {
        
        do {
            try realm.write {
                
                transaction!.transactionAmount = amountTextField.text!.toDouble()
                transaction!.transactionDescription = descriptionTextField.text
                transaction!.transactionDate = datePicked
                transaction!.transactionCategory = categoryPicked
                transaction!.repeatInterval = repeatInterval
                transaction!.transactionName = transactionName
                transaction!.isCleared = false
                
            }
        } catch {
            print("Error saving edit: \(error)")
        }
        
    }
    
    private func saveTransaction() {
        
        guard let startingBalance = realm.objects(StartingBalance.self).first else { return }
        
        guard amountTextField.text != "" else { amountTextField.placeholder = "Enter an amount"; return }
        guard categoryPicked != nil else { categoryButton.setTitle("Select a Category", for: .normal); return }

        guard datePicked.isAfterDate(startingBalance.date, orEqual: true, granularity: .day) else { dateButton.setTitle("Choose a date on or after \(startingBalance.date.toString(style: .medium))", for: .normal)
            return
        }
        
        if !newTransaction {
            
            setNumberOfTransactions()
            saveEdit()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionEdited"), object: nil)
            
        } else {
            
            setNumberOfTransactions()
            
            for _ in 1...numberOfTransactionsToAdd {
                
                let newTransaction = Transaction()
                
                var timeAdded = 1.months
                
                newTransaction.transactionAmount = amountTextField.text!.toDouble()
                newTransaction.transactionDescription = descriptionTextField.text
                newTransaction.transactionDate = datePicked
                print(newTransaction.transactionDate)
                newTransaction.transactionCategory = categoryPicked
                newTransaction.repeatInterval = repeatInterval
                newTransaction.transactionName = transactionName
                
                switch repeatInterval {
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
                
                do {
                    try realm.write {
                        realm.add(newTransaction)
                    }
                } catch {
                    print("Error saving transaction: \(error)")
                }
                
                datePicked = datePicked + timeAdded
                
            }
            
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private func displayRepeatInterval(with date: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        
        let dateString = formatter.string(from: date)
        
        if repeatInterval != RepeatInterval.never.rawValue && datePicked.day == Date().day {
            dateButton.setTitle("Starts Today\nRepeats \(repeatInterval)", for: .normal)
        } else if repeatInterval != RepeatInterval.never.rawValue {
            dateButton.setTitle("Starts \(dateString)\nRepeats \(repeatInterval)", for: .normal)
        } else if repeatInterval == RepeatInterval.never.rawValue && datePicked.day == Date().day {
            dateButton.setTitle("Today\nRepeats \(repeatInterval)", for: .normal)
        } else {
            dateButton.setTitle(dateString, for: .normal)
        }
    }
    
    private func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        if dateString == formatter.string(from: Date()) {
            dateButton.setTitle("Today", for: .normal)
        } else {
            dateButton.setTitle(dateString, for: .normal)
        }
        
    }
    
    @objc private func plusMinusButtonTapped() {
        
        if isExpense {
            amountTextField.dropMinus()
            amountTextField.textColor = UIColor(rgb: SystemColors.shared.green)
            isExpense = false
        } else {
            amountTextField.addMinus()
            amountTextField.textColor = UIColor(rgb: SystemColors.shared.red)
            isExpense = true
        }
        
    }
    
    private func addAmountFieldAccessory() {
        
        amountFieldAccessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        amountFieldAccessory.translatesAutoresizingMaskIntoConstraints = false
        
        keyboardDismissButton.translatesAutoresizingMaskIntoConstraints = false
        categoryAccessoryButton.translatesAutoresizingMaskIntoConstraints = false
        plusMinusButton.translatesAutoresizingMaskIntoConstraints = false
        
        amountTextField.inputAccessoryView = amountFieldAccessory
        
        amountFieldAccessory.addSubview(keyboardDismissButton)
        amountFieldAccessory.addSubview(plusMinusButton)
        amountFieldAccessory.addSubview(categoryAccessoryButton)
        
        NSLayoutConstraint.activate([
            
            keyboardDismissButton.leadingAnchor.constraint(equalTo:
                                                            amountFieldAccessory.leadingAnchor, constant: 40),
            keyboardDismissButton.centerYAnchor.constraint(equalTo:
                                                            amountFieldAccessory.centerYAnchor),
            plusMinusButton.centerXAnchor.constraint(equalTo:
                                                        amountFieldAccessory.centerXAnchor),
            plusMinusButton.centerYAnchor.constraint(equalTo:
                                                        amountFieldAccessory.centerYAnchor),
            
            categoryAccessoryButton.trailingAnchor.constraint(equalTo: amountFieldAccessory.trailingAnchor, constant: -40),
            categoryAccessoryButton.centerYAnchor.constraint(equalTo: amountFieldAccessory.centerYAnchor),
            
        ])
    }
    
//    private func addDescriptionFieldAccessory() {
//
//        amountFieldAccessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
//        amountFieldAccessory.translatesAutoresizingMaskIntoConstraints = false
//
//        keyboardDismissButton.translatesAutoresizingMaskIntoConstraints = false
//        categoryAccessoryButton.translatesAutoresizingMaskIntoConstraints = false
//        plusMinusButton.translatesAutoresizingMaskIntoConstraints = false
//
//        descriptionTextField.inputAccessoryView = descriptionFieldAccessory
//
//        amountFieldAccessory.addSubview(keyboardDismissButton)
//        amountFieldAccessory.addSubview(plusMinusButton)
//        amountFieldAccessory.addSubview(categoryAccessoryButton)
//
//
//        NSLayoutConstraint.activate([
//
//            keyboardDismissButton.leadingAnchor.constraint(equalTo:
//                                                            descriptionFieldAccessory.leadingAnchor, constant: 30),
//            keyboardDismissButton.centerYAnchor.constraint(equalTo:
//                                                            descriptionFieldAccessory.centerYAnchor),
//            plusMinusButton.centerXAnchor.constraint(equalTo:
//                                                        descriptionFieldAccessory.centerXAnchor),
//            plusMinusButton.centerYAnchor.constraint(equalTo:
//                                                        descriptionFieldAccessory.centerYAnchor),
//
//            categoryAccessoryButton.trailingAnchor.constraint(equalTo: descriptionFieldAccessory.trailingAnchor, constant: -30),
//            categoryAccessoryButton.centerYAnchor.constraint(equalTo: descriptionFieldAccessory.centerYAnchor),
//
//        ])
//    }
    
    private func addDescriptionFieldAccessory() {

        descriptionFieldAccessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        descriptionFieldAccessory.translatesAutoresizingMaskIntoConstraints = false

        keyboardDismissButton.translatesAutoresizingMaskIntoConstraints = false
        chooseDateButton.translatesAutoresizingMaskIntoConstraints = false
        accessorySaveButton.translatesAutoresizingMaskIntoConstraints = false

        descriptionTextField.inputAccessoryView = descriptionFieldAccessory

        descriptionFieldAccessory.addSubview(keyboardDismissButton)
        descriptionFieldAccessory.addSubview(chooseDateButton)
        descriptionFieldAccessory.addSubview(accessorySaveButton)

        
        NSLayoutConstraint.activate([

            keyboardDismissButton.leadingAnchor.constraint(equalTo:
                                                            descriptionFieldAccessory.leadingAnchor, constant: 40),
            keyboardDismissButton.centerYAnchor.constraint(equalTo:
                                                            descriptionFieldAccessory.centerYAnchor),

            chooseDateButton.centerXAnchor.constraint(equalTo:
                                                        descriptionFieldAccessory.centerXAnchor),
            chooseDateButton.centerYAnchor.constraint(equalTo:
                                                        descriptionFieldAccessory.centerYAnchor),

            accessorySaveButton.trailingAnchor.constraint(equalTo: descriptionFieldAccessory.trailingAnchor, constant: -40),
            accessorySaveButton.centerYAnchor.constraint(equalTo: descriptionFieldAccessory.centerYAnchor),

        ])
    }
    
    //MARK: - IBActions
    
    
    @objc func objcSaveTransaction() {
        
        saveTransaction()

    }
    
    @objc private func chooseDateTapped() {
        if let calendarVC = storyboard?.instantiateViewController(withIdentifier: CalendarVC.identifier) as? CalendarVC {
            
            calendarVC.dateDelegate = self
            present(calendarVC, animated: true, completion: nil)
        }
    }
    
    @objc func categoryButtonTapped() {
        
        if let categoryVC = storyboard?.instantiateViewController(withIdentifier: CategoryVC.identifier) as? CategoryVC {
            
            categoryVC.categoryDelegate = self
            amountTextField.resignFirstResponder()
            present(categoryVC, animated: true, completion: nil)
        }
    }
    
    @objc private func keyboardDismissButtonTapped() {

            amountTextField.resignFirstResponder()
            descriptionTextField.resignFirstResponder()
        
    }
    
    @objc private func accessorySaveButtonTapped() {
        saveTransaction()
    }
    
    @IBAction func categoryButtonPressed(_ sender: UIButton) {
        
        if let categoryVC = storyboard?.instantiateViewController(withIdentifier: CategoryVC.identifier) as? CategoryVC {
            
            categoryVC.categoryDelegate = self
            amountTextField.resignFirstResponder()
            present(categoryVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        
        if let calendarVC = storyboard?.instantiateViewController(withIdentifier: CalendarVC.identifier) as? CalendarVC {
            
            calendarVC.dateDelegate = self
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
            present(calendarVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        saveTransaction()

    }
    
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
}

//MARK: - Extensions
extension AddTransactionVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == amountTextField {
            addAmountFieldAccessory()
        } else if textField == descriptionTextField {
            addDescriptionFieldAccessory()
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == descriptionTextField {
            
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
        
        transactionName = subcategory.subCategoryName
        categoryButton.setTitle(subcategory.subCategoryName, for: .normal)
        descriptionTextField.becomeFirstResponder()
        
        setCategoryNameAndColor()

        
        if categoryPicked?.categoryName == "Income" {
            amountTextField.dropMinus()
            isExpense = false
            amountTextField.textColor = UIColor(rgb: SystemColors.shared.green)
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
        displayRepeatInterval(with: date)
    }
    func getRepeatInterval(interval: String) {
        repeatInterval = interval
//        repeatButton.setTitle("Repeats: \(repeatInterval)", for: .normal)
        displayRepeatInterval(with: datePicked)
    }
}


