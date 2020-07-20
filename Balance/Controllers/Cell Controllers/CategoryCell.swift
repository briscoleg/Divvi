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
        
//        layer.borderColor = UIColor.black.cgColor
//        layer.borderWidth = 1
//        layer.cornerRadius = self.frame.size.width / 2
//        layer.masksToBounds = true
//        layer.
//        layer.backgroundColor = UIColor(rgb: Constants.purple) as! CGColor
    }
    
//    public func configure(with image: UIImage) {
//        categoryImage.image = image
//    }
    
    func configure (with category: String, with image: UIImage) {
        categoryName.text = category
        categoryImage.image = image
        
    }
    
//    static func nib() -> UINib {
//        
//        return UINib(nibName: "CategoryCell", bundle: nil)
//        
//    }

}

