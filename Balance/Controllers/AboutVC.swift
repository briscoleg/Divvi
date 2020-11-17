//
//  AboutVC.swift
//  Balance
//
//  Created by Bo LeGrand on 11/16/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var icons8Button: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()

    }
    
    private func configureUI() {
        dismissButton.backgroundColor = UIColor(rgb: SystemColors.shared.blue)
        dismissButton.roundCorners()
    }
    
    @IBAction func icons8ButtonPressed(_ sender: UIButton) {
        
        if let url = URL(string: "https://icons8.com") {
            UIApplication.shared.open(url)
        }
        
        
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
