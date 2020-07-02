//
//  ViewController.swift
//  Balance
//
//  Created by Bo on 6/22/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

class SummaryViewController: UIViewController, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let realm = try! Realm()
    
    var transaction: Results<Transaction>!
    
    let addItemVC = AddTransactionViewController()
    
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.summaryVC = self
        
        totalTransactions()
        
         print(Realm.Configuration.defaultConfiguration.fileURL!)
                
        calendar.delegate = self
            
        amountLabel.layer.shadowColor = UIColor.black.cgColor
        
    }
    
    func totalTransactions() {
        
        let transactionsTotal: Double = realm.objects(Transaction.self).sum(ofProperty: "transactionAmount")

        amountLabel.text = String(format: "$%.2f", transactionsTotal)
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
//        let transactionsDate = realm.objects(Transaction.self).filter("transactionDate < %@", date)
//
//        print(transactionsDate)
//        print(date)
        
        let adjustedDate = date.addingTimeInterval(17 * 60 * 60)
        
        let transactionsTotal: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", adjustedDate).sum(ofProperty: "transactionAmount")

        amountLabel.text = String(format: "$%.2f", transactionsTotal)
        
    }
    
    func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM dd, yyyy"

        let dateString = formatter.string(from: date)
        
        dateLabel.text = dateString
                        
    }
    
}

extension UIButton {
    func makeCircular(button: UIButton) {
        
        let button = UIButton()
        
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    button.layer.masksToBounds = false
    button.layer.shadowRadius = 2.0
    button.layer.shadowOpacity = 0.5
    button.layer.cornerRadius = button.frame.width / 2
    button.layer.borderColor = UIColor.black.cgColor
    button.layer.borderWidth = 1.0
    }
}
