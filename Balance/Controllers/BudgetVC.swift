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
    
    var selectedCategory: Category!
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //        populateDefaultCategories()
        //        populateDefaultColors()
        
        setupCategories()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        
        
        
    }
    
    //MARK: -  Methods
    
    private func populateDefaultCategories() {
        if categories.count == 0 {
            try! realm.write() {
                
                let defaultCategories =
                    ["Income", "Housing", "Transportation", "Food", "Utilities", "Clothing", "Entertainment", "Insurance", "Savings", "Debt" ]
                
                for category in defaultCategories {
                    let newCategory = Category()
                    newCategory.categoryName = category
                    
                    realm.add(newCategory)
                }
            }
            
            categories = realm.objects(Category.self)
        }
    }
    
    private func setupCategories() {
        
        if categories.count == 0 {
            
            let paycheck = SubCategory()
            paycheck.subCategoryName = "Paycheck"
            paycheck.amountBudgeted = 0.0
            
            let bonus = SubCategory()
            bonus.subCategoryName = "Bonus"
            bonus.amountBudgeted = 0.0
            
            let incomeCategory = Category()
            
            incomeCategory.categoryName = "Income"
            incomeCategory.categoryColor = 0x20bf6b
            incomeCategory.subCategories.append(paycheck)
            incomeCategory.subCategories.append(bonus)
            
            let mortgageRent = SubCategory()
            mortgageRent.subCategoryName = "Mortgage/Rent"
            mortgageRent.amountBudgeted = 0.0
            
            let housingCategory = Category()
            housingCategory.categoryName = "Housing"
            housingCategory.categoryColor = 0xa5b1c2
            housingCategory.subCategories.append(mortgageRent)
            
            try! realm.write() {
                
                
                realm.add(incomeCategory)
                realm.add(housingCategory)
            }
            
            categories = realm.objects(Category.self)
            
        }
    }
}

//MARK: - Delegate Methods
extension BudgetVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(identifier: "SubVC") as? SubVC {
            
            vc.subCategories = categories[indexPath.item].subCategories
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BudgetCell", for: indexPath) as! BudgetCell
        
        cell.nameLabel.text = categories[indexPath.item].categoryName
        cell.nameLabel.textColor = UIColor.black
        cell.amountBudgetedLabel.textColor = UIColor.black
        cell.amountSpentLabel.textColor = UIColor.black
        
        //        let realmColor = UIColor(rgb: categories[indexPath.item].color)
        
        cell.backgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor).withAlphaComponent(0.25)
        //        cell.backgroundColor = realmColor
        
        cell.progressRingView.foregroundCircleColor = UIColor(rgb: categories[indexPath.item].categoryColor).cgColor
        cell.progressRingView.backgroundColor = UIColor.clear
        
        
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        
        return cell
    }
    
    
}


