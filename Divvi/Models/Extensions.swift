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

extension UIView {
    func makeCircular() {
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.masksToBounds = false
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.1
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.black.cgColor
        
    }
}

//extension UIApplication {
//    func hideKeyboard() {
//        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}

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

extension AddTransactionVC {
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
            
            let saveButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: nil, action: #selector(objcSaveTransaction))
            let hideButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .plain, target: nil, action: #selector(hideKeyboard))
            items.append(contentsOf: [hideButton, spacer, saveButton])

            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
            
            //        toolbar.backgroundColor = UIColor(red: 204, green: 207, blue: 214)
            //        toolbar.alpha = 0.8
            
            
        }
        
    }
    
}

extension UIView {
    func round(){
        
        let radius = bounds.maxX / 16
        
        layer.cornerRadius = radius
        clipsToBounds = true
//        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}


extension UIViewController {
    func addKeyboardAccessoryForSearchbar(searchBar: UISearchBar) {
        
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

extension UIColor {

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

extension String {
    func toDouble() -> Double {
        return NumberFormatter().number(from: self)?.doubleValue ?? 0.0
    }
}

extension Double {
    func toCurrency() -> String {
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency

        let formattedNumber = formatter.string(from: NSNumber(value: self))

        return formattedNumber!
    }
}

extension Date {
    func style(style: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "\(style)"
        let formattedDate = formatter.string(from: date)
        return formattedDate
        
    }
}

extension Date {
    func dateToString() -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM d, yyyy"
        
        let dateString = formatter.string(from: date)

        return dateString
    }
}

extension Double {
    func toString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let formattedNumber = formatter.string(from: NSNumber(value: self))
        
//        return formattedNumber!
        
        return NumberFormatter().string(from: NSNumber(value: self))!
    }
}

extension Double {
    func toPercent() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
//        formatter.multiplier = 1
        var percentString = formatter.string(from: NSNumber(value: self))
        if self.isNaN {
            percentString = formatter.string(from: 0)
        }
        return percentString!
    }
}

extension UIViewController {
    func convertStringToDouble(from string: String) -> Double {
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        let number = formatter.number(from: string)
        let doubleValue = number!.doubleValue
        
        return doubleValue
        
    }
}

extension Double {
    func toAttributedString(size: Int, offset: Int, weight: UIFont.Weight) -> NSAttributedString {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let number = currencyFormatter.string(from: NSNumber(value: self))
        
        let mutableAttributedString = NSMutableAttributedString(string: number!)
        if let range = mutableAttributedString.string.range(of: #"(?<=.)(\d{2})$"#, options: .regularExpression) {
            mutableAttributedString.setAttributes([.font: UIFont.systemFont(ofSize: CGFloat(size), weight: weight), .baselineOffset: offset],
                                                  range: NSRange(range, in: mutableAttributedString.string))
        }
        
        return mutableAttributedString
        
    }
}

extension NSPredicate {
    
    static func transactionDescriptionEqualTo(_ description: String?) -> NSPredicate {
        if let description = description {
            return .init(format: "transactionDescription == %@", description)
        }
        return .init(format: "transactionDescription == nil")
    }

    static func transactionCategoryEqualTo(_ category: Category?) -> NSPredicate {
        if let category = category {
            return .init(format: "transactionCategory == %@", category)
        }
        return .init(format: "transactionCategory == nil")
    }

    static func transactionDateIsAfter(_ date: Date) -> NSPredicate {
        return .init(format: "transactionDate >= %@", date as NSDate)
    }

    static func futureRepeats(of transaction: Transaction) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            .transactionDescriptionEqualTo(transaction.transactionDescription),
            .transactionCategoryEqualTo(transaction.transactionCategory),
            .transactionDateIsAfter(transaction.transactionDate),
        ])
    }
}

extension Date {
    enum Style {
        case short
        case medium
        case long
    }
    func toString(style: Style) -> String {
        
        let formatter = DateFormatter()
        
        var formattedString: String
        
        switch style {
        case Style.short:
            formatter.dateStyle = .short
            formattedString = formatter.string(from: self)
        case Style.medium:
            formatter.dateStyle = .medium
            formattedString = formatter.string(from: self)
        case Style.long:
            formatter.dateStyle = .long
            formattedString = formatter.string(from: self)
            
        }
        
        return formattedString
        
    }
}

