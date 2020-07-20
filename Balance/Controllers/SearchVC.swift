//
//  TransactionListTableViewController.swift
//  Balance
//
//  Created by Bo on 6/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class SearchVC: UITableViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var realm = try! Realm()
    
    var transaction: Results<Transaction>!
    
    //    let delTransaction = self.realm.objects(Transaction.self)
    //        = { self.realm.objects(Transaction.self) }()
    
    let addItemVC = AddVC()
    
    var transactionName = ""
    var transactionAmount = 0.0
    var transactionDate = Date()
    var transactionDescription = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupRealm()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 90.0
        
        DataManager.shared.firstVC = self
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        
        self.title = "Transactions"
        
    }
    
    func setupRealm() {
        
        transaction = realm.objects(Transaction.self)
        
    }
    
    
    func deleteTransaction(index: Int) {
        
        try! realm.write {
            realm.delete(transaction)
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transaction.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
                        
            try! realm.write {
                realm.delete(transaction[indexPath.row])
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                
            }
        }
        DataManager.shared.summaryVC.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        let t = transaction[indexPath.row]
        
        vc.transaction = t

        present(vc, animated: true, completion: nil)
        
//        DataManager.shared.summaryVC.viewDidLoad()
        
//        performSegue(withIdentifier: "DetailSegue", sender: self)
        

    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
                        
            try! realm.write {
                realm.delete(transaction[indexPath.row])
                
//                tableView.deleteRows(at: [indexPath], with: .automatic)
                
        }
        DataManager.shared.summaryVC.viewDidLoad()
        
        let deleteAction = UIContextualAction(style: .normal, title: "", handler: {a,b,c in
            // example of your delete function
//            self.YourArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })

        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor(rgb: Constants.red)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        
//        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
//        
//        let realm = try! Realm(configuration: config)
        let transactions = realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true)
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        let realmTransactionDate = transactions[indexPath.row].transactionDate
        
        let dateString = formatter.string(from: realmTransactionDate)
        
        cell.dateLabel.text = dateString
        
        cell.nameLabel.text = transactions[indexPath.row].transactionName
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let number = currencyFormatter.string(from: NSNumber(value: transactions[indexPath.row].transactionAmount))
        
        let mutableAttributedString = NSMutableAttributedString(string: number!)
        if let range = mutableAttributedString.string.range(of: #"(?<=.)(\d{2})$"#, options: .regularExpression) {
            mutableAttributedString.setAttributes([.font: UIFont.systemFont(ofSize: 9), .baselineOffset: 6],
                range: NSRange(range, in: mutableAttributedString.string))
        }
        
        cell.amountLabel.attributedText = mutableAttributedString
        
        if transactions[indexPath.row].transactionAmount > 0 {
            
            
            cell.amountLabel.textColor = UIColor(rgb: Constants.green)
            cell.valueView.backgroundColor = UIColor(rgb: Constants.green)
        } else {
            cell.amountLabel.textColor = UIColor(rgb: Constants.red)
            cell.valueView.backgroundColor = UIColor(rgb: Constants.red)
        }
        
        
                
//        cell.descriptionLabel.text = transactions[indexPath.row].transactionDescription
        
        return cell
    }

    
}





