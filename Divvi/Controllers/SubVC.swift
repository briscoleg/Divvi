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
    @IBOutlet weak var budgetLabel: UILabel!
    
    //MARK: - Properties
    
    static let identifier = "SubVC"
    
    let realm = try! Realm()
    
    lazy var subCategories = List<SubCategory>()
    
    var categorySelected: Category?
    
    var viewTitle = ""
    
    var categoryBudgetedAmount: Double { categoryBudgets.filter(NSPredicate(format: "budgetCategory == %@ && budgetMonth == \(SelectedMonth.shared.date.month) && budgetYear == \(SelectedMonth.shared.date.year)", categorySelected!.categoryName)).sum(ofProperty: "monthlyBudgetAmount") }
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter(SelectedMonth.shared.selectedMonthPredicate()).filter(NSPredicate(format: "transactionCategory == %@", categorySelected!)).sorted(byKeyPath: "transactionDate", ascending: true) }()
    
    lazy var categoryBudgets: Results<MonthlyCategoryBudget> = { self.realm.objects(MonthlyCategoryBudget.self) }()
    
    var sectionNames: [String] {
        return Set(transactions.value(forKey: "transactionName") as! [String]).sorted()
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        configureObservers()
        
        setupUI()
        //        hideNavigationBarLine()
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    //MARK: - Methods
    
    @objc func refresh() {
        collectionView.reloadData()
    }
    
    private func setupBudgetLabel() {
        
        let categoryBudgetAmount: Double = categoryBudgets.filter(NSPredicate(format: "budgetCategory == %@ && budgetMonth == \(SelectedMonth.shared.date.month) && budgetYear == \(SelectedMonth.shared.date.year)", categorySelected!.categoryName)).sum(ofProperty: "monthlyBudgetAmount")
        
        if categoryBudgetAmount > 0 {
            budgetLabel.text = "\(categoryBudgetAmount.toCurrency()) Budgeted"
        } else {
            budgetLabel.text = "No Budget Set"
        }
        
    }
    
    private func setupUI() {
        
        setBudgetButton.setTitleColor(UIColor(rgb: SystemColors.shared.blue), for: .normal)
//        setBudgetButton.setTitle("Set Budget", for: .normal)
        
        //\(SelectedMonth.shared.date.monthAsString()) \(SelectedMonth.shared.date.year) \(categorySelected!.categoryName)
        
        if categoryBudgetedAmount > 0 {
            
            setBudgetButton.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)

        } else {
            setBudgetButton.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)

        }
        configureCollectionViewLayout()
        configureNavigationBar(largeTitleColor: .label, backgoundColor: .systemBackground, tintColor: UIColor(rgb: SystemColors.shared.blue), title: viewTitle, preferredLargeTitle: true)
        
        setupBudgetLabel()

        
        
    }
    
    private func hideNavigationBarLine() {
        
        title = viewTitle
        
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
    
    private func addBudgetAmount() {
        
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Monthly \(categorySelected!.categoryName) Budget", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { [self] (action) in
            
            let monthlyBudget = MonthlyCategoryBudget()
            monthlyBudget.budgetCategory = categorySelected!.categoryName
            monthlyBudget.budgetMonth = SelectedMonth.shared.date.month
            monthlyBudget.budgetYear = SelectedMonth.shared.date.year
            if let textFieldDoubleValue = textField.text?.toDouble() {
                monthlyBudget.monthlyBudgetAmount = textFieldDoubleValue
                budgetLabel.text = "\(textFieldDoubleValue.toCurrency()) Budgeted"
                
            }
            
            do {
                try realm.write {
                    realm.add(monthlyBudget)
                }
            } catch {
                print("Error settings monthly budget: \(error)")
            }
            
            setupUI()

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (field) in
            
            textField = field
            textField.placeholder = "Enter monthly total"
            
            textField.keyboardType = .decimalPad
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "planningAmountAdded"), object: nil)
        
        self.present(alert, animated: true, completion: nil)
        
        
        


            
    }

//MARK: - IBActions

@IBAction func setBudgetButtonPressed(_ sender: UIButton) {
    
    let budgetAmount: Double = categoryBudgets.filter(NSPredicate(format: "budgetCategory == %@ && budgetMonth == \(SelectedMonth.shared.date.month) && budgetYear == \(SelectedMonth.shared.date.year)", categorySelected!.categoryName)).sum(ofProperty: "monthlyBudgetAmount")
    
    if budgetAmount > 0 {
        
        let setBudgetAmounts = categoryBudgets.filter(NSPredicate(format: "budgetCategory == %@ && budgetMonth == \(SelectedMonth.shared.date.month) && budgetYear == \(SelectedMonth.shared.date.year)", categorySelected!.categoryName))
        
        for amounts in setBudgetAmounts {
            do {
            try realm.write {
                realm.delete(amounts)
            }
            } catch {
                print("Error deleting budget amounts: \(error)")
            }
        }
        

        
    } else {
        addBudgetAmount()

    }
    
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "budgetUpdated"), object: nil)
    
    setupUI()
    
//    collectionView.reloadData()
    
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
            
            headerView.totalPlannedLabel.text = ""
            
            //            headerView.totalSpentLabel.text = "Spent: \(abs(totalSpent).toCurrency())"
            
            headerView.totalSpentLabel.text = "\(sectionNames[indexPath.section]) Total: \(abs(totalPlanned).toCurrency())"
            
            return headerView
            
        default:
            assert(false, "Invalid element type")
        }
        return UICollectionReusableView()
        
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
