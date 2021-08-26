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
    
    var favoriteListVC: FavoriteListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(tapGestureRecognizer)
        title = "Home"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultController = nil
    }
    
    override func viewDidLayoutSubviews() {
        self.view.autoresizesSubviews = false
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addSubCollectionView()
    }

}

extension HomeViewController {
    
    private func setupFetchedResultController() {
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
    
    private func addSubCollectionView() {
        favoriteListVC = self.storyboard?.instantiateViewController(identifier: "FavoriteListVC") as? FavoriteListViewController
        guard let favoriteListVC = self.favoriteListVC else {
            return
        }
        let width = self.view.bounds.width - 30
        let height: CGFloat = 100
        favoriteListVC.view.frame = CGRect(x: defaultAddButton.center.x - width / 2,
                                           y: defaultAddButton.frame.minY + 30,
                                           width: width,
                                           height: height)
        self.view.addSubview(favoriteListVC.view)
        self.addChild(favoriteListVC)
        // favoriteListVC.didMove(toParent: self)
    }
    
    private func moveButton() {
        print("Move button")
        let timeInterval: TimeInterval = 1
        UIView.animate(withDuration: timeInterval) {
            self.defaultAddButton.center.y += 200
        }
    }
    
    private func removeSubView() {
        if let favoriteListVC = self.favoriteListVC {
            if self.view.subviews.contains(favoriteListVC.view) {
                self.favoriteListVC?.view.removeFromSuperview()
            }
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

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if !(self.favoriteListVC?.view.bounds.contains(touch.location(in: self.favoriteListVC?.view)) ?? true) {
            removeSubView()
        }
        return !(self.favoriteListVC?.view.bounds.contains(touch.location(in: self.favoriteListVC?.view)) ?? true)
    }
}
