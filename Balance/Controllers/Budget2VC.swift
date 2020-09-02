//
//  Budget2VC.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class Budget2VC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var incomeRing: CircularGraph!
    @IBOutlet weak var expenseRing: CircularGraph!
    
    //MARK: - Properties
    
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self)}()
    
    var category: Category?
    
    lazy var plannedTransactions: Results<Transaction> = { self.realm.objects(Transaction.self).filter(currentMonthPredicate(date: Date())) }()
    
    //    lazy var subCategories1: Results<SubCategory> = { self.realm.objects(SubCategory.self)}()
    
    
    
    //    var selectedCategory: Category!
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 25)
        
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/1.1, height: 100)
        
        layout.minimumInteritemSpacing = 0
        
        layout.minimumLineSpacing = 12
        
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        
        collectionView.collectionViewLayout = layout
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "planningAmountAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionCleared"), object: nil)
        
    }
    
    //MARK: -  Methods
    
    @objc private func refresh() {
        collectionView.reloadData()
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
    
    func getPredicateForSelectedMonth(date: Date) -> NSPredicate {
        
        let startDate = Date()
        
        let selectedYear = 2020
        let selectedMonth = 9
        
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        let startDateOfMonth = Calendar.current.date(from: components)
        
        //Now create endDateOfMonth using startDateOfMonth
        components.year = 0
        components.month = 1
        components.day = -1
        
        let endDateOfMonth = Calendar.current.date(byAdding: components, to: startDate)
        
        let predicate = NSPredicate(format: "%K >= %@ && %K <= %@", "DateAttribute", startDateOfMonth! as NSDate, "DateAttribute", endDateOfMonth! as NSDate)
        
        return predicate
    }
    
    func predicateForMonthFromDate(date: Date) -> NSPredicate {
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.day = 01
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.day = Date().day
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }
    
    
    
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            try! self.realm.write {
                
                let newCategory = Category()
                newCategory.categoryName = textField.text!
                newCategory.categoryColor = 0xd8d8d8
                
                self.realm.add(newCategory)
                
            }
            
            self.categories = self.realm.objects(Category.self)
            
            
            self.collectionView.reloadData()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (field) in
            
            textField = field
            textField.placeholder = "Enter a category name"
            textField.autocapitalizationType = .words
            
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

//MARK: - CollectionView Delegate Methods
extension Budget2VC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "SubVC") as? SubVC {
            
            vc.categorySelected = categories[indexPath.item]
            vc.subCategories = categories[indexPath.item].subCategories
            vc.viewTitle = categories[indexPath.item].categoryName
            show(vc, sender: self)
            //            navigationController?.pushViewController(vc, animated: true)
            //            present(vc, animated: true, completion: nil)
            
        }
    }
    
}

//MARK: - CollectionView DataSource Methods
extension Budget2VC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Budget2Cell", for: indexPath) as! Budget2Cell
        
        let datePredicate = predicateForMonthFromDate(date: Date())
        
        cell.nameLabel.text = categories[indexPath.item].categoryName
        cell.nameLabel.textColor = .white
        cell.amountSpentLabel.textColor = .white
        cell.amountBudgetedLabel.textColor = .white
        cell.rightArrowIconImageView.tintColor = .white
        cell.imageView.tintColor = .white
        
        //        let plannedTotal: Double = abs(categories[indexPath.item].subCategories.sum(ofProperty: "subCategoryAmountBudgeted"))
        
//        let plannedTotal: Double = abs(categories[indexPath.item].categoryAmountBudgeted)
//        let plannedTotal: Double = abs(plannedTransactions.filter(NSPredicate(format: "transactionCategory == %@", categories[indexPath.item] as! CVarArg)))
        let plannedTotal: Double = abs(plannedTransactions.filter(NSPredicate(format: "transactionCategory == %@", categories[indexPath.item])).sum(ofProperty: "transactionAmount"))
                
        cell.amountBudgetedLabel.text = "\(plannedTotal.toCurrency())\n Planned"
        
        let spentTotal: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@ && isCleared == true", categories[indexPath.row])).filter(datePredicate).sum(ofProperty: "transactionAmount"))
        
        
        if categories[indexPath.item].categoryName == "Income" {
            cell.amountSpentLabel.text = "\(spentTotal.toCurrency()) \nEarned"
        } else {
            cell.amountSpentLabel.text = "\(spentTotal.toCurrency()) \nSpent"
        }
