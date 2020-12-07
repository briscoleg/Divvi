//
//  Budget3Cell.swift
//  Balance
//
//  Created by Bo on 10/12/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class PlanningCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountBudgetedLabel: UILabel!
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var rightArrowIconImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var progressBar: PlainHorizontalProgressBar!
    
    //MARK: - Properties
    static let identifier = "PlanningCell"
    var progress: Float = 0.0
    
    //MARK: - LayoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
                
    }
        
    //MARK: - Methods
    private func configureLayout() {
        nameLabel.textColor = .white
        amountSpentLabel.textColor = .white
        amountBudgetedLabel.textColor = .white
        rightArrowIconImageView.tintColor = .white
        imageView.tintColor = .white
        percentLabel.textColor = .white
        contentView.backgroundColor = .systemBackground
        progressBar.backgroundColor = .systemGray3
                
    }
    
    internal func configure(name: String, image: UIImage, color: UIColor) {
        
        nameLabel.text = name
        imageView.image = image
        progressBar.color = color
        
    }
    
}
