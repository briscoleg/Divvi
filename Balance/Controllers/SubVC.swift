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
    
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    
    var viewTitle = ""
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.title = viewTitle
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout = UICollectionViewFlowLayout()
//
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        layout.sectionInset = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)

        layout.itemSize = CGSize(width: screenWidth/1.1, height: 100)

        layout.minimumInteritemSpacing = 0

        layout.minimumLineSpacing = 10

        collectionView.collectionViewLayout = layout
        
//        let itemSpacing: CGFloat = 3
//        let itemsInOneLine: CGFloat = 3
//        let flow = UICollectionView().collectionViewLayout as! UICollectionViewFlowLayout
//        flow.sectionInset = UIEdgeInsets(top: itemSpacing, left: itemSpacing, bottom: itemSpacing, right: itemSpacing)
//        flow.minimumInteritemSpacing = itemSpacing
//        flow.minimumLineSpacing = itemSpacing
//        let cellWidth = (UIScreen.main.bounds.width - (itemSpacing * 2) - ((itemsInOneLine - 1) * itemSpacing)) / itemsInOneLine
//        flow.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        collectionView.collectionViewLayout = layout

        
        collectionView.backgroundColor = UIColor(rgb: categorySelected!.categoryColor).withAlphaComponent(0.25)
        
        
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
                newSubCategory.subCategoryAmountBudgeted = 0.0
                
                self.subCategories.append(newSubCategory)
                
                self.realm.add(self.subCategories)
                
            }
            
            self.categories = self.realm.objects(Category.self)
            
            
            self.collectionView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCategoryCollectionView"), object: nil)
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
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

extension SubVC: UICollectionViewDataSource, SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            
            try! self.realm.write {
                self.realm.delete(self.subCategories[indexPath.row])
                
            }
            
            collectionView.reloadData()
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")
        
        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath) as! SubCell
        
        cell.delegate = self
        
        cell.nameLabel.text = subCategories[indexPath.item].subCategoryName
        let absAmountBudgeted = abs(subCategories[indexPath.item].subCategoryAmountBudgeted)
        cell.amountLabel.text = absAmountBudgeted.toCurrency()
        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
}

extension SubVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Monthly \(subCategories[indexPath.item].subCategoryName):", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let textFieldDoubleValue = textField.text?.toDouble()
            
            let subCategoryAmountToUpdate = self.subCategories[indexPath.item]
            
            let categoryAmountToUpdate = self.categorySelected?.categoryAmountBudgeted
            
            try! self.realm.write {
                
                if self.categorySelected?.categoryName == "Income" {
                    subCategoryAmountToUpdate.subCategoryAmountBudgeted = textFieldDoubleValue!
                } else {
                    subCategoryAmountToUpdate.subCategoryAmountBudgeted = -textFieldDoubleValue!
                }
                
                let sumOfSubCategories: Double = self.subCategories.sum(ofProperty: "subCategoryAmountBudgeted")
                
                self.categorySelected?.categoryAmountBudgeted = sumOfSubCategories
                
                print(self.categorySelected?.categoryAmountBudgeted)
            }
            
            collectionView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCategoryCollectionView"), object: nil)
            
            
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
    
    
    
}