//        cell.backgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor).withAlphaComponent(0.25)
        
        let plannedToSpentRatio = spentTotal / plannedTotal
        
//        print(plannedToSpentRatio)
        
//        cell.progressView.progressTintColor = UIColor(rgb: categories[indexPath.item].categoryColor)
//
//        cell.progressBar.backgroundColor = .white
        cell.progressBar.barFillColor = UIColor(rgb: categories[indexPath.item].categoryColor)
        cell.progressBar.barBackgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor).withAlphaComponent(0.75)
    
//        cell.progressBar.progress = CGFloat(plannedToSpentRatio)
        if plannedTotal == 0 {
            cell.progressBar.progress = 0
        } else {
            cell.progressBar.animateTo(progress: CGFloat(plannedToSpentRatio))
        }
        cell.progressBar.labelPosition = .right
        cell.progressBar.cornerType = .square
        cell.progressBar.cornerRadius = 5
        cell.progressBar.barBorderWidth = 0
        cell.progressBar.labelTextColor = .black
        
        
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        
//        cell.progressView.progress = Float(plannedToSpentRatio)
                
//        cell.progressBarProgress = 0.25
        
//        cell.progressView.setProgress(0.25, animated: true)
//        DispatchQueue.main.async {
//            cell.progressView.progress = 0.25
//        }
        

        //        cell.showProgress(with: plannedToSpentRatio)
//        cell.showProgress(with: 0.75)
//        cell.showProgress(with: plannedToSpentRatio)
//        cell.progressView.progress = Float(plannedToSpentRatio)
        
//        print(cell.progressView.progress)
        
        cell.layer.cornerRadius = 7.5
        
        cell.imageView.image = UIImage(named: categories[indexPath.item].categoryName)
        
        return cell
    }
    
    //    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    //
    //        // 1
    //        switch kind {
    //        // 2
    //        case UICollectionView.elementKindSectionHeader:
    //          // 3
    //          guard
    //            let headerView = collectionView.dequeueReusableSupplementaryView(
    //              ofKind: kind,
    //              withReuseIdentifier: "HeaderView",
    //              for: indexPath) as? HeaderView
    //
    //
    //            else {
    //              fatalError("Invalid view type")
    //          }
    //
    //
    //          let incomePlannedTotal = categories[0].categoryAmountBudgeted
    //
    //          headerView.incomeAmountLabel.text = incomePlannedTotal.toCurrency()
    //
    //          let expensesPlannedTotal: Double = abs(categories.filter(NSPredicate(format: "categoryName != %@", "Income")).sum(ofProperty: "categoryAmountBudgeted"))
    //
    //          headerView.expenseAmountLabel.text = expensesPlannedTotal.toCurrency()
    //
    //          let incomeMinusExpenseAmount = incomePlannedTotal - expensesPlannedTotal
    //
    //          let incomeToExpenseRatio =  expensesPlannedTotal / incomePlannedTotal
    //
    //          headerView.netAmountLabel.text = incomeMinusExpenseAmount.toCurrency()
    //
    //          headerView.progressBar.progress = Float(incomeToExpenseRatio)
    //
    //          headerView.progressBar.trackTintColor = UIColor(rgb: Constants.green)
    //
    //          if incomeMinusExpenseAmount == 0 {
    //            headerView.progressBar.progressTintColor = UIColor(rgb: Constants.blue)
    //          } else {
    //            headerView.progressBar.progressTintColor = UIColor(rgb: Constants.red)
    //          }
    //
    //          if incomeMinusExpenseAmount > 0 {
    //            headerView.adviceLabel.text = "Great job! You're under budget! You can pay off debt or add to savings!"
    //          } else if incomeMinusExpenseAmount < 0 {
    //            headerView.adviceLabel.text = "Uh oh! Your planned expenses are more than this month's income! Add more income or cut your expenses!"
    //          } else {
    //            headerView.adviceLabel.text = "You're right on track! Awesome Job! 🙌"
    //          }
    //
    //          return headerView
    //        default:
    //          // 4
    //          assert(false, "Invalid element type")
    //        }
    //
    //    }
    
}
