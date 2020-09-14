//
//  SubVC.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class SubVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    
    let realm = try! Realm()
    
    lazy var subCategories = List<SubCategory>()
    
    var categorySelected: Category?
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    //    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter(currentMonthPredicate(date: Date())).filter(NSPredicate(format: "transactionCategory == %@", categorySelected as! CVarArg)).sorted(byKeyPath: "transactionDate", ascending: true) }()
    
    var viewTitle = ""
    
    lazy var items: Results<Transaction> = { self.realm.objects(Transaction.self).filter(currentMonthPredicate(date: Date())).filter(NSPredicate(format: "transactionCategory == %@", categorySelected as! CVarArg)) }()
    var sectionNames: [String] {
        return Set(items.value(forKey: "transactionDescription") as! [String]).sorted()
    }
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionCleared"), object: nil)
        
        
        self.title = viewTitle
        //        self.view.backgroundColor = UIColor(rgb: categorySelected!.categoryColor).withAlphaComponent(0.25)
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        createCollectionViewLayout()
        
        //        let itemSpacing: CGFloat = 3
        //        let itemsInOneLine: CGFloat = 3
        //        let flow = UICollectionView().collectionViewLayout as! UICollectionViewFlowLayout
        //        flow.sectionInset = UIEdgeInsets(top: itemSpacing, left: itemSpacing, bottom: itemSpacing, right: itemSpacing)
        //        flow.minimumInteritemSpacing = itemSpacing
        //        flow.minimumLineSpacing = itemSpacing
        //        let cellWidth = (UIScreen.main.bounds.width - (itemSpacing * 2) - ((itemsInOneLine - 1) * itemSpacing)) / itemsInOneLine
        //        flow.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        //        collectionView.collectionViewLayout = layout
        
        
        
        //        collectionView.register(SearchCell.self, forCellWithReuseIdentifier: "SearchCell")
        //        collectionView.register(SubCell.self, forCellWithReuseIdentifier: "SubCell")
        
        
        
        
    }
    
    
    
    //MARK: - Methods
    
    @objc func refresh() {
        collectionView.reloadData()
    }
    
    func createCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/1.1, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        
        collectionView.collectionViewLayout = layout
    }
    
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
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: MonthToAdjust.date)
        
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
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        if let vc =  storyboard?.instantiateViewController(identifier: "AddTransactionVC") as? AddTransactionVC {
            vc.modalPresentationStyle = .fullScreen
            vc.categoryPicked = categorySelected
            self.present(vc, animated: true, completion: nil)
            
            
        }
        
        
    }
}

//MARK: - CollectionView DataSource
extension SubVC: UICollectionViewDataSource, SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            
            try! self.realm.write {
                self.realm.delete(self.subCategories[indexPath.row])
                
            }
            
            collectionView.reloadData()
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")
        
        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return items.filter("transactionDescription == %@", sectionNames[section]).count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return sectionNames.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let transactionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath) as! SubCell
        
        transactionCell.contentView.backgroundColor = UIColor(rgb: categorySelected!.categoryColor).withAlphaComponent(0.20)
        
        let transactionDescription = items.filter("transactionDescription == %@", sectionNames[indexPath.section])[indexPath.item].transactionDescription
        transactionCell.nameLabel.text = transactionDescription
        
        let transactionDate = items.filter("transactionDescription == %@", sectionNames[indexPath.section])[indexPath.item].transactionDate
        transactionCell.dateLabel.text = transactionDate.dateToString()
        
        let transactionAmount = items.filter("transactionDescription == %@", sectionNames[indexPath.section])[indexPath.item].transactionAmount
        transactionCell.amountLabel.text = transactionAmount.toCurrency()
        //
        let balanceAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", items[indexPath.item].transactionDate).sum(ofProperty: "transactionAmount")
        transactionCell.balanceLabel.text = balanceAtDate.toCurrency()
        
        
        //        if transactions[indexPath.item].transactionDescription == subCategories[indexPath.section].subCategoryName {
        
        
        //
                            if items.filter("transactionDescription == %@", sectionNames[indexPath.section])[indexPath.item].isCleared == false {
                                transactionCell.nameLabel.textColor = .lightGray
                                transactionCell.amountLabel.textColor = .lightGray
                                transactionCell.dateLabel.textColor = .lightGray
                                transactionCell.balanceLabel.textColor = .lightGray
                            } else {
                                transactionCell.nameLabel.textColor = .black
                                transactionCell.amountLabel.textColor = .black
                                transactionCell.dateLabel.textColor = .black
                                transactionCell.balanceLabel.textColor = .black
                            }
        //            //        transactionCell.backgroundColor = UIColor(white: 1, alpha: 0.05)
        //                    transactionCell.layer.cornerRadius = 10
        
        //        }
        
        //        transactionCell.nameLabel.text = transactions[indexPath.section].transactionDescription
        //
        //              transactionCell.dateLabel.text = transactions[indexPath.section].transactionDate.dateToString()
        //
        //              transactionCell.amountLabel.text = transactions[indexPath.section].transactionAmount.toCurrency()
        return transactionCell
        
        
    }
}


