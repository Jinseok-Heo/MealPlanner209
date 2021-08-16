//
//  LoginViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import Firebase
import FirebaseAuthUI
import GoogleSignIn
import NaverThirdPartyLogin
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextfield: DesignableUITextField!
    @IBOutlet weak var passwordTextfield: DesignableUITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var naverButton: UIButton!
    
    let naverSignInInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        naverSignInInstance?.delegate = self
        // Test
        emailTextfield.text = "hjs7747@naver.com"
        passwordTextfield.text = "hh44061312!"
        
        if Auth.auth().currentUser !=  nil {
            appDelegate.user.didSigninWith = .Default
            performSegue(withIdentifier: "SignInComplete", sender: nil)
        } else if naverSignInInstance?.accessToken != nil {
            appDelegate.user.didSigninWith = .Naver
            performSegue(withIdentifier: "SignInComplete", sender: nil)
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextfield.text ?? "", password: passwordTextfield.text ?? "") { (user, error) in
            if user != nil{
                print("login success")
                self.performSegue(withIdentifier: "SignInComplete", sender: nil)
            } else {
                DispatchQueue.main.async {
                    self.notifyError()
                }
                fatalError("Failed login with error: \(error?.localizedDescription ?? "")")
            }
        }
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        print("Sign up button tapped")
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        facebookLogin()
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        signWithGoogleAuthentication()
    }
    
    @IBAction func naverButtonTapped(_ sender: Any) {
        naverSignInInstance?.requestThirdPartyLogin()
        
    }
    
}

extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success login")
        appDelegate.user.didSigninWith = .Naver
        performSegue(withIdentifier: "SignInComplete", sender: nil)
        //getInfo()
    }
    
    // referesh token
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print(naverSignInInstance?.accessToken ?? "Nil")
    }
        
    func oauth20ConnectionDidFinishDeleteToken() {
        print("log out")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("error = \(error.localizedDescription)")
    }
    
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
                    appDelegate.user.didSigninWith = .Google
                    performSegue(withIdentifier: "SignInComplete", sender: nil)
                }
            }
            
        }
    }
    
    func facebookLogin() {
        let fbLoginManager: LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if error != nil {
                NSLog("Process error")
            } else if result?.isCancelled == true {
                NSLog("Cancelled")
            } else {
                NSLog("Logged in")
                self.getFBUserData()
                try? Auth.auth().signOut()
                self.signInWithFacebookAuthentication()
            }
        }
    }
    
    func getFBUserData() {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields":"id, name, first_name, last_name, picture.type(large), email"]).start { (connection, result, error) in
                if error == nil {
                    guard let result = result else { return }
                    print(result)
                }
            }
        }
    }
    
    func signInWithFacebookAuthentication() {
        guard let token = AccessToken.current else { return }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                fatalError("Failed sign in with error: \(error.localizedDescription)")
            } else {
                self.appDelegate.user.didSigninWith = .Facebook
                self.performSegue(withIdentifier: "SignInComplete", sender: nil)
            }
        })
        
    }
    
    func notifyError() {
        let alertController = UIAlertController(title: "Login Failed", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
    }
    
}
