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

//extension UIButton {
//    func makeButtonCircular(button: UIButton) {
//        
//        let button = UIButton()
//        
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
//        button.layer.masksToBounds = false
//        button.layer.shadowRadius = 2.0
//        button.layer.shadowOpacity = 0.5
//        button.layer.cornerRadius = button.frame.width / 2
//        button.layer.borderColor = UIColor.black.cgColor
//        button.layer.borderWidth = 1.0
//    }
//}

extension UIView {
    func makeCircular() {
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        layer.masksToBounds = false
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.1
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.black.cgColor
//        layer.borderWidth = 1.0
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

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyGroupingSeparator = ","
        formatter.locale = Locale(identifier: "en_US") //for USA's currency patter
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

//extension Add2VC: UITextFieldDelegate {
//
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let dotString = "."
//        let dollarSign = "$"
//        let minusSign = "-$"
//
//
//        if let text = textField.text{
//
//
//
//            print(text)
//
//            if !text.contains(dollarSign) && isExpense {
//                textField.text = "-\(dollarSign)\(text)"
//            }
//            if !text.contains(dollarSign) && !isExpense {
//                textField.text = "\(dollarSign)\(text)"
//            }
//
//            let backSpace = string.isEmpty
//
//            if backSpace && text == minusSign {
//                textField.text = ""
//            }
//            if !backSpace {
//                if text.contains(dotString) {
//                    if text.components(separatedBy: dotString)[1].count == 2 || string == "."  {
//                        return false
//                    }
//                }
//            }
//        }
//        return true
//    }
//}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIViewController {
    func addInputAccessoryForTextFields(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = false) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()

            var items = [UIBarButtonItem]()
            if previousNextable {
                let previousButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: nil, action: nil)
                previousButton.width = 30
                if textField == textFields.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                let nextButton = UIBarButtonItem(image: UIImage(systemName: "arrow.right"), style: .plain, target: nil, action: nil)
                nextButton.width = 30
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
            items.append(contentsOf: [spacer, doneButton])
            
            
            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
            
            //        toolbar.backgroundColor = UIColor(red: 204, green: 207, blue: 214)
            //        toolbar.alpha = 0.8
            
            
        }
        
    }
    
}

extension UIViewController {
    func addInputAccessoryForSearchbars(searchBar: UISearchBar) {
        
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()

            var items = [UIBarButtonItem]()
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
            items.append(contentsOf: [spacer, doneButton])
            
            
            toolbar.setItems(items, animated: false)
            searchBar.inputAccessoryView = toolbar
            
            //        toolbar.backgroundColor = UIColor(red: 204, green: 207, blue: 214)
            //        toolbar.alpha = 0.8
            
            
        }
        
    }
    
