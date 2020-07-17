//
//  TransactionTableViewCell.swift
//  Balance
//
//  Created by Bo on 6/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var transactionView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()

        valueView.round()

    }
}

extension UIView {
    func round(){
        
        let radius = bounds.maxX / 16
        
        layer.cornerRadius = radius
        clipsToBounds = true
//        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

extension UIView {
    func round2(){
                
        layer.cornerRadius = 2.5
//        layer.masksToBounds = false
        clipsToBounds = false
//        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
