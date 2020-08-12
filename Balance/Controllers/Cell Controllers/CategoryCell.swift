//
//  CategoryCell.swift
//  Balance
//
//  Created by Bo on 7/19/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var circleView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.makeCircular()
        
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
        
    }
    
}

