//
//  SubCell.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import SwipeCellKit

class SubCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var subcategoryImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.makeCircular()
        subcategoryImage.tintColor = .white
        
    }
    
    func configureSubcategoryCell(with category: Category) {
        subcategoryImage.image = UIImage(named: category.categoryName)
        circleView.backgroundColor = UIColor(rgb: category.categoryColor)
    }
    
}
