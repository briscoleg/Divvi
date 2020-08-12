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

//private let reuseIdentifier = "CategoryCell"

class CategoryVC: UICollectionViewController {
    
    var categoryDelegate: CategoryDelegate!
    
//    var categorySelected: Category?
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    let realm = try! Realm()
    lazy var categories: Results<Category> = { self.realm.objects(Category.self) }()
                                
//    let images: [UIImage] = [
//        UIImage.init(named: "Income")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Housing")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(systemName: "car")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Food/Drink")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Utilities")!.withRenderingMode(.alwaysOriginal),
//        UIImage.init(named: "Clothing")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Entertainment")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Insurance")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Savings")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Debt")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Misc")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Medical")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Household")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Giving")!.withRenderingMode(.alwaysTemplate),
//        UIImage.init(named: "Travel")!.withRenderingMode(.alwaysTemplate),
//        
//    ]
    
//    let colors: [UIColor] = [
//        UIColor(rgb: Constants.green),
//        UIColor(rgb: Constants.grey),
//        UIColor(rgb: Constants.red),
//        UIColor(rgb: Constants.yellow),
//        UIColor(rgb: Constants.black),
//        UIColor(rgb: Constants.grey),
//        UIColor(rgb: Constants.orange),
//        UIColor(rgb: Constants.blue),
//        UIColor(rgb: Constants.green),
//        UIColor(rgb: Constants.grey),
//        UIColor(rgb: Constants.red),
//        UIColor(rgb: Constants.blue),
//        UIColor(rgb: Constants.purple),
//        UIColor(rgb: Constants.yellow),
//        UIColor(rgb: Constants.red),
//        
//    
//    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout = UICollectionViewFlowLayout()
        
//        layout.itemSize = CGSize(width: 100.0, height: 100.0)
        
        layout.sectionInset = UIEdgeInsets(top: 50, left: 0, bottom: 10, right: 0)
        
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        
//        layout.headerReferenceSize = CGSize(width: 0, height: 100)
        
        layout.minimumInteritemSpacing = 0
        
        layout.minimumLineSpacing = 0
                
        collectionView.collectionViewLayout = layout
        
        //        collectionView.register(CategoryCell.nib(), forCellWithReuseIdentifier: "CategoryCell")
        //        collectionView!.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        
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
    
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        switch kind {
//
//        case UICollectionView.elementKindSectionHeader:
//
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
//
//            headerView.backgroundColor = UIColor.blue
//            return headerView
//
//        case UICollectionView.elementKindSectionFooter:
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
//
//            footerView.backgroundColor = UIColor.green
//            return footerView
//
//        default:
//
//            assert(false, "Unexpected element kind")
//        }
//    }
}
