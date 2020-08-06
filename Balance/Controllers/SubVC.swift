//
//  SubVC.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift


class SubVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    
    let realm = try! Realm()
    
    lazy var subCategories = List<SubCategory>()
    
    var categorySelected: Category?
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    var viewTitle = ""
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.title = viewTitle
        
    }
    
    //MARK: - Methods
    
    func convertStringtoDouble(with amount: String) -> Double {
        
        let formatter = NumberFormatter()
        
        let formattedNumber = formatter.number(from: amount)
        
        return formattedNumber!.doubleValue
        
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
                
        let alert = UIAlertController(title: "Add Subcategory", message: "", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Add", style: .default) { (action) in
                    
                    try! self.realm.write {
                        
                        let newSubCategory = SubCategory()
                        newSubCategory.subCategoryName = textField.text!
                        newSubCategory.amountBudgeted = 0.0
                        
                        self.subCategories.append(newSubCategory)
                        
                        self.realm.add(self.subCategories)
                        
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
                    textField.placeholder = "Enter a subcategory name"
                    textField.autocapitalizationType = .words
                    
                    //Make Capital
                    
                    
                }
                alert.addAction(action)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        
    }
    
//MARK: - Extensions

extension SubVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath) as! SubCell
                
        cell.nameLabel.text = subCategories[indexPath.item].subCategoryName
        cell.amountLabel.text = subCategories[indexPath.item].amountBudgeted.toCurrency()
        
        return cell
    }
    
}

extension SubVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Monthly \(subCategories[indexPath.item].subCategoryName):", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
                        
            let textFieldDoubleValue = textField.text?.toDouble()
            
            let categoryToUpdate = self.subCategories[indexPath.item]
                
            try! self.realm.write {
                categoryToUpdate.amountBudgeted = textFieldDoubleValue!
                
            }
            
            collectionView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCategoryCollectionView"), object: nil)
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (cancelAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (field) in
            
            textField = field
                        textField.placeholder = "Enter monthly total"

            textField.keyboardType = .decimalPad
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

extension Double {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        
        let formattedNumber = formatter.string(from: NSNumber(value: self))
        
        return formattedNumber!
        
    }
}
