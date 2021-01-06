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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleView.makeCircular()
        subcategoryImage.tintColor = .white
//        nameLabel.adjustsFontSizeToFitWidth = true
//        nameLabel.minimumScaleFactor = 0.5
        nameLabel.fitTextToBounds()
    }
        
    func configureSubcategoryCell(_ image: UIImage, _ color: UIColor) {
        subcategoryImage.image = image
        circleView.backgroundColor = color
    }
    
}
