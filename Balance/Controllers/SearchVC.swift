//
//  TransactionListTableViewController.swift
//  Balance
//
//  Created by Bo on 6/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class SearchVC: UIViewController, UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
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
        
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        
        transactionTableView.rowHeight = 90.0
        
        DataManager.shared.firstVC = self
        
        transactionTableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        
        //Hide Nav Bar Line
        navigationBar.setValue(true, forKey: "hidesShadow")
        navigationBar.topItem?.title = "Transactions"
        
        searchBar.backgroundColor = .clear
    }
    
    
    
    func setupRealm() {
        
        transaction = realm.objects(Transaction.self)
        
    }
    
    
    func deleteTransaction(index: Int) {
        
        try! realm.write {
            realm.delete(transaction)
            self.transactionTableView.reloadData()
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transaction.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
                        
            try! realm.write {
                realm.delete(transaction[indexPath.row])
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                
            }
        }
        DataManager.shared.summaryVC.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        let transactions = realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true)[indexPath.row]

        
        vc.transaction = transactions

        present(vc, animated: true, completion: nil)
        
//        DataManager.shared.summaryVC.viewDidLoad()
        
//        performSegue(withIdentifier: "DetailSegue", sender: self)
        

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
                        
            try! realm.write {
                realm.delete(transaction[indexPath.row])
                                
        }
        DataManager.shared.summaryVC.viewDidLoad()
        
        let deleteAction = UIContextualAction(style: .normal, title: "", handler: {a,b,c in

            tableView.deleteRows(at: [indexPath], with: .automatic)
        })

        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor(rgb: Constants.red)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell

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

        return cell
    }

    
}





