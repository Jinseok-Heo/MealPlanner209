//
//  EditGoalViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/31.
//

import UIKit
import CoreData

class EditGoalViewController: UIViewController {
    
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var proportionStackView: UIStackView!
    @IBOutlet weak var carbsProportionTextfield: DesignableUITextField!
    @IBOutlet weak var proteinProportionTextfield: DesignableUITextField!
    @IBOutlet weak var fatProportionTextfield: DesignableUITextField!
    @IBOutlet weak var caloriesTextfield: DesignableUITextField!
    @IBOutlet weak var carbsTextfield: DesignableUITextField!
    @IBOutlet weak var proteinTextfield: DesignableUITextField!
    @IBOutlet weak var fatTextfield: DesignableUITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let otherNutrientsTextfieldDelegate = OtherNutrientsTextfieldDelegate()
    
    var userFetchedResultController: NSFetchedResultsController<UserInfo>! = {
        return FetchedResultController.userFetchedResultController()
    }()
    
    var checkBoxState: Bool = false
    var calories: Double = 0.0
    var carbs: Double {
        var newText: String = "0.0"
        if let text = carbsTextfield.text {
            if text.contains("g") {
                newText = text.replacingOccurrences(of: "g", with: "")
            } else {
                newText = text
            }
        }
        return Double(newText) ?? 0.0
    }
    var protein: Double {
        var newText: String = "0.0"
        if let text = proteinTextfield.text {
            if text.contains("g") {
                newText = text.replacingOccurrences(of: "g", with: "")
            } else {
                newText = text
            }
        }
        return Double(newText) ?? 0.0
    }
    var fat: Double {
        var newText: String = "0.0"
        if let text = fatTextfield.text {
            if text.contains("g") {
                newText = text.replacingOccurrences(of: "g", with: "")
            } else {
                newText = text
            }
        }
        return Double(newText) ?? 0.0
    }
    var carbsProportion: Double {
        return Double(carbsProportionTextfield.text ?? "0.0") ?? 0.0
    }
    var proteinProportion: Double {
        return Double(proteinProportionTextfield.text ?? "0.0") ?? 0.0
    }
    var fatProportion: Double {
        return Double(fatProportionTextfield.text ?? "0.0") ?? 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        proportionStackView.isHidden = true
        caloriesTextfield.delegate = self
        carbsTextfield.delegate = otherNutrientsTextfieldDelegate.self
        proteinTextfield.delegate = otherNutrientsTextfieldDelegate.self
        fatTextfield.delegate = otherNutrientsTextfieldDelegate.self
        
        carbsProportionTextfield.delegate = self
        proteinProportionTextfield.delegate = self
        fatProportionTextfield.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userFetchedResultController = nil
    }
    
    @IBAction func checkBoxButtonTapped(_ sender: Any) {
        proportionStackView.isHidden = checkBoxState
        if checkBoxState {
            checkBoxButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            checkBoxState = false
        } else {
            checkBoxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            checkBoxState = true
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let user = userFetchedResultController.fetchedObjects?.first else {
            self.notifyMessage(message: "Can't find user")
            return
        }
        setLoading(isLoading: true)
        user.maxCalories = calories
        user.maxCarbs = carbs
        user.maxProtein = protein
        user.maxFat = fat
        
        do {
            try FetchedResultController.dataController.viewContext.save()
        } catch {
            setLoading(isLoading: false)
            fatalError("Can't save data")
        }
        User.user = user
        setLoading(isLoading: false)
        let alert = UIAlertController(title: "Saving success", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension EditGoalViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == caloriesTextfield {
            if textField.text?.contains("kcal") ?? false {
                let newText = textField.text!.replacingOccurrences(of: "kcal", with: "")
                textField.text = newText
                return true
            }
            var newText = textField.text! as NSString
            newText = newText.replacingCharacters(in: range, with: string) as NSString
            if newText.contains("kcal") {
                newText.replacingOccurrences(of: "kcal", with: "")
            }
            let newCalories = Double(newText as String)
            calories = newCalories ?? 0.0
        }
        if checkBoxState {
            calculateFromProportion()
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == caloriesTextfield {
            if let text = textField.text {
                if text.contains("kcal") {
                    return true
                } else {
                    textField.text = (textField.text ?? "0.0") + "kcal"
                }
            }
        }
        return true
    }
    
}

extension EditGoalViewController {
    
    private func calculateFromProportion() {
        let total = carbsProportion + proteinProportion + fatProportion
        if total == 0 {
            return
        }
        
        let calculatedCarbs = calories * carbsProportion / total / 4
        let calculatedProtein = calories * proteinProportion / total / 4
        let calculatedFat = calories * fatProportion / total / 9
        carbsTextfield.text = String(calculatedCarbs) + "g"
        proteinTextfield.text = String(calculatedProtein) + "g"
        fatTextfield.text = String(calculatedFat) + "g"
    }
    
    private func setLoading(isLoading: Bool) {
        cancelButton.isEnabled = !isLoading
        saveButton.isEnabled = !isLoading
        if isLoading {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func notifyMessage(message: String?=nil) {
        let alertController = UIAlertController(title: "Edit failed", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
