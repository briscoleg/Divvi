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
    
    //MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteRepeatButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK: - Properties
    static let identifier = "DetailVC"
    
    let realm = try! Realm()
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    
    var transaction: Transaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteRepeatButton.roundCorners()
        
        editButton.roundCorners()
        displayTransactionInfo()
        
        configureObservers()
        
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionEdited"), object: nil)
    }
    
    @objc func refresh() {
        displayTransactionInfo()
    }
    
    private func displayTransactionInfo() {
        
        if let transaction = transaction {
            
            displayTransactionAmount(transaction.transactionAmount)
            displayTransactionDate(transaction.transactionDate)
            subCategoryLabel.text = transaction.transactionName
            repeatLabel.text = "Repeats: \(transaction.repeatInterval)"
            
            if transaction.transactionDescription == nil {
                descriptionLabel.isHidden = true
            } else {
                descriptionLabel.text = transaction.transactionDescription
            }
            
            if transaction.repeatInterval == "Never" {
                deleteRepeatButton.isHidden = true
            }

        }
        
    }
    
    private func displayTransactionAmount (_ number: Double) {

        if number > 0 {
            amountLabel.textColor = UIColor(rgb: SystemColors.shared.green)
        } else if number < 0 {
            amountLabel.textColor = UIColor(rgb: SystemColors.shared.red)
        }

        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency

        let formattedNumber = formatter.string(from: NSNumber(value: abs(number)))

        amountLabel.text = formattedNumber

    }
    
    private func displayTransactionDate (_ date: Date) {
        
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
        
//        vc.amount = transaction!.transactionAmount
        
//        vc.datePicked = transaction!.transactionDate
        
//        vc.repeatInterval = transaction!.repeatInterval
        
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
        
        let alert = UIAlertController(title: "Delete All Future \(transaction!.transactionName) Transactions?", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
//            let futureRecurringTransactions = self.transactions.filter(NSPredicate(format: "transactionDescription == %@ && transactionDate >= %@ && transactionCategory == %@", self.transaction!.transactionDescription!, self.transaction!.transactionDate as NSDate, self.transaction!.transactionCategory!))
            if let transactionsToDelete = self.transaction {
                do {
                    try self.realm.write {
                        self.realm.delete(self.transactions.filter(.futureRepeats(of: transactionsToDelete)))
                    }
                } catch {
                    print("Error deleting future transactions: \(error)")
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
            textColor = UIColor(rgb: SystemColors.shared.green)
        } else if number < 0 {
            textColor = UIColor(rgb: SystemColors.shared.red)
        }
        return textColor
    }
}
