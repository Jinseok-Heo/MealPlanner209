//
//  FetchedResultControllers.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/31.
//

import Foundation
import CoreData
import UIKit

class FetchedResultController {
    
    static let dataController: DataController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.dataController
    }()
    
    static let currentDate: String = {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }()
    
    class func userFetchedResultController() -> NSFetchedResultsController<UserInfo> {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        let predicate = NSPredicate(format: "uid == %@", User.Auth.uid!)
        let sortDescripter = NSSortDescriptor(key: "uid", ascending: false)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescripter]

        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
        return fetchedResultController
    }

    class func historyFetchedResultController() -> NSFetchedResultsController<History> {
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", User.user!)
        let datePredicate = NSPredicate(format: "date == %@", FetchedResultController.currentDate)
        let sortDescripter = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescripter]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, datePredicate])

        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: FetchedResultController.dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
        return fetchedResultController
    }
    
    class func foodFetchedResultController(sort: String) -> NSFetchedResultsController<Food> {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", User.user!)
        let sortPredicate = NSPredicate(format: "sort == %@", sort)
        let sortDescripter = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, sortPredicate])
        fetchRequest.sortDescriptors = [sortDescripter]
        
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
        return fetchedResultController
    }
}
