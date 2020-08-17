//
//  BudgetVC.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class BudgetVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    lazy var transactions: Results<Transaction> = { self.realm.objects(Transaction.self)}()
    
    //    var selectedCategory: Category!
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        
        //        self.perform(#selector(animateProgress), with: nil, afterDelay: 2.0)
        
        
        //        progressRingSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "planningAmountAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "transactionAdded"), object: nil)
        
        
        //        populateDefaultCategories()
        //        populateDefaultColors()
        
        
        tabBarController!.tabBar.items![2].badgeValue = nil
        
        
        //        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        
        
    }
    
    
    
    //MARK: -  Methods
    
    @objc func animateProgress() {
        
    }
    
    @objc private func refresh() {
        collectionView.reloadData()
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
        
        components.day = 31
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (cancelAction) in
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

//MARK: - Delegate Methods
extension BudgetVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "SubVC") as? SubVC {
            
            vc.categorySelected = categories[indexPath.item]
            vc.subCategories = categories[indexPath.item].subCategories
            vc.viewTitle = categories[indexPath.item].categoryName
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
}

//MARK: - DataSource Methods
extension BudgetVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let datePredicate = predicateForMonthFromDate(date: Date())
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BudgetCell", for: indexPath) as! BudgetCell
        
        cell.nameLabel.text = categories[indexPath.item].categoryName
        
        let plannedTotal: Double = abs(categories[indexPath.item].subCategories.sum(ofProperty: "amountBudgeted"))
        
        cell.amountBudgetedLabel.text = plannedTotal.toCurrency()
        
//        let transactionCategoryTotal: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@ ", categories[indexPath.row])).sum(ofProperty: "transactionAmount"))
                
        let transactionCategoryTotal: Double = abs(transactions.filter(NSPredicate(format: "transactionCategory == %@ ", categories[indexPath.row])).filter(datePredicate).sum(ofProperty: "transactionAmount"))
        
        cell.amountSpentLabel.text = transactionCategoryTotal.toCurrency()
        
        cell.progressRingView.progressLayerStrokeColor = UIColor(rgb: categories[indexPath.item].categoryColor)
        
        let plannedToSpentRatio = transactionCategoryTotal / plannedTotal
        
        cell.progressRingView.animateProgress(duration: 1.0, value: plannedToSpentRatio)
        
        cell.backgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor).withAlphaComponent(0.25)
        
        cell.progressRingView.backgroundColor = UIColor.clear
        
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        cell.layer.cornerRadius = 7.5
        
        cell.imageView.image = UIImage(named: categories[indexPath.item].categoryName)
        
        return cell
    }
    
    
    
}
