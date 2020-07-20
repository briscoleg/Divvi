//
//  CategoryCVC.swift
//  Balance
//
//  Created by Bo on 7/14/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "CategoryCell"

class CategoryVC: UICollectionViewController {
    
    
    let categories: [String] = ["Add Category",
                                "Income",
                                "Housing",
                                "Transport",
                                "Food",
                                "Utilities",
                                "Clothing",
                                "Entertainment",
                                "Insurance",
                                "Savings",
                                "Debt",
                                "Miscellaneous",
                                "Add Category",
                                "Income",
                                "Housing",
                                "Auto",
                                "Food",
                                "Utilities",
                                "Clothing",
                                "Entertainment",
                                "Insurance",
                                "Savings",
                                "Debt",
                                "Miscellaneous"
    ]
    let images: [UIImage] = [
        UIImage.init(named: "add")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "income")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "housing")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "transportation")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "food")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "utilities")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "clothing")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "entertainment")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "insurance")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "savings")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "debt")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "misc")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "add")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "income")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "housing")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "transportation")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "food")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "utilities")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "clothing")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "entertainment")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "insurance")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "savings")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "debt")!.withRenderingMode(.alwaysOriginal),
        UIImage.init(named: "misc")!.withRenderingMode(.alwaysOriginal),
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 130.0, height: 130.0)
        
        collectionView.collectionViewLayout = layout
        
        
        //        collectionView.register(CategoryCell.nib(), forCellWithReuseIdentifier: "CategoryCell")
        //        collectionView!.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        
    }
    
}

extension CategoryVC {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        collectionView.deselectItem(at: indexPath, animated: true)
        //        print("You tapped me")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell {
            
            categoryCell.configure(with: categories[indexPath.row], with: images[indexPath.row])
            
            cell = categoryCell
            
        }
        
        return cell
        
    }
}
