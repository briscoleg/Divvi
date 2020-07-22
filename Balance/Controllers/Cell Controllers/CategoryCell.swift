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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func setColors(with color: UIColor) {
        
        categoryName.textColor = color
        categoryImage.tintColor = color
        
    }
    
    func configure (with category: String, with image: UIImage) {
        categoryName.text = category
        categoryImage.image = image
        
    }
    
}

