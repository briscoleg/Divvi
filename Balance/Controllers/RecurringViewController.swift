//
//  RecurringViewController.swift
//  Balance
//
//  Created by Bo on 7/11/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

protocol IntervalDelegate {
    func getInterval(interval: String)
}

class RecurringViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - IBOutlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    //MARK: - Properties
    var pickerData = ["Yearly", "Monthly", "Every Two Weeks", "Weekly", "Daily", "Does Not Repeat"]
    var intervalPicked = "Monthly"
    var intervalDelegate: IntervalDelegate!
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        
        saveButton.roundCorners()
        
        picker.selectRow(1, inComponent: 0, animated: true)
        
    }
    
    //MARK: - Methods
    
    
    //MARK: - IBActions
    @IBAction func savePressed(_ sender: UIButton) {
        
        intervalDelegate.getInterval(interval: intervalPicked)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Picker Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        label.text = "Occurs \(pickerData[row])"
        intervalPicked = pickerData[row]
        print(intervalPicked)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
