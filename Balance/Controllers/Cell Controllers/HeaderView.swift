//
//  HeaderView.swift
//  Balance
//
//  Created by Bo on 8/20/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var incomeAmountLabel: UILabel!
    @IBOutlet weak var expenseAmountLabel: UILabel!
    @IBOutlet weak var netAmountLabel: UILabel!
    @IBOutlet weak var adviceLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressBar.trackTintColor = UIColor(rgb: Constants.green)
        progressBar.progressTintColor = UIColor(rgb: Constants.red)
        
    }
    
}
