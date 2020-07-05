//
//  ButtonViewController.swift
//  Balance
//
//  Created by Bo on 6/30/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class ButtonViewController: UIViewController {
    
    @IBOutlet weak var myButton: RoundShakeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addActionToButton()
        setupButtonConstraints()

        
    }
    
    func setupButtonConstraints() {
        
        view.addSubview(myButton)
        myButton.translatesAutoresizingMaskIntoConstraints = false
        myButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        myButton.widthAnchor.constraint(equalToConstant: 280).isActive = true
        myButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200).isActive = true
        
    }
    
    
    func addActionToButton() {
        
        myButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
    }
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        myButton.shake()
        
    }
    
}
