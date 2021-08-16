//
//  HomeViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeBarButton: UITabBarItem!
    @IBOutlet weak var caloriesBar: LinearProgressBar!
    @IBOutlet weak var carbsBar: CircleProgressBar!
    @IBOutlet weak var proteinsBar: CircleProgressBar!
    @IBOutlet weak var fatsBar: CircleProgressBar!
    
    @IBOutlet weak var defaultAddButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            User.Auth.uid = user.uid
        } else {
            return
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
    }
    
}
