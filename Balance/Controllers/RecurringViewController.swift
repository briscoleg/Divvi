//
//  RecurringViewController.swift
//  Balance
//
//  Created by Bo on 7/11/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class RecurringViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    var pickerData: [String] = ["Yearly", "Monthly", "Every Two Weeks", "Weekly", "Daily"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
       self.picker.dataSource = self
        
        saveButton.roundCorners()
        
        picker.selectRow(2, inComponent: 0, animated: true)

    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        label.text = "Occurs \(pickerData[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
}
