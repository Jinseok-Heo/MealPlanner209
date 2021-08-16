//
//  TabbarController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/07.
//

import UIKit
import FirebaseAuth
import NaverThirdPartyLogin

class TabbarController: UITabBarController {
    
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
}
