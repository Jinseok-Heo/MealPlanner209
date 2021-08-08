//
//  LoginViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var naverButton: UIButton!
    @IBOutlet weak var button: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        // Test
        emailTextfield.text = "hjs7747@naver.com"
        passwordTextfield.text = "hh44061312!"
        
        if let _ = Auth.auth().currentUser {
            performSegue(withIdentifier: "SignInComplete", sender: nil)
        }
    }
    
    
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextfield.text ?? "", password: passwordTextfield.text ?? "") { (user, error) in
            if user != nil{
                print("login success")
                self.performSegue(withIdentifier: "SignInComplete", sender: nil)
            } else{
                fatalError("Failed login with error: \(error?.localizedDescription ?? "")")
                // TODO: Notification
            }
        }
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        print("Sign up button tapped")
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        signWithGoogleAuthentication()
    }
    
    @IBAction func naverButtonTapped(_ sender: Any) {
        
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    
}

extension LoginViewController {
    
    func signWithGoogleAuthentication() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    fatalError("Failed sign in with error: \(error.localizedDescription)")
                } else {
                    performSegue(withIdentifier: "SignInComplete", sender: nil)
                }
            }
            
        }
    }
    
}
