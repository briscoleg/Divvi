//
//  DetailViewController.swift
//  Balance
//
//  Created by Bo on 7/14/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import RealmSwift



class DetailVC: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    
    let realm = try! Realm()
    var transaction: Transaction?
//    var transaction: Results<Transaction>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        displayTransactionInfo()
        
    }
    
    func displayTransactionInfo() {
        
        descLabel.text = transaction?.transactionDescription
        repeatLabel.text = "Repeats: \(transaction!.repeatInterval)"
            
        formatNumber(transaction!.transactionAmount)
        formatDate(transaction!.transactionDate)
        
    }
    
    func formatNumber (_ number: Double) {
        
        if number > 0 {
            amountLabel.textColor = UIColor(rgb: Constants.green)
        } else if number < 0 {
            amountLabel.textColor = UIColor(rgb: Constants.red)
        }
        
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        
        let formattedNumber = formatter.string(from: NSNumber(value: number))
        
        amountLabel.text = formattedNumber
        
    }
    
    func formatDate (_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "EEEE\nMMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        
        dateLabel.text = dateString
                
    }

    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
