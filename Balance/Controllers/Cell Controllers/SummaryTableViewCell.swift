//
//  SummaryTableViewCell.swift
//  Balance
//
//  Created by Bo on 7/5/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
