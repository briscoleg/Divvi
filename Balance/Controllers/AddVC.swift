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

class AddVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var cancelButton: UIButton!

    //Amount View Outlets
    @IBOutlet weak var amountInstructionsLabel: UILabel!
    @IBOutlet weak var incomeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountNextButton: UIButton!
    
    //Name View Outlets
    @IBOutlet weak var nameInstructionsLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var nameNextButton: UIButton!
    @IBOutlet weak var nameBackButton: UIButton!

    //Date View Outlets
    @IBOutlet weak var dateInsructionsLabel: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var recursLabel: UILabel!
    @IBOutlet weak var recurringSwitch: UISwitch!
    @IBOutlet weak var dateAddTransactionButton: UIButton!
    @IBOutlet weak var dateBackButton: UIButton!
    
    
    //Stacks
    @IBOutlet weak var amountStackView: UIStackView!
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!
    
    
    
    //MARK: - Properties
    let realm = try! Realm()
    public var buttonCounter = 1
    var amount = 0.0
//    var name = ""
//    var desc: String?
    var datePicked = Date()
    var category = ""
    var isExpense = true
    var recurringInterval = "None"
    var numberOfTransactionsToAdd = 1
    var component: Int?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.delegate = self
        calendar.delegate = self
        calendar.dataSource = self
        
        title = "Add Transaction"
        
        setupAmountView()
        roundButtonCorners()
        
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
            saveTransaction()
        default:
            break
        }
        
    }
    
    func convertAmountToCurrency() {
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        let number = formatter.number(from: amountTextField.text!)
        let doubleValue = number?.doubleValue
        amount = doubleValue!
        
    }
    
    func roundButtonCorners() {
        
        amountNextButton.roundCorners()
        nameNextButton.roundCorners()
        dateAddTransactionButton.roundCorners()
        
    }
    
    func setupAmountView() {
        
        //Setup Stacks
        nameStackView.isHidden = true
        dateStackView.isHidden = true
        amountStackView.isHidden = false
        
        //Setup Instructions
        amountInstructionsLabel.text = "Amount:"

        
        //Setup Keyboard
        amountTextField.becomeFirstResponder()
        amountTextField.keyboardType = .decimalPad

        //Actions
        if isExpense {
            amountTextField.textColor = UIColor(rgb: Constants.red)
               }
        
    }
    
    func setupNameView() {
        
        amountTextField.reloadInputViews()

        //Setup Stacks
        dateStackView.isHidden = true
        amountStackView.isHidden = true
        nameStackView.isHidden = false
        
        //Setup Label
        nameInstructionsLabel.text = "Name:"
        
        //Setup Keyboard
        nameTextField.becomeFirstResponder()

        //Setup Instructions

    }
    
    func setupDateView() {
        
        //Setup Stacks
        amountStackView.isHidden = true
        nameStackView.isHidden = true
        dateStackView.isHidden = false
        
        //Setup Keyboard
        UIApplication.shared.hideKeyboard()

        //Setup Instructions
        
        amountInstructionsLabel.text = "Date:"
        recursLabel.text = "Repeat Transaction:"

    }
    
    func setNumberOfTransactions() {
        
        switch recurringInterval {
            
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
        case "Does Not Repeat":
            numberOfTransactionsToAdd = 1
        default:
            break
        }
        
    }
    
    func saveTransaction() {
        
        
        //        setTimeInterval()
        setNumberOfTransactions()
        
        for _ in 1...numberOfTransactionsToAdd {
            
            let newTransaction = Transaction()
            
            var timeAdded = 1.months
            
            convertAmountToCurrency()

            newTransaction.transactionAmount = amount
            newTransaction.transactionName = nameTextField.text!
            newTransaction.transactionDescription = descriptionTextField.text
            newTransaction.transactionDate = datePicked
            newTransaction.transactionCategory = category
            
            switch recurringInterval {
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
        
        DataManager.shared.firstVC.tableView.reloadData()
        DataManager.shared.summaryVC.viewDidLoad()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM d"
        
        let dateString = formatter.string(from: date)
        
        if recurringSwitch.isOn {
            dateInsructionsLabel.text = "Starts \(dateString)"

        } else {
            dateInsructionsLabel.text = dateString
        }
    }
    
    //MARK: - IBActions
    @IBAction func nextPressed(_ sender: UIButton) {
        
        
        if amountTextField.text == "" {
            amountTextField.placeholder = "Enter an amount"
        } else {
            buttonCounter += 1
        }
        
        setupViews()
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func incomeSegmentedControlPressed(_ sender: UISegmentedControl) {
        
        switch incomeSegmentedControl.selectedSegmentIndex {
            
        case 0:
            
            isExpense = true
            if isExpense && amountTextField.text != ""{
                amountTextField.addMinus()
            }
            amountInstructionsLabel.text = "Expense"
            amountTextField.textColor = UIColor(rgb: Constants.red)
            
        case 1:
            
            if isExpense {
                amountTextField.dropMinus()
            }
            isExpense = false
            
            amountInstructionsLabel.text = "Income"
            amountTextField.textColor = UIColor(rgb: Constants.green)
            
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
    
    @IBAction func recurringSwitchPressed(_ sender: UISwitch) {
        
        if recurringSwitch.isOn {
            let recurringVC = storyboard?.instantiateViewController(withIdentifier: "RecurringViewController") as! RepeatVC
            recurringVC.intervalDelegate = self
            present(recurringVC, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
                self.displaySelectedDate(self.datePicked)
            }
            
            
        } else {
            recurringInterval = "None"
            recursLabel.text = "Does not repeat"
            displaySelectedDate(datePicked)
            
        }
    }
    
    
    
    //MARK: - Calendar Delegate Methods
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        datePicked = date
        displaySelectedDate(date)
        
        
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
                                    
            calendar.appearance.todayColor = UIColor(rgb: Constants.yellow)
            
            calendar.appearance.selectionColor = UIColor(rgb: Constants.blue)
               
    }
    
}
//MARK: - Extensions

extension AddVC: IntervalDelegate {
    func getInterval(interval: String) {
        recurringInterval = interval
        recursLabel.text = "Repeats \(recurringInterval)"
    }
}
