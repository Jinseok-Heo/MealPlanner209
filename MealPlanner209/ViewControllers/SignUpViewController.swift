//
//  SignUpViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: DesignableUITextField!
    @IBOutlet weak var passwordTextfield: DesignableUITextField!
    @IBOutlet weak var verifyPasswordTextfield: DesignableUITextField!
    @IBOutlet weak var nameTextfield: DesignableUITextField!
    @IBOutlet weak var userIDTextfield: DesignableUITextField!
    @IBOutlet weak var passwordMessageLabel: UILabel!
    @IBOutlet weak var userIDMessageLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let baseTextfieldDelegate = BaseTextfieldDelegate()
    let emailTextfieldDelegate = EmailTextfieldDelegate()
    let passwordTextfieldDelegate = PasswordTextfieldDelegate()
    
    var ableToSignUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setSignUpButton()
        setTextfieldDelegate()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let email = emailTextfield.text else {
            // TODO: Notify
            return
        }
        guard let password = passwordTextfield.text else {
            return
        }
        
        guard let verifiedPassword = verifyPasswordTextfield.text else {
            return
        }
        
        guard let name = nameTextfield.text else {
            return
        }
        
        guard let userId = userIDTextfield.text else {
            return
        }
        
        guard verifyPassword(password: password, verifiedPassword: verifiedPassword) == true else {
            return
        }
    
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let _ = authResult {
                Auth.auth().signIn(withEmail: self.emailTextfield.text ?? "", password: self.passwordTextfield.text ?? "") { (user, error) in
                    if user != nil{
                        print("login success")
                        User.name = name
                        User.userId = userId
                        print(user?.additionalUserInfo)
                        self.performSegue(withIdentifier: "SignUpComplete", sender: nil)
                    } else {
                        fatalError("Failed login with error: \(error?.localizedDescription ?? "")")
                    }
                }
            } else {
                // TODO: Notify Failure
                self.notifyMessage()
            }
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        if newText == (self.passwordTextfield.text ?? "") as NSString {
            passwordMessageLabel.textColor = .systemGreen
            passwordMessageLabel.text = passwordMessage(verified: true)
        } else {
            passwordMessageLabel.textColor = .red
            passwordMessageLabel.text = passwordMessage(verified: false)
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
    
}

extension SignUpViewController {
    
    private func setTextfieldDelegate() {
        emailTextfield.delegate = self.emailTextfieldDelegate
        passwordTextfield.delegate = self.passwordTextfieldDelegate
        verifyPasswordTextfield.delegate = self
        nameTextfield.delegate = self.baseTextfieldDelegate
        userIDTextfield.delegate = self.baseTextfieldDelegate
    }
    
    private func verifyPassword(password: String, verifiedPassword: String) -> Bool {
        // TODO: Check if password is valid
        if password != verifiedPassword {
            self.notifyMessage(message: "Password is not correct!")
            return false
        }
        if password.count < 6 || password.count > 12 {
            self.notifyMessage(message: "Invalid password!")
            return false
        }
        return true
    }
    
    private func setSignUpButton() {
        signUpButton.isEnabled = ableToSignUp
    }
    
    private func notifyMessage(message: String?=nil) {
        let alertController = UIAlertController(title: "Sign up Failed", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
    }
    
    private func passwordMessage(verified: Bool) -> String {
        if verified {
            return "Valid password!"
        } else {
            return "Invalid password                      Try again!"
        }
    }
}