//Hide Keyboard with Gesture Recognizer
extension UIViewController {
    //Call this function from any view controller to enable.
    func hideKeyboardOnTap() {
        view.addGestureRecognizer(endEditingRecognizer())
        navigationController?.navigationBar.addGestureRecognizer(endEditingRecognizer())
    }

    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}

extension UIViewController {
    func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool) {
    if #available(iOS 13.0, *) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
        navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
        navBarAppearance.backgroundColor = backgoundColor
        navBarAppearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

        navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = tintColor
        navigationItem.title = title

    } else {
        // Fallback on earlier versions
        navigationController?.navigationBar.barTintColor = backgoundColor
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = title
    }
}}

extension NSPredicate {
    func startingBalancePredicate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "date >= %@ && date =< %@", argumentArray: [startDate!, endDate!])
    }
}

extension NSPredicate {
    
    static func getDayRangePredicateFromDate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@", argumentArray: [startDate!, endDate!])
    }
    
    static func negativeTransactionPredicate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount < 0", argumentArray: [startDate!, endDate!])
    }
    
    static func positiveTransactionPredicate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "transactionDate >= %@ && transactionDate =< %@ && transactionAmount > 0", argumentArray: [startDate!, endDate!])
    }
    
    static func startingBalancePredicate(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        components.hour = 00
        components.minute = 00
        components.second = 00
        
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "date >= %@ && date =< %@", argumentArray: [startDate!, endDate!])
    }
    
}

extension Date{

func makeDayPredicate() -> NSPredicate {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
    components.hour = 00
    components.minute = 00
    components.second = 00
    let startDate = calendar.date(from: components)
    components.hour = 23
    components.minute = 59
    components.second = 59
    let endDate = calendar.date(from: components)
    return NSPredicate(format: "transactionDate >= %@ AND transactionDate =< %@", argumentArray: [startDate!, endDate!])
}
}



extension UINavigationController {

override open var shouldAutorotate: Bool {
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.shouldAutorotate
        }
        return super.shouldAutorotate
    }
}

override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }
}

override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
    get {
        if let visibleVC = visibleViewController {
            return visibleVC.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
}}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension UIFont {
    
    /**
     Will return the best font conforming to the descriptor which will fit in the provided bounds.
     */
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]
        
        let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension
        
        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont
            
            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            
            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        return bestFontSize
    }
    
    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return UIFont(descriptor: fontDescriptor, size: bestSize)
    }
}

extension UILabel {
    
    /// Will auto resize the contained text to a font size which fits the frames bounds.
    /// Uses the pre-set font to dynamically determine the proper sizing
    func fitTextToBounds() {
        guard let text = text, let currentFont = font else { return }
    
        let bestFittingFont = UIFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: basicStringAttributes)
        font = bestFittingFont
    }
    
    private var basicStringAttributes: [NSAttributedString.Key: Any] {
        var attribs = [NSAttributedString.Key: Any]()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        attribs[.paragraphStyle] = paragraphStyle
        
        return attribs
    }
}

extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
    
    func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
}

extension Date {
    public var removeTime : Date? {
       guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
        return nil
       }
       return date
   }
   
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}

extension Date {
    func monthAsString() -> String {
            let df = DateFormatter()
            df.setLocalizedDateFormatFromTemplate("MMM")
            return df.string(from: self)
    }
}

//extension UIViewController {
//    func showInputDialog(title:String? = nil,
//                         subtitle:String? = nil,
//                         actionTitle:String? = "Add",
//                         cancelTitle:String? = "Cancel",
//                         inputPlaceholder:String? = nil,
//                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
//                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
//                         actionHandler: ((_ amount: Double?) -> Void)? = nil) {
//
//        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
//        alert.addTextField { (textField:UITextField) in
//            textField.placeholder = inputPlaceholder
//            textField.keyboardType = inputKeyboardType
//        }
//        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
//            guard let textField =  alert.textFields?.first else {
//                actionHandler?(nil)
//                return
//            }
//            actionHandler?(field)
//        }))
//        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
//
//        self.present(alert, animated: true, completion: nil)
//    }
//}
