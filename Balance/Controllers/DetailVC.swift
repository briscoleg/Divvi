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
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteRepeatButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let realm = try! Realm()
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    
    var transaction: Transaction?
    
    
    //    var transaction: Results<Transaction>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionEdited"), object: nil)
        
        deleteRepeatButton.roundCorners()
        
        editButton.roundCorners()
        displayTransactionInfo()
        
    }
    
    @objc func refresh() {
        displayTransactionInfo()
    }
    
    private func displayTransactionInfo() {
        
        subCategoryLabel.text = transaction?.transactionSubCategory?.subCategoryName
        
        if transaction?.transactionDescription == nil {
            descriptionLabel.isHidden = true
        } else {
            descriptionLabel.text = transaction?.transactionDescription
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
            amountLabel.textColor = UIColor(rgb: SystemColors.green)
        } else if number < 0 {
            amountLabel.textColor = UIColor(rgb: SystemColors.red)
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
        
        vc.newTransaction = false
        
        vc.amount = transaction!.transactionAmount
        
        vc.datePicked = transaction!.transactionDate
        
        vc.repeatInterval = transaction!.repeatInterval
        
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
        
        let alert = UIAlertController(title: "Delete All Future \(transaction!.transactionSubCategory!.subCategoryName) Transactions?", message: "", preferredStyle: .alert)
        
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
            textColor = UIColor(rgb: SystemColors.green)
        } else if number < 0 {
            textColor = UIColor(rgb: SystemColors.red)
        }
        return textColor
    }
}
