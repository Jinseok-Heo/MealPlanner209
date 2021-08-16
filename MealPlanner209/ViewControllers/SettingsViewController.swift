//
//  SettingsViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import NaverThirdPartyLogin
import FirebaseAuth

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsCell
        cell.cellTitle.text = "Sign out"
        
        return cell
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        signOut()
    }
    
    func signOut() {
        print("SignOut Tapped")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        switch appDelegate.user.didSigninWith {
        case .Default, .Google, .Facebook:
            print("Default or Google or Facebook")
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        case .Naver:
            print("Naver")
            let naverSignInInstance = NaverThirdPartyLoginConnection.getSharedInstance()
            naverSignInInstance?.requestDeleteToken()
        }
        appDelegate.user = User()
        self.navigationController?.popViewController(animated: true)
    }
}
