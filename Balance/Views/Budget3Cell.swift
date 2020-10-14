//
//  Budget3Cell.swift
//  Balance
//
//  Created by Bo on 10/12/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation


import UIKit
import RealmSwift

class Budget3Cell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountBudgetedLabel: UILabel!
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var rightArrowIconImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
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
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "dateUpdated"), object: nil)

        
        //        progressBar.labelPosition = .right
//        progressBar.cornerType = .rounded
//        progressBar.layer.cornerRadius = 20
//        contentView.layer.cornerRadius = 20
//        progressBar.barBorderWidth = 0
//        progressBar.labelTextColor = .black
        
        
//        layer.shadowColor = UIColor.darkGray.cgColor
//        layer.cornerRadius = 0
        
        
        
    }
    
//    @objc func refresh() {
//        subviews.forEach { subview in
//            subview.layer.masksToBounds = false
//            subview.clipsToBounds = false
//            subview.layer.cornerRadius = 20
//            }
//    }
    
    
    
    //MARK: - Methods
    
    func configure(with indexPath: IndexPath) {
        
        nameLabel.text = categories[indexPath.item].categoryName
        
        imageView.image = UIImage(named: categories[indexPath.item].categoryName)
        
        progressBar.progressTintColor = UIColor(rgb: categories[indexPath.item].categoryColor)
        
        progressBar.backgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor).withAlphaComponent(0.55)
        
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
            progressBar.setProgress(Float(plannedToSpentRatio), animated: true)
        }
        
    }
    
}
