//
//  ViewController.swift
//  Balance
//
//  Created by Bo on 6/22/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

class SummaryViewController: UIViewController, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var dateLabel: UILabel!
            
    let realm = try! Realm()
    
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         print(Realm.Configuration.defaultConfiguration.fileURL!)
                
        calendar.delegate = self
        
//        addButton.layer.shadowColor = UIColor.black.cgColor
//        addButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
//        addButton.layer.masksToBounds = false
//        addButton.layer.shadowRadius = 2.0
//        addButton.layer.shadowOpacity = 0.1
//        addButton.layer.cornerRadius = addButton.frame.width / 2
//        addButton.layer.borderColor = UIColor.black.cgColor
//        addButton.layer.borderWidth = 1.0
        
//        makeCircular(button: addButton)
        
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        displaySelectedDate(date)
        
    }
    
    func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM dd, yyyy"

        let dateString = formatter.string(from: date)
        
        dateLabel.text = dateString
                        
    }
    
    func makeCircular(button: UIButton) {
    addButton.layer.shadowColor = UIColor.black.cgColor
    addButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    addButton.layer.masksToBounds = false
    addButton.layer.shadowRadius = 2.0
    addButton.layer.shadowOpacity = 0.5
    addButton.layer.cornerRadius = addButton.frame.width / 2
    addButton.layer.borderColor = UIColor.black.cgColor
    addButton.layer.borderWidth = 2.0
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func addButton2Pressed(_ sender: UIBarButtonItem) {
    }
}
