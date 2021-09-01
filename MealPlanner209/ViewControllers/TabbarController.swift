//
//  TabbarController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/07.
//

import UIKit
import CoreData

class TabbarController: UITabBarController {

    var fetchedResultController: NSFetchedResultsController<UserInfo>! = {
        return FetchedResultController.userFetchedResultController()
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        if (fetchedResultController.fetchedObjects?.count ?? 0) == 0 {
            addUser()
        } else if (fetchedResultController.fetchedObjects?.count ?? 0) == 1 {
            User.user = fetchedResultController.fetchedObjects?.first
        } else {
            fatalError("There's duplicate user")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultController = nil
    }
    
}

extension TabbarController: NSFetchedResultsControllerDelegate {

    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        guard let uid = User.Auth.uid else {
            fatalError("Can't configure current uid")
        }
        let predicate = NSPredicate(format: "uid == %@", uid)
        let sortDescripter = NSSortDescriptor(key: "uid", ascending: false)

        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescripter]
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
        let user = UserInfo(context: FetchedResultController.dataController.viewContext)
        user.uid = User.Auth.uid
        user.name = User.name
        user.birth = User.birth
        user.gender = User.gender?.rawValue
        user.signInInfo = Int16(signInfo)
        user.profilePhoto = User.profileImage
        user.maxCalories = 2500
        user.maxCarbs = 312.5
        user.maxProtein = 125
        user.maxFat = 83.33

        do {
            try FetchedResultController.dataController.viewContext.save()
        } catch {
            fatalError("Can't save user with error: \(error.localizedDescription)")
        }
        User.user = user
    }
}
