//
//  CurrencyTextField.swift
//  Balance
//
//  Created by Bo on 7/3/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

@IBDesignable class CurrencyTextField: UITextField, UITextFieldDelegate {
        
    open override func awakeFromNib() {
    super.awakeFromNib()
        
        
    
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let dotString = "."
        let character = "$"

        if let text = textField.text{
            if !text.contains(character){
                textField.text = "-\(character)\(text)"
            }
            let isDeleteKey = string.isEmpty

            if !isDeleteKey {
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
