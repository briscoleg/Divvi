//
//  TestViewController.swift
//  Balance
//
//  Created by Bo on 8/30/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift


class TestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var plannedActualSegmentedControl: UISegmentedControl!
    
    let realm = try! Realm()
    
    lazy var subCategories = List<SubCategory>()
    
    var categorySelected: Category?
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter(currentMonthPredicate(date: Date())).filter(NSPredicate(format: "transactionCategory == %@", categorySelected!)) }()
    
    var viewTitle = ""
    
    var planningView = true
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

        registerCells()
    }

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .gray
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        return cv
    }()

    var cellId = "SubCell"
    var celltwoCellId = "SearchCell"
    
    func displayAmount(with amount: Double) -> NSAttributedString {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let number = currencyFormatter.string(from: NSNumber(value: amount))
        
        let mutableAttributedString = NSMutableAttributedString(string: number!)
        if let range = mutableAttributedString.string.range(of: #"(?<=.)(\d{2})$"#, options: .regularExpression) {
            mutableAttributedString.setAttributes([.font: UIFont.systemFont(ofSize: 9), .baselineOffset: 6],
                                                  range: NSRange(range, in: mutableAttributedString.string))
        }
        
        return mutableAttributedString
        
    }
    
    func convertStringtoDouble(with amount: String) -> Double {
        
        let formatter = NumberFormatter()
        
        let formattedNumber = formatter.number(from: amount)
        
        return formattedNumber!.doubleValue
        
    }
    
    func currentMonthPredicate(date: Date) -> NSPredicate {
                
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.day = 01
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.day = 31
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }

    fileprivate func registerCells() {
        collectionView.register(SubCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(TaskCell.self, forCellWithReuseIdentifier: celltwoCellId)
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        
        switch plannedActualSegmentedControl.selectedSegmentIndex {
        case 0:
            planningView = true
            collectionView.reloadData()
        case 1:
            planningView = false
            collectionView.reloadData()
        default:
            break
        }
    }
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if planningView {
        return subCategories.count
        } else {
            return transactions.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
            if planningView {
                
            let planningCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath) as! SubCell
//
//            planningCell.nameLabel.text = subCategories[indexPath.item].subCategoryName
//                planningCell.nameLabel.textColor = .black
//            let absAmountBudgeted = abs(subCategories[indexPath.item].subCategoryAmountBudgeted)
//            planningCell.amountLabel.text = absAmountBudgeted.toCurrency()
//            planningCell.amountLabel.textColor = .black
//            planningCell.backgroundColor = UIColor(white: 1, alpha: 0.5)
//            planningCell.layer.cornerRadius = 10
            
            
            return planningCell
        } else {
            // Cell 2
            let transactionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! TaskCell
                                                
                        transactionCell.imageView.image = UIImage(named: transactions[indexPath.item].transactionCategory!.categoryName)
                        transactionCell.imageView.tintColor = .white
                        transactionCell.circleView.backgroundColor = UIColor(rgb: transactions[indexPath.item].transactionCategory!.categoryColor)
                        transactionCell.subcategoryLabel.text = transactions[indexPath.item].transactionDescription
                        transactionCell.amountLabel.attributedText = displayAmount(with: transactions[indexPath.item].transactionAmount)
                        
                        let formatter = DateFormatter()
                        
                        formatter.dateFormat = "MMMM dd, yyyy"
                        
                        let dateString = formatter.string(from: transactions[indexPath.item].transactionDate)
                        
                        transactionCell.dateLabel.text = dateString
                        
                        
                        
                        if transactions[indexPath.row].transactionAmount > 0 {
                            
                            transactionCell.amountLabel.textColor = UIColor(rgb: SystemColors.green)
                            
                        } else {
                            transactionCell.amountLabel.textColor = UIColor(rgb: SystemColors.red)
                            
                        }
                        
            //            let transactionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath) as! SubCell
                        
            //            transactionCell.delegate = self
                        if transactions[indexPath.item].isCleared == false {
                            transactionCell.subcategoryLabel.textColor = .lightGray
                            transactionCell.amountLabel.textColor = .lightGray
                        }
                        
            //            transactionCell.nameLabel.text = transactions[indexPath.item].transactionDescription
            //            let absAmountBudgeted = abs(subCategories[indexPath.item].subCategoryAmountBudgeted)
            //            transactionCell.amountLabel.text = transactions[indexPath.item].transactionAmount.toCurrency()
                        transactionCell.backgroundColor = UIColor(white: 1, alpha: 0.5)
                        transactionCell.layer.cornerRadius = 10
                        
                        return transactionCell
        }
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}
