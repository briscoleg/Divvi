//
//  RecurringViewController.swift
//  Balance
//
//  Created by Bo on 7/11/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

protocol RepeatDelegate {
    func getRepeatInterval(interval: String)
}

class RepeatVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - IBOutlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var repeatLabel: UILabel!
    
    //MARK: - Properties
    var pickerData = ["Yearly", "Monthly", "Every Two Weeks", "Weekly", "Daily", "Never"]
    var intervalPicked = "Monthly"
    var repeatDelegate: RepeatDelegate!
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        repeatLabel.text = "Repeats Monthly"
        
        saveButton.roundCorners()
        
        picker.selectRow(1, inComponent: 0, animated: true)
        
    }
    
    //MARK: - Methods
    
    
    //MARK: - IBActions
    @IBAction func savePressed(_ sender: UIButton) {
        
        repeatDelegate.getRepeatInterval(interval: intervalPicked)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Picker Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repeatLabel.text = "Repeats \(pickerData[row])"
        intervalPicked = pickerData[row]
        print(intervalPicked)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
