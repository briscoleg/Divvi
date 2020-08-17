//
//  BudgetCategoryCell.swift
//  Balance
//
//  Created by Bo on 7/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class BudgetCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressRingView: CircularGraph!
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var amountBudgetedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    //MARK: - Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
 }
    
    
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        
//        configureCell()

    }
    
    
        
    //MARK: - Methods
    
    func configureProgressRing() {
        
//        progressRingView.foregroundCircleColor = 
        
    }

    //MARK: - Extensions
}
extension UICollectionViewCell {
    func configureCell() {
        layer.cornerRadius = 4.5
        layer.borderWidth = 5.0
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = UIColor.white
        
//        layer.masksToBounds = true
//
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: -1, height: 1)
//        layer.shadowRadius = 10.0
//        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        
    }
}
    
    extension UICollectionViewCell {

    func dropShadow() {
            self.layer.masksToBounds = false
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.5
            self.layer.shadowOffset = CGSize(width: -1, height: 1)
            self.layer.shadowRadius = 1
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.main.scale

        }
}

//extension UIColor {
//
//    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
//        return self.adjust(by: abs(percentage) )
//    }
//
//    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
//        return self.adjust(by: -1 * abs(percentage) )
//    }
//
//    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
//        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
//        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
//            return UIColor(red: min(red + percentage/100, 1.0),
//                           green: min(green + percentage/100, 1.0),
//                           blue: min(blue + percentage/100, 1.0),
//                           alpha: alpha)
//        } else {
//            return nil
//        }
//    }
//}


