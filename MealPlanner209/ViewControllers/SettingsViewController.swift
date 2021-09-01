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
    @IBOutlet weak var tableView: UITableView!
    
    let settingItems: [String] = [
        "Edit profile",
        "Edit goal",
        "Sign out"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsCell
        cell.cellTitle.text = settingItems[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "ToEditProfile", sender: nil)
        case 1:
            performSegue(withIdentifier: "ToEditGoal", sender: nil)
        case 2:
            signOut()
        default:
            print("Invalid cell is tapped")
        }
    }
    
    func signOut() {
        switch User.didSigninWith {
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
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
