//
//  CategoryCVC.swift
//  Balance
//
//  Created by Bo on 7/14/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

protocol CategoryDelegate {
    func getCategory(from category: Category)
    func getSubcategory(from subcategory: SubCategory)
}

class CategoryVC: UICollectionViewController {
    
    var categoryDelegate: CategoryDelegate!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    let realm = try! Realm()
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    lazy var subCategories: Results<SubCategory> = { self.realm.objects(SubCategory.self) }()
    
    var categoryView = true
    var categorySelected: Category?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        
    }
    
    func configureLayout() {
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 50, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
    }
    
}

extension CategoryVC {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if categoryView {
            categorySelected = categories[indexPath.item]
            categoryDelegate.getCategory(from: categories[indexPath.item])
            categoryView = false
            collectionView.reloadData()

        } else {
            
            if indexPath.item == 0 {
                var textField = UITextField()
                
                let alert = UIAlertController(title: "New \(categorySelected!.categoryName) Category", message: "(20 Characters Max)", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Add", style: .default) { (action) in
                    
                    let newCategory = SubCategory()
                    newCategory.subCategoryName = textField.text!
                    newCategory.subCategoryAmountBudgeted = 0.0
                    
                    
                    try! self.realm.write {
                        self.categorySelected!.subCategories.append(newCategory)
                        
                    }
                    
                    collectionView.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "categoryAdded"), object: nil)
                    
                    
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
                }
                
                alert.addTextField { (field) in
                    
                    field.delegate = self
                    textField = field
                    textField.placeholder = "New Category Name"
                    textField.autocapitalizationType = .words
                    
                }
                alert.addAction(action)
                alert.addAction(cancelAction)
                                
                present(alert, animated: true, completion: nil)
            } else {
                categoryDelegate.getSubcategory(from: categorySelected!.subCategories[indexPath.item - 1])
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if categoryView {
            return categories.count

        } else {
            return categorySelected!.subCategories.count + 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if categoryView {
            
            if let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell {
                
                categoryCell.configureCategory(with: categories[indexPath.item])
                
                cell = categoryCell
                
            }
        } else {
            if let subCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell {
                
                if indexPath.item == 0 {
                    subCategoryCell.categoryImage.image = UIImage(systemName: "plus")
                    subCategoryCell.categoryName.text = "Add"
                    subCategoryCell.circleView.backgroundColor = UIColor(rgb: Constants.grey)
                } else {
                    subCategoryCell.configureSubcategory(with: categorySelected!.subCategories[indexPath.item - 1], and: categorySelected!)
                }
                
                
                
                cell = subCategoryCell
                
            }
        }
        
        return cell
        
    }
}

extension CategoryVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
                let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                    return false
            }
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            return count <= 20
    }
}
