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

enum RepeatInterval: String, CaseIterable {
    case yearly = "Yearly"
    case monthly = "Monthly"
    case twoWeeks = "Every Two Weeks"
    case weekly = "Weekly"
    case daily = "Daily"
}

class CalendarVC: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    var intervalPicked = "Never"
    var dateDelegate: DateDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        picker.delegate = self
        picker.dataSource = self
        
        repeatSwitch.isOn = false
        picker.isHidden = true
        
        chooseButton.roundCorners()
        
        repeatLabel.text = "Repeats:"
        
        picker.selectRow(1, inComponent: 0, animated: true)

    }
    
    private func displaySelectedDate(_ date: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = formatter.string(from: date)
        
        if dateString == formatter.string(from: Date()) {
            dateLabel.text = "Today"
        } else {
            dateLabel.text = dateString
        }
        
    }
    
    //MARK: - IBActions
    @IBAction func chooseButtonPressed(_ sender: UIButton) {
        
        dateDelegate.getRepeatInterval(interval: intervalPicked)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func repeatSwitchChanged(_ sender: UISwitch) {
        
        switch repeatSwitch.isOn {
        case true:
            picker.isHidden = false
            picker.selectRow(1, inComponent: 0, animated: true)
            repeatLabel.text = "Repeats: \(RepeatInterval.allCases[picker.selectedRow(inComponent: 0)].rawValue)"
        case false:
            picker.isHidden = true
            intervalPicked = "Never"
            repeatLabel.text = "Repeats: Never"
        }
    }
}

//MARK: - Calendar Delegate
extension CalendarVC: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        dateDelegate.getCalendarDate(from: date)
        displaySelectedDate(date)
        
    }
}

//MARK: - Picker Delegate & DataSource
extension CalendarVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RepeatInterval.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repeatLabel.text = "Repeats: \(RepeatInterval.allCases[row].rawValue)"
        intervalPicked = RepeatInterval.allCases[row].rawValue
        print(intervalPicked)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RepeatInterval.allCases[row].rawValue
    }
}
