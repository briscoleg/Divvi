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

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegates()
        configureUI()
        
        setupHideKeyboardOnTap()

    }
    
    //MARK: - Methods
    private func setDelegates() {
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

        dateAndAmountLabel.text = " Starting Balance:\n\n\(startingBalanceAmount.toCurrency())\n \(startingBalanceDate.toString(style: .long))"
    }
    
    private func saveTransaction() {
        
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
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - IBActions
    @IBAction func setBalanceButtonPressed(_ sender: UIButton) {
        
        saveTransaction()
        userDefaults.setValue(true, forKey: "startingBalanceSet")
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK: - FSCalendar Delegate & DataSourc
extension StartingBalanceVC: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        updateStartingBalance(with: date)
    }
}

//MARK: - TextField Delegate
extension StartingBalanceVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        startingBalanceAmount = textField.text!.toDouble()

//        amountTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = amountTextField {
            
        }
    }
}
