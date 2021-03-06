//
//  AddFoodViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/18.
//

import Foundation
import UIKit
import CoreData
import DropDown

class AddFoodViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var foodNameTextfield: DesignableUITextField!
    @IBOutlet weak var foodCaloriesTextfield: DesignableUITextField!
    @IBOutlet weak var foodCarbsTextfield: DesignableUITextField!
    @IBOutlet weak var foodProteinsTextfield: DesignableUITextField!
    @IBOutlet weak var foodFatsTextfield: DesignableUITextField!
    
    @IBOutlet weak var carbsSort: UIPickerView!
    @IBOutlet weak var proteinsSort: UIPickerView!
    @IBOutlet weak var fatsSort: UIPickerView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let pickerDelegate = CustomPickerViewDelegate()
    let pickerData = ["g", "kcal"]
    
    var dataController: DataController!
    var fetchedResultController: NSFetchedResultsController<Food>!
    
    var textfields: [DesignableUITextField] = []
    var pickerViews: [UIPickerView] = []
    var totalCalories: Double = 0
    var foodSort: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPickerView()
        setupTextfield()
        setupFetchedResultController()
    }
    
    @IBAction func addImageButtonTapped(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.dataSource = ["Add image with album", "Add image with camera"]
        dropDown.anchorView = addImageButton
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.selectionAction = { (index: Int, item: String) in
            if index == 0 {
                self.pressedPickerViewController(source: .photoLibrary)
            } else {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.pressedPickerViewController(source: .camera)
                }
            }
            dropDown.clearSelection()
        }
        dropDown.show()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        addFood()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AddFoodViewController: NSFetchedResultsControllerDelegate {
    
    private func setupFetchedResultController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dataController = appDelegate.dataController
                
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Food.user), User.user!)
        
        let sortDescripter = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescripter]
        fetchRequest.predicate = predicate

        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func addFood() {
        if !checkTextfield() {
            self.notifyMessage(message: "Found empty textfield")
            return
        }
        
        let newFood = Food(context: dataController.viewContext)
        var totalCalories: Double = 0
        for (idx, textfield) in textfields.enumerated() {
            let text = textfield.text ?? "0"
            guard let number = Double(text) else {
                notifyMessage(message: "Invalid number")
                return
            }
            
            // Note: idx 0, 1, 2 -> carbs, proteins, fats
            if pickerData[pickerViews[idx].selectedRow(inComponent: 0)] == "g" {
                switch idx {
                case 0:
                    newFood.carbohydrates = number * Double(4)
                case 1:
                    newFood.proteins = number * Double(4)
                case 2:
                    newFood.fats = number * Double(9)
                default:
                    fatalError("Idx error")
                }
            } else {
                totalCalories += number
                switch idx {
                case 0:
                    newFood.carbohydrates = number
                case 1:
                    newFood.proteins = number
                case 2:
                    newFood.fats = number
                default:
                    fatalError("Idx error")
                }
            }
        }
        newFood.name = foodNameTextfield.text!
        newFood.sort = foodSort
        if let calories = foodCaloriesTextfield.text {
            newFood.calories = Double(calories)!
        } else {
            newFood.calories = self.totalCalories
        }
        newFood.user = User.user
        newFood.creationDate = Date()
        if let image = imageView.image {
            newFood.photo = image.pngData()
        } else {
            newFood.photo = UIImage(named: "placeholder")!.pngData()
        }
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AddFoodViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        if Double(newText as String) == nil {
            notifyMessage(title: "Text error", message: "Invalid number!")
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        calculateTotalCalories()
        self.foodCaloriesTextfield.text = String(self.totalCalories)
    }
    
}

extension AddFoodViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pressedPickerViewController(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let newImage = ImageHandler.resizeImage(image: image, targetSize: self.imageView.frame.size) else { return }
            self.imageView.image = newImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AddFoodViewController {
    
    private func setupPickerView() {
        self.carbsSort.delegate = pickerDelegate
        self.proteinsSort.delegate = pickerDelegate
        self.fatsSort.delegate = pickerDelegate
        
        pickerViews = [carbsSort, proteinsSort, fatsSort]
    }
    
    private func setupTextfield() {
        self.foodProteinsTextfield.delegate = self
        self.foodCarbsTextfield.delegate = self
        self.foodFatsTextfield.delegate = self
        
        textfields = [foodCarbsTextfield, foodProteinsTextfield, foodFatsTextfield]
    }
    
    private func checkTextfield() -> Bool {
        if foodNameTextfield.text == nil { return false }
        for textfield in textfields {
            if textfield.text == nil {
                return false
            }
        }
        return true
    }
    
    private func calculateTotalCalories() {
        totalCalories = 0
        for (idx, textfield) in textfields.enumerated() {
            if let text = textfield.text {
                guard let number = Double(text) else { return }
                if pickerData[pickerViews[idx].selectedRow(inComponent: 0)] == "g" {
                    if idx == 2 {
                        self.totalCalories += (number * Double(9))
                    } else {
                        self.totalCalories += (number * Double(4))
                    }
                } else {
                    totalCalories += number
                }
            }
        }
    }
    
    private func notifyMessage(title: String="Add failed", message: String?=nil) {
        let alertController = UIAlertController(title: "Add failed", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
