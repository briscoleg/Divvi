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

class BalanceVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionsLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var todayButton: UIButton!
    
    
    //MARK: - Properties
    let realm = try! Realm()
    var transaction: Results<Transaction>!
    let addItemVC = AddVC()
    var selectedCalendarDate = Date()
    var dateTappedOnCalendar = Date()
    let todaysDate = Date()
    var startDate: Date?
    var endDate: Date?
    var dateRangePredicate = NSPredicate()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()

    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        calendar.delegate = self
        calendar.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        todayButton.makeCircular()
        
        if categories.count == 0 {
        tabBarController!.tabBar.items![2].badgeValue = "1"
        }

        
        //Hide Nav Bar Line
        navigationBar.setValue(true, forKey: "hidesShadow")
        
        
        let todayItem = UIBarButtonItem(title: "TODAY", style: .plain, target: self, action: #selector(self.todayItemClicked(sender:)))
        self.navigationItem.rightBarButtonItem = todayItem
        DataManager.shared.summaryVC = self
        
        tableView.rowHeight = 40
        
        setupRealm()
        
        getTotalAtDate(Date())
        
        dateRangePredicate = predicateForDayFromDate(date: todaysDate)
        
        calendar.collectionView.reloadData()
        
        tableView.reloadData()
        
        tableView.register(UINib(nibName: "SummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "SummaryTableViewCell")
        
    }
    //MARK: - Methods
    @objc
       func todayItemClicked(sender: AnyObject) {
           self.calendar.setCurrentPage(Date(), animated: false)
       }
    
    func setupRealm() {
        
        transaction = realm.objects(Transaction.self)
        
    }
    
    func getTotalAtDate(_ date: Date) {
        
        let transactionsTotalAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", date).sum(ofProperty: "transactionAmount")
        
        let formattedLabel = transactionsTotalAtDate.toCurrency()
        
        let mutableAttributedString = NSMutableAttributedString(string: formattedLabel)
        if let range = mutableAttributedString.string.range(of: #"(?<=.)(\d{2})$"#, options: .regularExpression) {
            mutableAttributedString.setAttributes([.font: UIFont.systemFont(ofSize: 40, weight: .ultraLight), .baselineOffset: 25],
                                                  range: NSRange(range, in: mutableAttributedString.string))
        }
        
        amountLabel.attributedText = mutableAttributedString
        
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
        
        formatter.dateFormat = "MMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        
        if dateString == formatter.string(from: Date()) {
            dateLabel.text = "Today"
        } else {
            dateLabel.text = dateString
        }
        
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
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }
    
    func negativeTransactionPredicate(date: Date) -> NSPredicate {
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
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount < 0", argumentArray: [startDate!, endDate!])
    }
    
    func positiveTransactionPredicate(date: Date) -> NSPredicate {
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
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount > 0", argumentArray: [startDate!, endDate!])
    }
    
    func positiveAndNegativeTransactionPredicate(date: Date) -> NSPredicate {
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
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount > 0 && transactionAmount < 0", argumentArray: [startDate!, endDate!])
    }
    
    //MARK: - IBActions
    @IBAction func todayPressed(_ sender: UIButton) {
        
        calendar.setCurrentPage(Date(), animated: true)
        
        calendar.select(calendar.today)
        
        displaySelectedDate(Date())
        
        getTotalAtDate(Date() + 61199)
        
        dateRangePredicate = predicateForDayFromDate(date: Date())
        
        tableView.reloadData()
    }
    
    //MARK: - Calendar Methods
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        getTotalAtDate(date + 61199)
        
        displaySelectedDate(date)
        
        dateRangePredicate = predicateForDayFromDate(date: date)
        
        tableView.reloadData()
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let incomeTransaction = realm.objects(Transaction.self).filter(positiveTransactionPredicate(date: date))

        let expenseTransaction = realm.objects(Transaction.self).filter(negativeTransactionPredicate(date: date))

        for _ in incomeTransaction {
            return 1
        }
        for _ in expenseTransaction {
            return 1
        }

        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        let incomeTransaction = realm.objects(Transaction.self).filter(positiveTransactionPredicate(date: date))
        
        let expenseTransaction = realm.objects(Transaction.self).filter(negativeTransactionPredicate(date: date))
        
        for _ in incomeTransaction {
            return [UIColor(rgb: Constants.green)]
        }
        for _ in expenseTransaction {
            return [UIColor(rgb: Constants.red)]
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        cell.appearance.eventDefaultColor = UIColor(rgb: Constants.green)
        
        calendar.appearance.todayColor = UIColor(rgb: Constants.yellow)
        
        calendar.appearance.selectionColor = UIColor(rgb: Constants.blue)
        
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
                
        cell.nameLabel.text = transactions[indexPath.row].transactionName
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let amount = currencyFormatter.string(from: NSNumber(value: transactions[indexPath.row].transactionAmount))
        
        cell.amountLabel.text = amount
                
        if transactions[indexPath.row].transactionAmount > 0 {
            
            cell.amountLabel.textColor = UIColor(rgb: Constants.green)
        } else {
            cell.amountLabel.textColor = UIColor(rgb: Constants.red)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        let transactions = realm.objects(Transaction.self).filter(dateRangePredicate)[indexPath.row]
        
        vc.transaction = transactions
        
        present(vc, animated: true, completion: nil)
    }
    
    
}
