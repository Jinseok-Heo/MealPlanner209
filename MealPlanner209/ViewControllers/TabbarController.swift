//
//  TabbarController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/07.
//

import UIKit
import CoreData

class TabbarController: UITabBarController {
    
    var dataController: DataController!
    var fetchedResultController: NSFetchedResultsController<UserInfo>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is tabbar controller")
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        guard let fetchedObjects = fetchedResultController.fetchedObjects else {
            addUser()
            return
        }
        if fetchedObjects.count == 0 {
            print("Adding user..")
            addUser()
        } else if fetchedObjects.count == 1 {
            print("Found a user with uid: \(User.Auth.uid)")
            User.user = fetchedObjects.first
            print(User.user)
        } else {
            print(fetchedObjects)
            fatalError("There's duplicate user")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultController = nil
    }
    
}

extension TabbarController: NSFetchedResultsControllerDelegate {
    
    fileprivate func setUpFetchedResultsController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dataController = appDelegate.dataController
        
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        guard let uid = User.Auth.uid else {
            fatalError("Can't configure current uid")
        }
        let predicate = NSPredicate(format: "uid == %@", uid)
        let sortDescripter = NSSortDescriptor(key: "uid", ascending: false)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescripter]

        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func addUser() {
        var signInfo: Int = 0
        switch User.didSigninWith {
        case .Default:
            signInfo = 0
        case .Google:
            signInfo = 1
        case .Facebook:
            signInfo = 2
        case .Naver:
            signInfo = 3
        }
        let user = UserInfo(context: dataController.viewContext)
        user.uid = User.Auth.uid
        user.name = User.name
        user.signInInfo = Int16(signInfo)
        user.profilePhoto = User.profileImage
        
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError("Can't save user with error: \(error.localizedDescription)")
        }
        User.user = user
    }
}
