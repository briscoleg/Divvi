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
    
    //    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    var viewTitle = ""
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter(SelectedMonth.shared.selectedMonthPredicate()).filter(NSPredicate(format: "transactionCategory == %@", categorySelected!)).sorted(byKeyPath: "transactionDate", ascending: true) }()
    
    var sectionNames: [String] {
        return Set(transactions.value(forKey: "subCategoryName") as! [String]).sorted()
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
        
        configureCollectionViewLayout()
        
        hideNavigationBarLine()
        
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
    
    private func hideNavigationBarLine() {
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.layoutIfNeeded()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 75)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        
        collectionView.collectionViewLayout = layout
    }
    
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        if let vc =  storyboard?.instantiateViewController(identifier: "AddTransactionVC") as? AddTransactionVC {
            vc.modalPresentationStyle = .fullScreen
            //            vc.subcategoryPicked = categorySelected
            self.present(vc, animated: true, completion: nil)
            
            
        }
        
        
    }
}

//MARK: - CollectionView DataSource
extension SubVC: UICollectionViewDataSource {
    //
    //    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    //        guard orientation == .right else { return nil }
    //
    //        let deleteAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
    //
    //            try! self.realm.write {
    //                self.realm.delete(self.subCategories[indexPath.item])
    //
    //            }
    //
    //            collectionView.reloadData()
    //
    //        }
    //
    //        deleteAction.image = UIImage(systemName: "trash")
    //
    //        return [deleteAction]
    //    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return transactions.filter("subCategoryName == %@", sectionNames[section]).count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return sectionNames.count
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let transactionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath) as! SubCell
        
        transactionCell.configureSubcategoryCell(with: categorySelected!)
        
        let sectionSubcategory = sectionNames[indexPath.section]
        
        let filteredTransactions = transactions.filter("subCategoryName == %@", sectionSubcategory)[indexPath.item]
        
        let transactionName = filteredTransactions.subCategoryName
        transactionCell.nameLabel.text = transactionName
        
        let transactionDate = filteredTransactions.transactionDate
        transactionCell.dateLabel.text = transactionDate.dateToString()
        
        let transactionAmount = filteredTransactions.transactionAmount
        transactionCell.amountLabel.attributedText = transactionAmount.toAttributedString(size: 9, offset: 6, weight: .regular)
        
        
        let balanceAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", transactionDate).sum(ofProperty: "transactionAmount")
        transactionCell.balanceLabel.attributedText = balanceAtDate.toAttributedString(size: 9, offset: 6, weight: .regular)
        
        if transactions.filter("subCategoryName == %@", sectionSubcategory)[indexPath.item].isCleared == false {
            transactionCell.nameLabel.textColor = .lightGray
            transactionCell.amountLabel.textColor = .lightGray
            transactionCell.dateLabel.textColor = .lightGray
            transactionCell.balanceLabel.textColor = .lightGray
        } else {
            transactionCell.nameLabel.textColor = .black
            if filteredTransactions.transactionAmount > 0 {
                transactionCell.amountLabel.textColor = UIColor(rgb: SystemColors.green)
            } else {
                transactionCell.amountLabel.textColor = UIColor(rgb: SystemColors.red)
            }
            transactionCell.dateLabel.textColor = .black
            transactionCell.balanceLabel.textColor = .black
        }
        
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
            let totalPlanned: Double = transactions.filter("subCategoryName == %@", sectionNames[indexPath.section]).sum(ofProperty: "transactionAmount")
            let totalSpent: Double = transactions.filter(NSPredicate(format: "isCleared == 1")).sum(ofProperty: "transactionAmount")
            
            headerView.totalPlannedLabel.text = "Total: \(abs(totalPlanned).toCurrency())"
            
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
            
            vc.transaction = transactions.filter("subCategoryName == %@", sectionNames[indexPath.section])[indexPath.item]
            
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


