//
//  TabbarController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/07.
//

import UIKit
import FirebaseAuth

class TabbarController: UITabBarController {
    
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
