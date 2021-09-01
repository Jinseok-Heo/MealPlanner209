//
//  NutritionInfoTextfieldDelegate.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/09/01.
//

import Foundation
import UIKit

class CaloriesTextfieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = (textField.text ?? "0.0") + "kcal"
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.text = (textField.text ?? "0.0") + "kcal"
//    }
    
}

class OtherNutrientsTextfieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = (textField.text ?? "0.0") + "g"
        return true
    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.text = (textField.text ?? "0.0") + "g"
//    }
    
}
