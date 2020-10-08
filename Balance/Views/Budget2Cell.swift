//
//  Budget2Cell.swift
//  Balance
//
//  Created by Bo on 8/31/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift
import GTProgressBar

class Budget2Cell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var amountBudgetedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var rightArrowIconImageView: UIImageView!
    @IBOutlet weak var progressBar: GTProgressBar!
    
    //MARK: - Properties
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self)}()
    lazy var plannedTransactions: Results<Transaction> = { self.realm.objects(Transaction.self) }()
    
    var category: Category?
//    var selectedDate = Date()
    
    static let identifier = "PlanningCell"
    
    //MARK: - ViewDidLoad
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.textColor = .white
        amountSpentLabel.textColor = .white
        amountBudgetedLabel.textColor = .white
        rightArrowIconImageView.tintColor = .white
        imageView.tintColor = .white
        percentLabel.textColor = .white
        
        //        progressBar.labelPosition = .right
//        progressBar.cornerType = .rounded
        progressBar.cornerRadius = 20
//        progressBar.barBorderWidth = 0
//        progressBar.labelTextColor = .black
        
        
//        layer.shadowColor = UIColor.darkGray.cgColor
//        layer.cornerRadius = 0
        
        
        
    }
    
    //MARK: - Methods
//    func currentMonthPredicate(date: Date) -> NSPredicate {
//
//        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//
//        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: SelectedMonth.shared.date)
//
//        components.day = 01
//        components.hour = 00
//        components.minute = 00
//        components.second = 00
//
//        let startDate = calendar.date(from: components)
//
//        components.day = 31
//        components.hour = 23
//        components.minute = 59
//        components.second = 59
//
//        let endDate = calendar.date(from: components)
//
//        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
//    }
//
//    func predicateForMonthFromDate(date: Date) -> NSPredicate {
//
//        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//
//        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
//
//        components.day = 01
//        components.hour = 00
//        components.minute = 00
//        components.second = 00
//
//        let startDate = calendar.date(from: components)
//
//        components.day = Date().day
//        components.hour = 23
//        components.minute = 59
//        components.second = 59
//
//        let endDate = calendar.date(from: components)
//
//        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
//    }
    
    func configure(with indexPath: IndexPath) {
        
        nameLabel.text = categories[indexPath.item].categoryName
        imageView.image = UIImage(named: categories[indexPath.item].categoryName)
        
        progressBar.barFillColor = UIColor(rgb: categories[indexPath.item].categoryColor)
        progressBar.barBackgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor).withAlphaComponent(0.55)
        
//        let datePredicate = predicateForMonthFromDate(date: SelectedMonth.shared.date)
        
        let plannedTotal: Double = abs(plannedTransactions.filter(NSPredicate(format: "transactionCategory == %@", categories[indexPath.item])).filter(SelectedMonth.shared.selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
        
        amountBudgetedLabel.text = "\(plannedTotal.toCurrency())\n Planned"
        
        let spentTotal: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@ && isCleared == true", categories[indexPath.row])).filter(SelectedMonth.shared.selectedMonthPredicate()).sum(ofProperty: "transactionAmount"))
        
        
        if categories[indexPath.item].categoryName == "Income" {
            amountSpentLabel.text = "\(spentTotal.toCurrency()) \nEarned"
        } else {
            amountSpentLabel.text = "\(spentTotal.toCurrency()) \nSpent"
        }
        
        let plannedToSpentRatio = spentTotal / plannedTotal
        
        percentLabel.text = plannedToSpentRatio.toPercent()
        
        if plannedTotal == 0 {
            progressBar.progress = 0
        } else {
            progressBar.animateTo(progress: CGFloat(plannedToSpentRatio))
        }
        
    }
    
}

//MARK: - Extensions
//extension Budget2Cell: DateSwitcherDelegate {
//
//    func getDate(with date: Date) {
//        selectedDate = date
//        print(selectedDate)
//    }
//
//}
