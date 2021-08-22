//
//  PickerViewDelegate.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/19.
//

import UIKit

class CustomPickerViewDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let value = ["g", "cal"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return value[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return value.count
    }
    
}

class FoodSortPickerViewDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let value = ["Meal", "Snack", "Beverage"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return value[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return value.count
    }
    
}
