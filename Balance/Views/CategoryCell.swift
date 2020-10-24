//
//  CategoryCell.swift
//  Balance
//
//  Created by Bo on 7/19/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryCell: UICollectionViewCell {
    
    static let cellIdentifier = "CategoryCell"

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var deleteThisCell: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.makeCircular()
        
        categoryImage.tintColor = .white
        
    }

//    func setColors(with color: UIColor) {
//        
////        categoryName.textColor = color
////        categoryImage.tintColor = color
//        
//        circleView.backgroundColor = color
//        
//    }
    
    func configureCategory (with category: Category) {
        
        categoryName.text = category.categoryName
        categoryImage.image = UIImage(named: category.categoryName)
        circleView.backgroundColor = UIColor(rgb: category.categoryColor)
        deleteButton.isHidden = true
        
    }
    
    func configureSubcategory(with subCategory: SubCategory, and categorySelected: Category) {
        
        categoryName.text = subCategory.subCategoryName
        categoryImage.image = UIImage(named: categorySelected.categoryName)
        circleView.backgroundColor = UIColor(rgb: categorySelected.categoryColor)
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        deleteThisCell?()
        
    }
}

