//
//  TransactionTableViewCell.swift
//  Balance
//
//  Created by Bo on 6/24/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        amountLabel.numberFormatted()
        
        let fnt = UIFont(name: "Helvetica", size: 50)
        let attributedString = NSMutableAttributedString(string: "$499", attributes: [NSAttributedString.Key.font: fnt?.withSize(50) as Any])
        attributedString.setAttributes([NSAttributedString.Key.font: fnt?.withSize(20) as Any, NSAttributedString.Key.baselineOffset: 20], range: NSRange(location: 2, length: 2))
        amountLabel.attributedText = attributedString
        
//        stackView.layer.cornerRadius = 10
//        amountView.layer.cornerRadius = 10
//        nameView.layer.cornerRadius = 10
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UILabel {
    
    func numberFormatted() {
        
        let s = "$499"
        let mas = NSMutableAttributedString(string: s, attributes: [
            .foregroundColor : UIColor.white,
            .font : UIFont(name:"Helvetica", size:50)!
        ])
        let r2 = s.index(before: s.endIndex)
        let r1 = s.index(before: r2)
        let r = NSRange(r1...r2, in:s)
        mas.addAttributes([
            .font : UIFont(name:"Helvetica", size:20)!,
            .baselineOffset : 20
            ], range: r)
        
        
    }
    
}
