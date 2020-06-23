//
//  ViewController.swift
//  Balance
//
//  Created by Bo on 6/22/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar

class ViewController: UIViewController, FSCalendarDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        
        displayTodaysDate()
        
                
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

//        selectDate(date)
        
        displaySelectedDate(date)
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateLabel.text = ""
    }
    
    func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM dd, yyyy"

        let stringDate = formatter.string(from: date)
        
        dateLabel.text = stringDate
                
    }
    
    
    
    func displayTodaysDate() {
        
        let todaysDate = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM dd, yyyy"
        
        let result = formatter.string(from: todaysDate)
        
        dateLabel.text = result
        
        
    }

}

