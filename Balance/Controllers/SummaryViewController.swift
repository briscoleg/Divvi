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
    
    //MARK: - IBOutlets
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    //MARK: - Properties
    let realm = try! Realm()
    var transaction: Results<Transaction>?
    let addItemVC = AddTransactionViewController()
    let date = Date()
    let nsDate = Date()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        
        DataManager.shared.summaryVC = self
        
                print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        totalTransactions()
        
    }
    //MARK: - Methods
    func totalTransactions() {
        
        let transactionsTotal: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", date).sum(ofProperty: "transactionAmount")
        
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.locale = Locale.current

        let transactionTotalString = formatter.string(from: NSNumber(value: transactionsTotal))

        amountLabel.text = transactionTotalString
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
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

//MARK: - Extensions
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
