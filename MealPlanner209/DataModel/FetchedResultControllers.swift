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
    
    private static let dataController: DataController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.dataController
    }()
    
    private static let currentDate: String = {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }()
    
    class func setHomeFetchedResultController() -> NSFetchedResultsController<History> {
        guard let user = User.user else { fatalError("Can't configure current user") }
        
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", user)
        let datePredicate = NSPredicate(format: "date == %@", FetchedResultController.currentDate)
        
        let sortDescripter = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescripter]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, datePredicate])

        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: FetchedResultController.dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(identifier: "HomeVC") as! HomeViewController
        fetchedResultController.delegate = homeVC.self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
        return fetchedResultController
    }
    
}
