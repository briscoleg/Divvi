//
//  CalendarVC.swift
//  Balance
//
//  Created by Bo on 8/12/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar

protocol DateDelegate {
    func getCalendarDate(from date: Date)
}

class CalendarVC: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var dateDelegate: DateDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        
        chooseButton.roundCorners()

    }
    
    func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        
        if dateString == formatter.string(from: Date()) {
            dateLabel.text = "Today"
        } else {
            dateLabel.text = dateString
        }
        
    }
    
    @IBAction func chooseButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}

extension CalendarVC: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        dateDelegate.getCalendarDate(from: date)
        displaySelectedDate(date)
        
    }
    
}

extension CalendarVC: FSCalendarDataSource {
    
    
    
}
