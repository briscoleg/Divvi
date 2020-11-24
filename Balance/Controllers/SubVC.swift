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
    @IBOutlet weak var setBudgetButton: UIButton!
    
    //MARK: - Properties
    
    static let identifier = "SubVC"
    
    let realm = try! Realm()
        
    lazy var subCategories = List<SubCategory>()
    
    var categorySelected: Category?
        
    var viewTitle = ""
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter(SelectedMonth.shared.selectedMonthPredicate()).filter(NSPredicate(format: "transactionCategory == %@", categorySelected!)).sorted(byKeyPath: "transactionDate", ascending: true) }()
    
    var sectionNames: [String] {
        return Set(transactions.value(forKey: "transactionName") as! [String]).sorted()
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        configureObservers()
        
        
        
        configureCollectionViewLayout()
        
//        hideNavigationBarLine()
        
        configureNavigationBar(largeTitleColor: .label, backgoundColor: .systemBackground, tintColor: UIColor(rgb: SystemColors.shared.blue), title: viewTitle, preferredLargeTitle: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Methods
    
    @objc func refresh() {
        collectionView.reloadData()
    }
    
    private func hideNavigationBarLine() {
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.layoutIfNeeded()
        title = viewTitle
        
//        navigationBar.setValue(true, forKey: "hidesShadow")

        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionCleared"), object: nil)
    }
    
    func configureCollectionViewLayout() {
        
        let layout = UICollectionViewFlowLayout()
        
        collectionView.collectionViewLayout = layout
    }
    
    
    //MARK: - IBActions
    
    @IBAction func setBudgetButtonPressed(_ sender: UIButton) {
        
        
        
    }
}

//MARK: - CollectionView DataSource
extension SubVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return transactions.filter("transactionName == %@", sectionNames[section]).count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return sectionNames.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath) as? SubCell else { return UICollectionViewCell() }
        
        if let categorySelected = categorySelected {
            let image = UIImage(named: categorySelected.categoryName)
            let color = UIColor(rgb: categorySelected.categoryColor)
            cell.configureSubcategoryCell(image!, color)
        }
        
        let sectionSubcategory = sectionNames[indexPath.section]
        
        let filteredTransactions = transactions.filter("transactionName == %@", sectionSubcategory)[indexPath.item]
        
        let transactionName = filteredTransactions.transactionName
        cell.nameLabel.text = transactionName
        
        let transactionDate = filteredTransactions.transactionDate
        cell.dateLabel.text = transactionDate.dateToString()
        
        let transactionAmount = filteredTransactions.transactionAmount
        cell.amountLabel.attributedText = transactionAmount.toAttributedString(size: 9, offset: 6, weight: .regular)
        
        
        let transactionsTotalAtDate: Double = realm.objects(Transaction.self).filter("transactionDate <= %@", transactionDate).sum(ofProperty: "transactionAmount")
        
        let startingBalance: Double = realm.objects(StartingBalance.self).sum(ofProperty: "amount")
        
        let totalBalance: Double = transactionsTotalAtDate + startingBalance
        
        cell.balanceLabel.attributedText = totalBalance.toAttributedString(size: 9, offset: 6, weight: .regular)
        
        if transactions.filter("transactionName == %@", sectionSubcategory)[indexPath.item].isCleared == false {
            cell.nameLabel.textColor = .systemGray2
            cell.amountLabel.textColor = .systemGray2
            cell.dateLabel.textColor = .systemGray2
            cell.balanceLabel.textColor = .systemGray2
        } else {
            cell.nameLabel.textColor = .label
            if filteredTransactions.transactionAmount > 0 {
                cell.amountLabel.textColor = UIColor(rgb: SystemColors.shared.green)
            } else {
                cell.amountLabel.textColor = UIColor(rgb: SystemColors.shared.red)
            }
            cell.dateLabel.textColor = .label
            cell.balanceLabel.textColor = .label
        }
        
        return cell
        
    }
}

//MARK: - CollectionView Delegate
extension SubVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        
        case UICollectionView.elementKindSectionHeader:
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SubHeaderView.identifier, for: indexPath) as? SubHeaderView else { fatalError("Invalid view type") }
            
            let totalPlanned: Double = transactions.filter("transactionName == %@", sectionNames[indexPath.section]).sum(ofProperty: "transactionAmount")
            //            let totalSpent: Double = transactions.filter(NSPredicate(format: "isCleared == 1")).sum(ofProperty: "transactionAmount")
            
            headerView.totalPlannedLabel.text = "Total planned: \(abs(totalPlanned).toCurrency())"
            
            //            headerView.totalSpentLabel.text = "Spent: \(abs(totalSpent).toCurrency())"
            
            headerView.totalSpentLabel.text = sectionNames[indexPath.section]
            
            return headerView
            
        default:
            assert(false, "Invalid element type")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: DetailVC.identifier) as? DetailVC {
            vc.transaction = transactions.filter("transactionName == %@", sectionNames[indexPath.section])[indexPath.item]
            present(vc, animated: true, completion: nil)
        }
    }
}

extension SubVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 50)
    }
    
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
