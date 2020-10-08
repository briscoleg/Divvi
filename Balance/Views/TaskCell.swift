//
//  SearchCell.swift
//  Balance
//
//  Created by Bo on 7/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

class TaskCell: SwipeCollectionViewCell {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var subcategoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    static let reuseIdentifier = "taskCell"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLayout()
    }
    
    private func configureLayout() {
        
        imageView.tintColor = .white
        circleView.makeCircular()


    }
    
    internal func configureCollectionViewCells(_ indexPath: IndexPath, _ transaction: Results<Transaction>) {
        
        imageView.image = UIImage(named: transaction[indexPath.item].transactionCategory!.categoryName)
        circleView.backgroundColor = UIColor(rgb: transaction[indexPath.item].transactionCategory!.categoryColor)
        subcategoryLabel.text = transaction[indexPath.item].transactionSubCategory?.subCategoryName
        amountLabel.attributedText = transaction[indexPath.item].transactionAmount.toAttributedString(size: 9, offset: 6, weight: .regular)
        
        
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM dd, yyyy"
        
        let dateString = formatter.string(from: transaction[indexPath.item].transactionDate)
        
        dateLabel.text = dateString
        
        if transaction[indexPath.item].transactionAmount > 0 {
            
            amountLabel.textColor = UIColor(rgb: Constants.green)
            
        } else {
            
            amountLabel.textColor = UIColor(rgb: Constants.red)
            
        }
    }
}
