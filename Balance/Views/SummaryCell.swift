//
//  SummaryCell.swift
//  Balance
//
//  Created by Bo on 8/19/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class SummaryCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    
    static let cellId = "SummaryCell"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.makeCircular()
        imageView.tintColor = .white

    }
    
    func configure(with image: UIImage, and amount: Double) {
        
        imageView.image = image
        amountLabel.attributedText = amount.toAttributedString(size: 9, offset: 4, weight: .regular)
        
    }
}
