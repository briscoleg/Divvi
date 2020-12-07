//
//  CategoryCell.swift
//  Balance
//
//  Created by Bo on 7/19/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    //MARK: - Properties
    static let cellIdentifier = "CategoryCell"
    
    var deleteThisCell: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleView.makeCircular()
        categoryImage.tintColor = .white
        
    }
    
    func configureCategory(name: String, image: UIImage, color: UIColor) {
        categoryName.text = name
        categoryImage.image = image
        circleView.backgroundColor = color

    }

    
    func configureSubcategory(_ name: String, _ image: UIImage, _ color: UIColor) {
        
        categoryName.text = name
        categoryImage.image = image
        circleView.backgroundColor = color
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        deleteThisCell?()
        
    }
}

