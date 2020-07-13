//
//  Extensions.swift
//  Balance
//
//  Created by Bo on 7/11/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

extension UIButton {
    func roundCorners(){
        
        let radius = bounds.maxX / 16
        
        layer.cornerRadius = radius
        
    }
}

extension UIButton {
    func makeCircular(button: UIButton) {
        
        let button = UIButton()
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UITextField {
    func addMinus() {
        
        if text?.hasPrefix("-") == false {
            self.text = "-\(text!)"
        }
    }
}

extension UITextField {
    func dropMinus() {
        
        if let text = self.text {
            if text.hasPrefix("-") {
                self.text = String(text.dropFirst())
            }
        }
    }
}

extension UIViewController: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let dotString = "."
        let dollarSign = "$"
        let minusSign = "-$"
        
        if let text = textField.text{
            if !text.contains(dollarSign){
                textField.text = "-\(dollarSign)\(text)"
            }

            let backSpace = string.isEmpty
            if backSpace && text == minusSign {
                textField.text = ""
            }
            if !backSpace {
                if text.contains(dotString) {
                    if text.components(separatedBy: dotString)[1].count == 2 || string == "."  {
                        return false
                    }
                }
            }
        }
        return true
    }
}
