//
//  StartingBalanceVC.swift
//  Balance
//
//  Created by Bo LeGrand on 11/14/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

class StartingBalanceVC: UIViewController {
    
    static let identifier = "StartingBalanceVC"

    //MARK: - IBOutlets
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var dateAndAmountLabel: UILabel!
    @IBOutlet weak var setBalanceButton: UIButton!
    
    //MARK: - Properties
    private let userDefaults = UserDefaults()
    private let realm = try! Realm()
    
    var startingBalanceAmount = 0.0
    var startingBalanceDate = Date()
    
    private let amountFieldAccessory: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemGray4
        view.alpha = 0.8
        return view
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(UIColor.link, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        return button
    }()

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDelegates()
        configureUI()
        hideKeyboardOnTap()
        setCalendarScrollDirection()

        addAmountFieldAccessory()
    }
    
    //MARK: - Methods
    
    private func setCalendarScrollDirection() {
        if userDefaults.value(forKey: "calendarScrollDirection") as! String == "horizontal" {
            calendarView.scrollDirection = .horizontal
        } else if userDefaults.value(forKey: "calendarScrollDirection") as! String == "vertical" {
            calendarView.scrollDirection = .vertical
        }
    }
    
    private func configureDelegates() {
        calendarView.delegate = self
        calendarView.dataSource = self
        amountTextField.delegate = self
    }
    
    private func configureUI() {
        setBalanceButton.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
        setBalanceButton.roundCorners()
        
        amountTextField.becomeFirstResponder()
                
    }
    
    private func updateStartingBalance(with date: Date) {
        
        startingBalanceDate = date

        dateAndAmountLabel.text = startingBalanceDate.toString(style: .long)
    }
    
    private func setStartingBalance() {
        
        guard amountTextField.text != "" else { amountTextField.placeholder = "Enter an amount"; return }
        
        let startingBalance = StartingBalance()
        
        startingBalance.amount = startingBalanceAmount
        startingBalance.date = startingBalanceDate
        do {
            try realm.write {
                realm.add(startingBalance)
            }
        } catch {
            print("Error saving starting balance: \(error)")
        }
        
        let transactionsBeforeStartingBalance = realm.objects(Transaction.self).filter(NSPredicate(format: "transactionDate < %@", startingBalanceDate as CVarArg))
        do {
            try realm.write {
                realm.delete(transactionsBeforeStartingBalance)
            }
        } catch {
            print("Error deleting transactions before starting balance: \(error)")
        }
        userDefaults.setValue(true, forKey: "startingBalanceSet")
        NotificationCenter.default.post(name: (Notification.Name(rawValue: "startingBalanceSet")), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    private func addAmountFieldAccessory() {
        
        amountFieldAccessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        amountFieldAccessory.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        amountTextField.inputAccessoryView = amountFieldAccessory
        
        amountFieldAccessory.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            
            doneButton.trailingAnchor.constraint(equalTo: amountFieldAccessory.trailingAnchor, constant: -30),
            doneButton.centerYAnchor.constraint(equalTo: amountFieldAccessory.centerYAnchor),
            
        ])
    }
    
    //MARK: - IBActions
    @IBAction func setBalanceButtonPressed(_ sender: UIButton) {
        
        if realm.objects(Transaction.self).count == 0 {
            setStartingBalance()
        } else {
            let alert = UIAlertController(title: "All transactions before this date will be deleted", message: "", preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title: "Set Starting Balance", style: .destructive) { [self] (action) in
                setStartingBalance()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            }
            alert.addAction(action)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    @objc private func doneButtonTapped() {
        amountTextField.resignFirstResponder()
        dateAndAmountLabel.text = startingBalanceDate.toString(style: .long)
        amountTextField.text = startingBalanceAmount.toCurrency()
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

//MARK: - FSCalendar Delegate, DataSource, & Appearance
extension StartingBalanceVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        updateStartingBalance(with: date)
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
                
        calendar.appearance.todayColor = UIColor(rgb: SystemColors.shared.yellow)
        
        calendar.appearance.selectionColor = UIColor(rgb: SystemColors.shared.blue)
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return .label
    }
}

//MARK: - TextField Delegate
extension StartingBalanceVC: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        startingBalanceAmount = textField.text!.toDouble()
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        amountTextField.text = startingBalanceAmount.toCurrency()

    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == amountTextField {
            if let text = textField.text {
                let dotString = "."
                let backSpace = string.isEmpty
                if !backSpace {
                    if text.contains(dotString) {
                        if text.components(separatedBy: dotString)[1].count == 2 || string == "." {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
}

