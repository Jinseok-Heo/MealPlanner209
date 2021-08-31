//
//  EditProfileViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/31.
//

import UIKit
import CoreData
import FirebaseAuth
import DropDown

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdTextfield: DesignableUITextField!
    @IBOutlet weak var passwordTextfield: DesignableUITextField!
    @IBOutlet weak var verifiedPasswordTextfield: DesignableUITextField!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var changeImageButton: UIButton!
    
    let passwordTextfieldDelegate = PasswordTextfieldDelegate()
    
    let genderData: [String] = ["Male", "Female", "Unknown"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifiedPasswordTextfield.delegate = self
        passwordTextfield.delegate = passwordTextfieldDelegate.self
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func birthSelected(_ sender: UIDatePicker) {
        print(sender.date)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeImageButtonTapped(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.dataSource = ["Add image with album", "Add image with camera"]
        dropDown.anchorView = changeImageButton
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
    
}

extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderData.count
    }
    
}

extension EditProfileViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        if newText == (self.passwordTextfield.text ?? "") as NSString {
            verifiedLabel.textColor = .systemGreen
            verifiedLabel.text = passwordMessage(verified: true)
        } else {
            verifiedLabel.textColor = .red
            verifiedLabel.text = passwordMessage(verified: false)
        }
        return newText.length <= 15
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        
        if !passwordTest.evaluate(with: textField.text) {
            let alertController = UIAlertController(title: "Sign up Failed", message: "Invalid password!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
        }
    }
    
    private func passwordMessage(verified: Bool) -> String {
        if verified {
            return "Valid password!"
        } else {
            return "Invalid password                      Try again!"
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pressedPickerViewController(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let newImage = ImageHandler.resizeImage(image: image, targetSize: self.profileImageView.frame.size) else { return }
            self.profileImageView.image = newImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
