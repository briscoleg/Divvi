//
//  CalendarVC.swift
//  Balance
//
//  Created by Bo on 8/12/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

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
    case never = "Never"
}

class CalendarVC: UIViewController {
    
    static let identifier = "CalendarVC"
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    var intervalPicked = RepeatInterval.never.rawValue
    var dateDelegate: DateDelegate!
    let userDefaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        setCalendarScrollDirection()
        configureUI()

    }
    
    private func setupDelegates() {
        
        calendar.delegate = self
        calendar.dataSource = self
        picker.delegate = self
        picker.dataSource = self
        
    }
    
    private func configureUI() {
        
        calendar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        
        chooseButton.roundCorners()
        repeatLabel.text = "Repeats:"
        picker.selectRow(1, inComponent: 0, animated: true)
        repeatSwitch.isOn = false
        picker.isHidden = true
    }
    
    private func setCalendarScrollDirection() {
        
        if userDefaults.value(forKey: "calendarScrollDirection") as! String == "horizontal" {
            calendar.scrollDirection = .horizontal
        } else if userDefaults.value(forKey: "calendarScrollDirection") as! String == "vertical" {
            calendar.scrollDirection = .vertical
        }
        
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
    
    private func startingBalancePredicate(date: Date) -> NSPredicate {
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
            intervalPicked = RepeatInterval.monthly.rawValue
            repeatLabel.text = "Repeats: \(RepeatInterval.allCases[picker.selectedRow(inComponent: 0)].rawValue)"
        case false:
            picker.isHidden = true
            intervalPicked = RepeatInterval.never.rawValue
            repeatLabel.text = "Repeats: \(RepeatInterval.never.rawValue)"
        }
    }
}

//MARK: - Calendar Delegate
extension CalendarVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let realm = try! Realm()
        let startingBalanceDate = realm.objects(StartingBalance.self).filter(startingBalancePredicate(date: date))
        for _ in startingBalanceDate {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        return [UIColor(rgb: SystemColors.shared.blue)]
        
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
                
        calendar.appearance.todayColor = UIColor(rgb: SystemColors.shared.yellow)
        calendar.appearance.selectionColor = UIColor(rgb: SystemColors.shared.blue)
        calendar.appearance.weekdayTextColor = UIColor(rgb: SystemColors.shared.blue)
        calendar.appearance.headerTitleColor = UIColor(rgb: SystemColors.shared.blue)
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
        
    }
    
    
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
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return RepeatInterval.allCases[row].rawValue
        
    }
}
