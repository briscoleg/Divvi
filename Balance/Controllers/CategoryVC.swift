//
//  CategoryVC2.swift
//  Balance
//
//  Created by Bo LeGrand on 10/23/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

protocol CategoryDelegate {
    func getCategory(from category: Category)
    func getSubcategory(from subcategory: SubCategory)
}

class CategoryVC: UIViewController {
    
    static let identifier = "CategoryVC"
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    //MARK: - Properties
    var categoryDelegate: CategoryDelegate!
    
    let realm = try! Realm()
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    lazy var subCategories: Results<SubCategory> = { self.realm.objects(SubCategory.self) }()
    
    var categoryView = true
    var editMode = false
    var categorySelected: Category?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        configureLayout()
        hideOrShowBackButton()
        
    }
    
    //MARK: - Methods
    private func configureLayout() {
        
        let layout = UICollectionViewFlowLayout()
        
        collectionView.collectionViewLayout = layout
        
    }
    
    private func showDeleteButtons(_ subCategoryCell: CategoryCell) {
        if editMode {
            subCategoryCell.deleteButton.isHidden = false
            editButton.setTitle("Done", for: .normal)
            
        } else {
            subCategoryCell.deleteButton.isHidden = true
            editButton.setTitle("Edit", for: .normal)
            
        }
    }
    
    private func hideOrShowBackButton() {
        
        if categoryView {
            backButton.isHidden = true
            editButton.isHidden = true
        } else {
            backButton.isHidden = false
            editButton.isHidden = false
        }
        
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        categoryView = true
        hideOrShowBackButton()
        editMode = false
        collectionView.reloadData()
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
        editMode = !editMode
        collectionView.reloadData()
        
    }
}

//MARK: - CollectionView Delegate & DataSource
extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if categoryView {
            return categories.count
            
        } else {
            return categorySelected!.subCategories.count + 1 //For add button
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if categoryView {
            
            if let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.cellIdentifier, for: indexPath) as? CategoryCell {
                
                let name = categories[indexPath.item].categoryName
                let image = UIImage(named: categories[indexPath.item].categoryName)
                let color = UIColor(rgb: categories[indexPath.item].categoryColor)
                
                categoryCell.configureCategory(name: name, image: image!, color: color)
                
                categoryCell.deleteButton.isHidden = true
                
                cell = categoryCell
                
            }
            
        } else {
            
            if let subCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.cellIdentifier, for: indexPath) as? CategoryCell {
                
                if indexPath.item == 0 {
                    
                    subCategoryCell.categoryImage.image = UIImage(systemName: "plus")
                    subCategoryCell.categoryName.text = "Add"
                    subCategoryCell.circleView.backgroundColor = UIColor(rgb: SystemColors.shared.grey)
                    subCategoryCell.deleteButton.isHidden = true
                    
                } else {
                    
                    if let categorySelected = categorySelected {
                        let name = categorySelected.subCategories[indexPath.item - 1].subCategoryName
                        let image = UIImage(named: categorySelected.categoryName)
                        let color = UIColor(rgb: categorySelected.categoryColor)
                        
                        subCategoryCell.configureSubcategory(name, image!, color)
                    }
                    
                    showDeleteButtons(subCategoryCell)
                    
                    subCategoryCell.deleteThisCell = { [self] in
                        
                        let categoryToDelete = categorySelected!.subCategories[indexPath.item - 1]
                        do {
                            try realm.write {
                                realm.delete(categoryToDelete)
                            }
                        } catch {
                            print("Error deleting subcategory \(error)")
                        }
                        collectionView.reloadData()
                        
                    }
                }
                
                cell = subCategoryCell
                
            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if categoryView {
            
            categorySelected = categories[indexPath.item]
            categoryDelegate.getCategory(from: categories[indexPath.item])
            categoryView = false
            hideOrShowBackButton()
            collectionView.reloadData()
            
        } else {
            
            if indexPath.item == 0 {
                
                var textField = UITextField()
                
                let alert = UIAlertController(title: "New \(categorySelected!.categoryName) Category", message: "(20 Characters Max)", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Add", style: .default) { [self] (action) in
                    
                    let newCategory = SubCategory()
                    newCategory.subCategoryName = textField.text!
                    newCategory.subCategoryAmountBudgeted = 0.0
                    
                    if let categorySelected = categorySelected {
                        do {
                            try realm.write {
                                categorySelected.subCategories.append(newCategory)
                            }
                        } catch {
                            print("Error creating new subcategory: \(error)")
                        }
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
    
}


extension CategoryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
