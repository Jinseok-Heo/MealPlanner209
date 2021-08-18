//
//  HomeViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import FirebaseAuth
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeBarButton: UITabBarItem!
    @IBOutlet weak var caloriesBar: LinearProgressBar!
    @IBOutlet weak var carbsBar: CircleProgressBar!
    @IBOutlet weak var proteinsBar: CircleProgressBar!
    @IBOutlet weak var fatsBar: CircleProgressBar!
    
    @IBOutlet weak var defaultAddButton: UIButton!
    
    var dataController: DataController!
    var fetchedResultController: NSFetchedResultsController<History>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is homeVC")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
    }
    
}

extension HomeViewController {
    
    private func setUpFetchedResultController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dataController = appDelegate.dataController
        
        let todayDate = Date()
        guard let user = User.user else { fatalError("Can't configure current user") }
        
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", user)
        let datePredicate = NSPredicate(format: "%K == %@", #keyPath(History.date), todayDate as NSDate)
        
        let sortDescripter = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescripter]
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, datePredicate])

        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}
