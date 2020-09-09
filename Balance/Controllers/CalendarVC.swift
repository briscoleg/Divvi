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
    func getRepeatInterval(interval: String)
}
//protocol RepeatDelegate {
//    func getRepeatInterval(interval: String)
//}

class CalendarVC: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    var pickerData = ["Yearly", "Monthly", "Every Two Weeks", "Weekly", "Daily", ]
    var intervalPicked = "Never"
//    var repeatDelegate: RepeatDelegate!
    var dateDelegate: DateDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        picker.delegate = self
        picker.dataSource = self
        
        repeatSwitch.isOn = false
        picker.isHidden = true
        
        chooseButton.roundCorners()
        
        repeatLabel.text = "Repeat Transaction?"
        
        picker.selectRow(1, inComponent: 0, animated: true)

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
        
        dateDelegate.getRepeatInterval(interval: intervalPicked)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func repeatSwitchChanged(_ sender: UISwitch) {
        
        switch repeatSwitch.isOn {
        case false:
            picker.isHidden = true
            intervalPicked = "Never"
        case true:
            picker.isHidden = false
            intervalPicked = "Monthly"
            repeatLabel.text = "Repeats: Monthly"

        }
        
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

extension CalendarVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
}

extension CalendarVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repeatLabel.text = "Repeats: \(pickerData[row])"
        intervalPicked = pickerData[row]
        print(intervalPicked)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
