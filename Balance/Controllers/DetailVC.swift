//
//  DetailViewController.swift
//  Balance
//
//  Created by Bo on 7/14/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift



class DetailVC: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteRepeatButton: UIButton!
    
    let realm = try! Realm()
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()

    var transaction: Transaction?
    
    
//    var transaction: Results<Transaction>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        
        deleteRepeatButton.roundCorners()
                
        editButton.roundCorners()
        displayTransactionInfo()
        
    }
    
    @objc func refresh() {
        displayTransactionInfo()
    }
    
    func displayTransactionInfo() {
        
        if transaction?.transactionDescription == "" {
            descLabel.text = "(not named)"
        } else {
        descLabel.text = transaction?.transactionDescription
        }
        repeatLabel.text = "Repeats: \(transaction!.repeatInterval)"
        
        if transaction?.repeatInterval == "Never" {
            deleteRepeatButton.isHidden = true
        }
            
        
        formatNumber(transaction!.transactionAmount)
        formatDate(transaction!.transactionDate)
        
    }
    
    func formatNumber (_ number: Double) {
        
        if number > 0 {
            amountLabel.textColor = UIColor(rgb: Constants.green)
        } else if number < 0 {
            amountLabel.textColor = UIColor(rgb: Constants.red)
        }
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        
        let formattedNumber = formatter.string(from: NSNumber(value: abs(number)))
        
        amountLabel.text = formattedNumber
        
    }
    
    func formatDate (_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "EEEE\nMMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        
        dateLabel.text = dateString
                
    }

    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddTransactionVC") as! AddTransactionVC
                
        vc.transaction = transaction
        
        vc.amount = transaction!.transactionAmount
        
//        vc.amountTextField.text = String(transaction!.transactionAmount)
        
//        print(transaction?.transactionAmount)
        
        present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
                
        let alert = UIAlertController(title: "Delete Transaction?", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                        
            if let transactionToDelete = self.transaction {
            
            try! self.realm.write {
                self.realm.delete(transactionToDelete)
                }
                
            }

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
            self.dismiss(animated: true, completion: nil)
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
//            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
                
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func repeatDeletePressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Delete All Future Repeating Transactions?", message: "", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                                
                    let futureRecurringTransactions = self.transactions.filter(NSPredicate(format: "transactionDescription == %@ && transactionDate >= %@ && transactionCategory == %@", self.transaction!.transactionDescription!, self.transaction!.transactionDate as CVarArg, self.transaction!.transactionCategory!))
                    
                    for transaction in futureRecurringTransactions {
                        try! self.realm.write {
                            self.realm.delete(transaction)
                        }
                    }

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                    
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
        //            self.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(action)
                alert.addAction(cancelAction)
                        
                self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
}

extension UILabel {
    func colorCode(number: Double) -> UIColor{
        if number > 0 {
            textColor = UIColor(rgb: Constants.green)
        } else if number < 0 {
            textColor = UIColor(rgb: Constants.red)
        }
        return textColor
    }
}
