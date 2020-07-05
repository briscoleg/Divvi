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
    
    lazy var realm = try! Realm()
    
    var transaction: Results<Transaction>!
//    let delTransaction = self.realm.objects(Transaction.self)
//        = { self.realm.objects(Transaction.self) }()
        
    let addItemVC = AddTransactionViewController()
    
    var transactionName = ""
    var transactionAmount = 0.0
    var transactionDate = Date()
    var transactionDescription = ""
    let darkRed = 0xD93D24
    let darkGreen = 0x59C13B
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        tableView.delegate = self
        tableView.dataSource = self
                
        tableView.rowHeight = 120.0
        
        DataManager.shared.firstVC = self
   
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        
        self.title = "Transactions"
        
    }
    
//    func deleteTran(_ transaction: Transaction.Type) {
//    do {
//        let realm = try! Realm()
//        try realm.write {
//            realm.delete(transaction)
//        }
//    } catch {
//        print(error)
//    }
//    }
    
    func deleteTransaction(index: Int) {
        
            try! realm.write {
                realm.delete(transaction)
                self.tableView.reloadData()
            }
        }
        
    
//    func retrieveTransactions() {
//        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
//
//        let realm = try! Realm(configuration: config)
//        transaction = realm.objects(Transaction.self).sorted(byKeyPath: "name", ascending: true)
//    }
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return realm.objects(Transaction.self).count
        return transaction?.count ?? 1
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
                
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        
        let realm = try! Realm(configuration: config)
        let transactions = realm.objects(Transaction.self).sorted(byKeyPath: "transactionDate", ascending: true)
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM dd, yyyy"
        
        let realmTransactionDate = transactions[indexPath.row].transactionDate
        
        let dateString = formatter.string(from: realmTransactionDate)
        
        cell.dateLabel.text = dateString
        
        cell.nameLabel.text = transactions[indexPath.row].transactionName
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current

        let number = currencyFormatter.string(from: NSNumber(value: transactions[indexPath.row].transactionAmount))

        cell.amountLabel.text = number
        
        if transactions[indexPath.row].transactionAmount > 0 {
            
            
            cell.amountLabel.textColor = UIColor(rgb: darkGreen)
            cell.valueView.backgroundColor = UIColor(rgb: darkGreen)
        } else {
            cell.amountLabel.textColor = UIColor(rgb: darkRed)
            cell.valueView.backgroundColor = UIColor(rgb: darkRed)
        }
            
//        cell.amountLabel.textColor = .blue
        
        cell.descriptionLabel.text = transactions[indexPath.row].transactionDescription
        
        return cell
    }

}
public extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
