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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        naverSignInInstance?.delegate = self
        // Test
        emailTextfield.text = "hjs7747@naver.com"
        passwordTextfield.text = "hh44061312!"
        
        if let user =  Auth.auth().currentUser {
            User.didSigninWith = .Default
            User.Auth.uid = user.uid
            self.performSegue(withIdentifier: "SignInComplete", sender: nil)
        }
        
        if naverSignInInstance?.accessToken != nil {
            User.didSigninWith = .Naver
            User.Auth.uid = naverSignInInstance?.accessToken
            self.performSegue(withIdentifier: "SignInComplete", sender: nil)
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextfield.text ?? "", password: passwordTextfield.text ?? "") { (user, error) in
            if let user = user  {
                User.Auth.uid = user.user.uid
                User.name = user.user.displayName
                User.userId = user.user.email
                User.profileImageURL = user.user.photoURL
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
        googleLogin()
    }
    
    @IBAction func naverButtonTapped(_ sender: Any) {
        naverSignInInstance?.requestThirdPartyLogin()
    }
    
}

extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success login")
        User.didSigninWith = .Naver
        self.performSegue(withIdentifier: "SignInComplete", sender: nil)
    }
    
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
    
    func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            signInWithFirebase(sort: 1, credential: credential)
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
        signInWithFirebase(sort: 3, credential: credential)
    }
    
    private func signInWithFirebase(sort: Int, credential: AuthCredential) {
        switch sort {
        case 0:
            User.didSigninWith = .Default
        case 1:
            User.didSigninWith = .Google
        case 2:
            User.didSigninWith = .Facebook
        case 3:
            User.didSigninWith = .Naver
        default:
            fatalError("Sort must be lower than 3")
        }
        
        if sort == 0 {
            Auth.auth().signIn(withEmail: emailTextfield.text ?? "",
                               password: passwordTextfield.text ?? "",
                               completion: handleSignInRequeset(authResult:error:))
        } else if sort < 3 {
            Auth.auth().signIn(with: credential, completion: handleSignInRequeset(authResult:error:))
        } else {
            
        }
        
    }
    
    private func handleSignInRequeset(authResult: AuthDataResult?, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.notifyError()
            }
            fatalError("Failed sign in with error: \(error.localizedDescription)")
        } else {
            guard let user = authResult else {
                fatalError("Can't configure current user")
            }
            User.Auth.uid = user.user.uid
            User.name = user.user.displayName
            User.userId = user.user.email
            User.profileImageURL = user.user.photoURL
            self.performSegue(withIdentifier: "SignInComplete", sender: nil)
        }
    }
    
    private func notifyError() {
        let alertController = UIAlertController(title: "Login Failed", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
    }
    
}
