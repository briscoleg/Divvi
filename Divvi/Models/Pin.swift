//
//  Pin.swift
//  Divvi
//
//  Created by Bo LeGrand on 12/6/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class Pin: UIView {
    
    let pin = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        pin.backgroundColor = .black
        pin.layer.cornerRadius = 10
        pin.layer.masksToBounds = true
        pin.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pin)
        NSLayoutConstraint.activate([
            pin.centerXAnchor.constraint(equalTo: centerXAnchor),
            pin.centerYAnchor.constraint(equalTo: centerYAnchor),
            pin.widthAnchor.constraint(equalToConstant: 20),
            pin.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
}
