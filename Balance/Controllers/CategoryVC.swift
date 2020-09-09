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
}

class CategoryVC: UICollectionViewController {
    
    var categoryDelegate: CategoryDelegate!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    let realm = try! Realm()
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
    lazy var subCategories: Results<SubCategory> = { self.realm.objects(SubCategory.self) }()
    
    
    
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
        
        categoryDelegate.getCategory(from: categories[indexPath.row])
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell {
            
            categoryCell.configureCategory(with: categories[indexPath.row])
            categoryCell.circleView.backgroundColor = UIColor(rgb: categories[indexPath.item].categoryColor)
            categoryCell.categoryImage.tintColor = .white
            
            cell = categoryCell
            
        }
        
        return cell
        
    }
}

