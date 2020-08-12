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

class Add2VC: UIViewController {
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    let accessory: UIView = {
        let accessoryView = UIView(frame: .zero)
        accessoryView.backgroundColor = UIColor(red: 204, green: 207, blue: 214)
        accessoryView.alpha = 0.8
        return accessoryView
    }()
    
    let keyboardDismissButton: UIButton = {
        
        let keyboardDismissButton = UIButton(type: .custom)
        keyboardDismissButton.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        //        keyboardDismissButton.setBackgroundImage(UIImage(systemName: "keyboard"), for: .normal)
        keyboardDismissButton.addTarget(self, action: #selector(keyboardDismissButtonTapped), for: .touchUpInside)
        keyboardDismissButton.showsTouchWhenHighlighted = true
        return keyboardDismissButton
        
    }()
    
    let plusMinusButton: UIButton = {
        let plusMinusButton = UIButton(type: .custom)
        plusMinusButton.setTitle("+/-", for: .normal)
        plusMinusButton.setTitleColor(UIColor.link, for: .normal)
        plusMinusButton.addTarget(self, action:
            #selector(plusMinusButtonTapped), for: .touchUpInside)
        plusMinusButton.showsTouchWhenHighlighted = true
        return plusMinusButton
    }()
    
    let nextAccessoryButton: UIButton! = {
        let nextAccessoryButton = UIButton(type: .custom)
        nextAccessoryButton.setTitleColor(.link, for: .normal)
        nextAccessoryButton.setTitle("Continue", for: .normal)
        nextAccessoryButton.setTitleColor(.white, for: .disabled)
        nextAccessoryButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextAccessoryButton.showsTouchWhenHighlighted = true
        nextAccessoryButton.isEnabled = true
        return nextAccessoryButton
    }()
    
    let realm = try! Realm()
    
    var amount = 0.0
    var categoryPicked: Category?
    var datePicked = Date()
    var repeatInterval = "Never"
    var isExpense = true
    var numberOfTransactionsToAdd = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.delegate = self
        
        amountTextField.becomeFirstResponder()
        
        addAccessory()
        
        saveButton.roundCorners()
        
    }
    
    //Methods
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
                numberOfTransactionsToAdd = 3
            case "Monthly":
                numberOfTransactionsToAdd = 12
            case "Every Two Weeks":
                numberOfTransactionsToAdd = 24
            case "Every Week":
                numberOfTransactionsToAdd = 5
            case "Every Day":
                numberOfTransactionsToAdd = 4
            case "Never":
                numberOfTransactionsToAdd = 1
            default:
                break
            }
        }
        
        func saveTransaction() {
            
            setNumberOfTransactions()
            
            for _ in 1...numberOfTransactionsToAdd {
                
                let newTransaction = Transaction()
                
                var timeAdded = 1.months
                
                convertAmountToCurrency()

                newTransaction.transactionAmount = amount
                newTransaction.transactionDescription = descriptionTextField.text
                newTransaction.transactionDate = datePicked
                newTransaction.transactionCategory = categoryPicked
                newTransaction.repeatInterval = repeatInterval
                
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
                try! realm.write {
                    realm.add(newTransaction)
                }
                
                datePicked = datePicked + timeAdded
            }
                        
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        func displayRepeatInterval(_ date: Date) {
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MMMM d"
            
            let dateString = formatter.string(from: date)
            
            if repeatInterval == "Never" {
                dateButton.setTitle("Starts \(dateString)", for: .normal)

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
            dateButton.setTitle("Date: \(dateString)", for: .normal)
        }
        
    }
    
    @objc func plusMinusButtonTapped() {
        
        if isExpense {
            amountTextField.dropMinus()
            isExpense = false
        } else {
            amountTextField.addMinus()
            isExpense = true
        }
        
    }
    
    func addAccessory() {
        
        accessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
        accessory.translatesAutoresizingMaskIntoConstraints = false
        keyboardDismissButton.translatesAutoresizingMaskIntoConstraints = false
        nextAccessoryButton.translatesAutoresizingMaskIntoConstraints = false
        plusMinusButton.translatesAutoresizingMaskIntoConstraints = false
        
        amountTextField.inputAccessoryView = accessory
        
        accessory.addSubview(keyboardDismissButton)
        accessory.addSubview(plusMinusButton)
        accessory.addSubview(nextAccessoryButton)
        
        NSLayoutConstraint.activate([
            
            keyboardDismissButton.leadingAnchor.constraint(equalTo:
            accessory.leadingAnchor, constant: 30),
            keyboardDismissButton.centerYAnchor.constraint(equalTo:
            accessory.centerYAnchor),
            
//            keyboardDismissButton.centerXAnchor.constraint(equalTo: accessory.leadingAnchor, constant: 40),
//            keyboardDismissButton.centerYAnchor.constraint(equalTo: accessory.centerYAnchor),
            
            plusMinusButton.centerXAnchor.constraint(equalTo:
                accessory.centerXAnchor),
            plusMinusButton.centerYAnchor.constraint(equalTo:
                accessory.centerYAnchor),
            
            nextAccessoryButton.trailingAnchor.constraint(equalTo: accessory.trailingAnchor, constant: -30),
            nextAccessoryButton.centerYAnchor.constraint(equalTo: accessory.centerYAnchor),
            
        ])
    }
    
    //IBActions
    
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
        
        let recurringVC = storyboard?.instantiateViewController(withIdentifier: "RecurringViewController") as! RepeatVC
        
        recurringVC.repeatDelegate = self
        
        present(recurringVC, animated: true, completion: nil)
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        //Add required amount and category perameters
        saveTransaction()
        
    }
    
    
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
}


extension Add2VC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let dotString = "."
        let dollarSign = "$"
        let minusSign = "-$"
        
        
        if let text = textField.text{
            
            
            
            print(text)
            
            if !text.contains(dollarSign) && isExpense {
                textField.text = "-\(dollarSign)\(text)"
            }
            if !text.contains(dollarSign) && !isExpense {
                textField.text = "\(dollarSign)\(text)"
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
extension Add2VC: CategoryDelegate {
    func getCategory(from category: Category) {
        categoryPicked = category
//        categoryPicked?.categoryName = category.categoryName
        categoryButton.setTitle("Category: \(categoryPicked!.categoryName)", for: .normal)
    }
}

extension Add2VC: RepeatDelegate {
    func getRepeatInterval(interval: String) {
        repeatInterval = interval
        repeatButton.setTitle("Repeats: \(repeatInterval)", for: .normal)
    }
}

extension Add2VC: DateDelegate {
    func getCalendarDate(from date: Date) {
        datePicked = date
        displaySelectedDate(date)
//        displaySelectedInterval(date)
    }
}

