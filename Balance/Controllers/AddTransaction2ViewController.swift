////
////  AddTransactionViewController.swift
////  Balance
////
////  Created by Bo on 6/24/20.
////  Copyright © 2020 Bo. All rights reserved.
////
//
//import UIKit
//import FSCalendar
//import RealmSwift
//
//class AddTransaction2ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
//    
//    @IBOutlet weak var instructionsLabel: UILabel!
//    @IBOutlet weak var universalTextField: UITextField!
//    @IBOutlet weak var descriptionTextField: UITextField!
//    @IBOutlet weak var calendar: FSCalendar!
//    @IBOutlet weak var nextButton: UIButton!
//    @IBOutlet weak var cancelButton: UIButton!
//    @IBOutlet weak var buttonStackView: UIStackView!
//    
//    
//    let realm = try! Realm()
//    
//    var buttonCounter = 0
//    
//    var amount = 0.0
//    var name = ""
//    var desc: String?
//    var datePicked = Date()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//                
//        calendar.delegate = self
//        calendar.dataSource = self
//        
//        
//        universalTextField.becomeFirstResponder()
//        universalTextField.keyboardType = .decimalPad
//        descriptionTextField.isHidden = true
//        calendar.isHidden = true
//        instructionsLabel.text = "Amount:"
//        
//        nextButton.roundCorners()
//        
//    }
//    
//    @IBAction func nextButtonPressed(_ sender: UIButton) {
//        
//        buttonCounter += 1
//               
//               switch buttonCounter {
//                   
//               case 1:
//                   
//                   amount = NSString(string: universalTextField.text!).doubleValue
//                   print(amount)
//                   universalTextField.text = ""
//                   instructionsLabel.text = "Name:"
//                   universalTextField.keyboardType = .alphabet
//                   
//                   universalTextField.becomeFirstResponder()
//                   universalTextField.placeholder = "e.g. Starbucks"
//                   descriptionTextField.placeholder = "Add description (optional)"
//                   universalTextField.reloadInputViews()
//                   descriptionTextField.isHidden = false
//                   
//               case 2:
//                   
//                   instructionsLabel.text = "Date:"
//                   
//                   name = universalTextField.text!
//                   desc = descriptionTextField.text!
//                   print(name)
//                   print(desc!)
//                   universalTextField.isHidden = true
//                   descriptionTextField.isHidden = true
//
//                   calendar.isHidden = false
//                   nextButton.setTitle("Add Transaction", for: .normal)
//                   UIApplication.shared.endEditing()
//                   
//               case 3:
//                   
//                   let newTransaction = Transaction()
//                   
//                   newTransaction.transactionAmount = amount
//                   newTransaction.transactionName = name
//                   newTransaction.transactionDescription = desc
//                   newTransaction.transactionDate = datePicked
//                               
//                   try! realm.write {
//                       realm.add(newTransaction)
//                   }
//                   
//                   DataManager.shared.firstVC.tableView.reloadData()
//                   self.dismiss(animated: true, completion: nil)
//                   
//               default:
//                   print("Error")
//    }
//    }
//    
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        
//        self.getDate(date: date)
//        
//        print(datePicked)
//        
//        }
//    
//    func getDate(date: Date) {
//        datePicked = date as Date
//        print(datePicked)
//    }
//}
//
////public extension UIView {
////    //Round the corners
////    func roundCorners(){
////        let radius = bounds.maxX / 16
////        layer.cornerRadius = radius
////    }
////}
////
////extension UIApplication {
////    func endEditing() {
////        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
////    }
////}
////