//MARK: - CollectionView Delegate
extension SubVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        // 2
        case UICollectionView.elementKindSectionHeader:
            // 3
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "SubHeaderView",
                    for: indexPath) as? SubHeaderView
                else {
                    fatalError("Invalid view type")
            }
            let totalPlanned: Double = items.filter("transactionDescription == %@", sectionNames[indexPath.section]).sum(ofProperty: "transactionAmount")
            let totalSpent: Double = items.filter(NSPredicate(format: "isCleared == 1")).sum(ofProperty: "transactionAmount")
            
            headerView.totalPlannedLabel.text = "Planned: \(abs(totalPlanned).toCurrency())"
            
            //            headerView.totalSpentLabel.text = "Spent: \(abs(totalSpent).toCurrency())"
            
            headerView.totalSpentLabel.text = sectionNames[indexPath.section]
            
            return headerView
        default:
            // 4
            assert(false, "Invalid element type")
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if let vc = storyboard?.instantiateViewController(identifier: "DetailVC") as? DetailVC {
            
            vc.transaction = items.filter("transactionDescription == %@", sectionNames[indexPath.section])[indexPath.item]
            
            present(vc, animated: true, completion: nil)
        }
        //        var textField = UITextField()
        //
        //        let alert = UIAlertController(title: "Monthly \(subCategories[indexPath.item].subCategoryName):", message: "", preferredStyle: .alert)
        //
        //        let action = UIAlertAction(title: "Add", style: .default) { (action) in
        //
        //            let textFieldDoubleValue = textField.text?.toDouble()
        //
        //            let subCategoryAmountToUpdate = self.subCategories[indexPath.item]
        //
        //            let categoryAmountToUpdate = self.categorySelected?.categoryAmountBudgeted
        //
        //            try! self.realm.write {
        //
        //                if self.categorySelected?.categoryName == "Income" {
        //                    subCategoryAmountToUpdate.subCategoryAmountBudgeted = textFieldDoubleValue!
        //                } else {
        //                    subCategoryAmountToUpdate.subCategoryAmountBudgeted = -textFieldDoubleValue!
        //                }
        //
        //                let sumOfSubCategories: Double = self.subCategories.sum(ofProperty: "subCategoryAmountBudgeted")
        //
        //                self.categorySelected?.categoryAmountBudgeted = sumOfSubCategories
        //
        //                print(self.categorySelected?.categoryAmountBudgeted)
        //            }
        //
        //            collectionView.reloadData()
        //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "planningAmountAdded"), object: nil)
        //
        //
        //        }
        //        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
        //            self.dismiss(animated: true, completion: nil)
        //        }
        //
        //        alert.addTextField { (field) in
        //
        //            textField = field
        //            textField.placeholder = "Enter monthly total"
        //
        //            textField.keyboardType = .decimalPad
        //
        //        }
        //        alert.addAction(action)
        //        alert.addAction(cancelAction)
        //
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "planningAmountAdded"), object: nil)
        //
        //        self.present(alert, animated: true, completion: nil)
        //
        //
        //
    }
}


