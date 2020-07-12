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

protocol CVarArg {
    }
class SummaryViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionsLabel: UILabel!
    
    //MARK: - Properties
    let realm = try! Realm()
    var transaction: Results<Transaction>!
    let addItemVC = AddTransactionViewController()
    var selectedCalendarDate = Date()
    var predicate = NSPredicate()
    var dateTappedOnCalendar = Date()
    let todaysDate = Date()
    var startDate: Date?
    var endDate: Date?
    var dateRangePredicate = NSPredicate()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataManager.shared.summaryVC = self
        
        tableView.rowHeight = 40
        
        setupRealm()
                                
        getTotalAtDate(Date())
        
        dateRangePredicate = predicateForDayFromDate(date: todaysDate)
        
        calendar.collectionView.reloadData()
        
        tableView.reloadData()
        
        tableView.register(UINib(nibName: "SummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "SummaryTableViewCell")
        
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        
    }
    //MARK: - Methods
    
    func setupRealm() {
        
        transaction = realm.objects(Transaction.self)
        
    }
    
    func getTotalAtDate(_ date: Date) {
        
        let transactionsTotalAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", date).sum(ofProperty: "transactionAmount")
        
        let formattedLabel = formatDoubleToCurrencyString(from: transactionsTotalAtDate)
        
        amountLabel.text = formattedLabel
                
    }
    
    func formatDoubleToCurrencyString(from number: Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        
        let formattedNumber = formatter.string(from: NSNumber(value: number))
        
        return formattedNumber!
        
    }
    
    func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM d"
        
        let dateString = formatter.string(from: date)
        
        dateLabel.text = dateString
                
    }
    func predicateForDayFromDate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)

        return NSPredicate(format: "transactionDate >= %@ AND transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }
    
    //MARK: - Calendar Methods
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        getTotalAtDate(date + 61199)
        
        displaySelectedDate(date)
        
        dateRangePredicate = predicateForDayFromDate(date: date)
        
        tableView.reloadData()
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {


        let results = realm.objects(Transaction.self).filter("transactionDate == %@ && transactionAmount > 0", date)

        for _ in results {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
            cell.appearance.eventDefaultColor = .green
           
}
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let transactionCount = transaction.filter(dateRangePredicate).count
        
        if transactionCount == 0 {
            transactionsLabel.text = "No transactions for this date."
        } else {
            transactionsLabel.text = "Transactions:"
        }
        return transactionCount
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as! SummaryTableViewCell
                
        let transactions = realm.objects(Transaction.self).filter(dateRangePredicate)
            
//            "transactionDate >= %@ && transactionDate >= %@", startDate!, endDate!)
                
        cell.nameLabel.text = transactions[indexPath.row].transactionName
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let number = currencyFormatter.string(from: NSNumber(value: transactions[indexPath.row].transactionAmount))
        
        cell.amountLabel.text = number
                
        return cell
        
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

//extension Date {
//    var startOfDay: Date {
//        return Calendar.current.startOfDay(for: self)
//    }
//
//    var endOfDay: Date {
//        var components = DateComponents()
//        components.day = 1
//        components.second = -1
//        return Calendar.current.date(byAdding: components, to: startOfDay)!
//    }
//
//    var startOfMonth: Date {
//        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
//        return Calendar.current.date(from: components)!
//    }
//
//    var endOfMonth: Date {
//        var components = DateComponents()
//        components.month = 1
//        components.second = -1
//        return Calendar.current.date(byAdding: components, to: startOfMonth)!
//    }
//}

//extension Date{
//
//func makeDayPredicate() -> NSPredicate {
//    let calendar = Calendar.current
//    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
//    components.hour = 00
//    components.minute = 00
//    components.second = 00
//    let startDate = calendar.date(from: components)
//    components.hour = 23
//    components.minute = 59
//    components.second = 59
//    let endDate = calendar.date(from: components)
//    return NSPredicate(format: "transactionDate >= %@ AND transactionDate =< %@", argumentArray: [startDate!, endDate!])
//}
//}
