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
    
    let realm = try! Realm()
    
    let addItemVC = AddTransactionViewController()
    
    let transactionName = "Starbucks"
    let transactionAmount = 3.45
    let transactionDate = Date()
    let transactionDescription = "That was a good coffee"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.firstVC = self

        
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        
        self.title = "Transactions"
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return realm.objects(Transaction.self).count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90
        
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
    
//    func dateFormat(_ cell: TransactionTableViewCell) -> String {
//
//
//        return
//    }
}
