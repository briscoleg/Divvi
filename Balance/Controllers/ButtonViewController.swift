//
//  ButtonViewController.swift
//  Balance
//
//  Created by Bo on 6/30/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class ButtonViewController: UIViewController {
    
    var button = CustomButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addActionToButton()
        setupButtonConstraints()

        
    }
    
    func setupButtonConstraints() {
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 280).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200).isActive = true
        
    }
    
    
    func addActionToButton() {
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
    }
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        button.shake()
        
    }
    
}
