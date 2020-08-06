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
    
//    var selectedCategory: Category!
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "reloadCategoryCollectionView"), object: nil)
        
        //        populateDefaultCategories()
        //        populateDefaultColors()
        
        
        tabBarController!.tabBar.items![2].badgeValue = nil

        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        

        
    }
    
    
    //MARK: -  Methods
    
    @objc private func refresh() {
        self.collectionView.reloadData()
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
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCategoryCollectionView"), object: nil)
                    
                    
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BudgetCell", for: indexPath) as! BudgetCell
        
        cell.nameLabel.text = categories[indexPath.item].categoryName
        
        let incomeCategoryTotal: Double = categories[indexPath.item].subCategories.sum(ofProperty: "amountBudgeted")
        
        cell.amountBudgetedLabel.text = incomeCategoryTotal.toCurrency()
        
//        let categoryTotal: Double = realm.objects(Category.self).filter("ANY subCategories == %@",categories[indexPath.item].subCategories).sum(ofProperty: "amountBudgeted")
        
//        let categoryTotal2: Double = incomeCategory
        
//        print(categoryTotal)
        
//        cell.amountBudgetedLabel.text =
//            String(format: "%.2f", categories[indexPath.item].subCategories[indexPath.item].amountBudgeted)
        
        //        let realmColor = UIColor(rgb: categories[indexPath.item].color)
        
        cell.backgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor).withAlphaComponent(0.25)
        //        cell.backgroundColor = realmColor
        
        cell.progressRingView.foregroundCircleColor = UIColor(rgb: categories[indexPath.item].categoryColor).cgColor
        cell.progressRingView.backgroundColor = UIColor.clear
        
        
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        
        return cell
    }
    
    
}


