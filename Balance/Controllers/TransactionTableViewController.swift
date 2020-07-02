//
//  TransactionListTableViewController.swift
//  Balance
//
//  Created by Bo on 6/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class TransactionTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var transaction: Results<Transaction>!
//        = { self.realm.objects(Transaction.self) }()
        
    let addItemVC = AddTransactionViewController()
    
    var transactionName = ""
    var transactionAmount = 0.0
    var transactionDate = Date()
    var transactionDescription = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        sortData()
        
        tableView.delegate = self
        tableView.dataSource = self
                
        tableView.rowHeight = 120.0
        
        DataManager.shared.firstVC = self
   
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        
        self.title = "Transactions"

    }
    
    func sortData() {
        
        transaction = realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true)
        
        self.tableView.reloadData()
        
        
    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return realm.objects(Transaction.self).count
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
                
        let transactions = realm.objects(Transaction.self)
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM dd, yyyy"
        
        let realmTransactionDate = transactions[indexPath.row].transactionDate
        
        let dateString = formatter.string(from: realmTransactionDate)
        
        cell.dateLabel.text = dateString
        
        cell.nameLabel.text = transactions[indexPath.row].transactionName
        
        cell.amountLabel.text = String(format: "$%.2f", transactions[indexPath.row].transactionAmount)
        
        cell.descriptionLabel.text = transactions[indexPath.row].transactionDescription
        
        return cell
    }

}
