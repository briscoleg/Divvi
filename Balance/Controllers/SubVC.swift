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
    
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        
        print(subCategories)
        
    }
    
    
    
    //MARK: - Methods
    
    func convertStringtoDouble(with amount: String) -> Double {
        
        let formatter = NumberFormatter()
        
        let formattedNumber = formatter.number(from: amount)
        
        return formattedNumber!.doubleValue
        
    }
    
    //MARK: - IBActions
    
}

//MARK: - Extensions

extension SubVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCell", for: indexPath) as! SubCell
        
        cell.nameLabel.text = subCategories[indexPath.item].subCategoryName
        cell.amountLabel.text = String(subCategories[indexPath.item].amountBudgeted)
        
        return cell
    }
    
}

extension SubVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Monthly \(subCategories[indexPath.item].subCategoryName) Amount:", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
                        
            var textFieldDoubleValue = textField.text?.toDouble()
            
            let categoryToUpdate = self.subCategories[indexPath.item]
                
//            try realm.write {
//                categoryToUpdate.amountBudgeted = textFieldDoubleValue
//                
//            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (cancelAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (field) in
            
            textField.placeholder = "Enter monthly amount"
            textField = field
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
