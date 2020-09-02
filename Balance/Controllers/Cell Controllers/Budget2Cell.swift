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
    
    @IBOutlet weak var nameLabel: UILabel!
       @IBOutlet weak var progressRingView: CircularGraph!
       @IBOutlet weak var amountSpentLabel: UILabel!
       @IBOutlet weak var amountBudgetedLabel: UILabel!
       @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rightArrowIconImageView: UIImageView!
    @IBOutlet weak var progressBar: GTProgressBar!
    
    let realm = try! Realm()
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let index = IndexPath.self
//
//        let plannedTotal: Double = abs(categories[IndexPath].categoryAmountBudgeted)
//
//        let plannedToSpentRatio = transactionCategoryTotal / plannedTotal
//        progressView.progress = Float(plannedToSpentRatio)
        
//        progressView.clipsToBounds = false
//        progressView.layer.cornerRadius = 10
//        progressView.progress = 0.5
//        progressView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/1.1, height: 100)
        

    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
////        showProgress()
//        progressBar.transform = progressBar.transform.scaledBy(x: UIScreen.main.bounds.width/1.1, y: 100)
//    }
    
    
        
    
    func showProgress() {
        
//        progressView.progress = progressBarProgress
//        progressView.setProgress(Float(progressBarProgress), animated: true)
        
    }
    
}
