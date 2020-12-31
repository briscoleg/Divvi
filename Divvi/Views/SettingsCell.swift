//
//  SettingsCell.swift
//  Balance
//
//  Created by Bo LeGrand on 10/27/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class SettingsCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var customView: UIView!
    
    
    //MARK: - Properties
    static let identifier = "SettingsCell"
    
    //MARK: - Init
    override func layoutSubviews() {
        super.layoutSubviews()
        customView.round()        
        
    }
    
    //MARK: - Methods
    
    func configure(with indexPath: IndexPath) {
        let switchControl = UISwitch(frame: .zero)
        switchControl.setOn(false, animated: true)
        switchControl.onTintColor = .red
        switchControl.tag = indexPath.row
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    @objc func handleSwitchAction(sender: UISwitch) {
        
        switch sender.tag {
        case 0:
            print("tapped on 0")
            

        default:
            print("tapped on something else")
        }
        print("Switch \(sender.tag) is \(sender.isOn)")

    }
    
    
}
