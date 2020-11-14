//
//  SearchCell.swift
//  Balance
//
//  Created by Bo on 7/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import SwipeCellKit

class TaskCell: SwipeCollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    //MARK: - Properties
    static let reuseIdentifier = "TaskCell"
    
    //MARK: - Init
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.tintColor = .white
        circleView.makeCircular()
    }
    
    //MARK: - Methods
    
    func configureCells(image: UIImage, color: UIColor, name: String, amount: NSAttributedString, date: String, balance: NSAttributedString) {
        
        imageView.image = image
        circleView.backgroundColor = color
        nameLabel.text = name
        amountLabel.attributedText = amount
        dateLabel.text = date
        balanceLabel.attributedText = balance

    }
}
