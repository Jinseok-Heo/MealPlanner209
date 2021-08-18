//
//  FavoriteListViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import CoreData

class FavoriteListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            flowLayout.estimatedItemSize = .zero
        }
    }
    
    var dataController: DataController!
    var fetchedResultController: NSFetchedResultsController<Favorites>!
    
    var mealResultController: NSFetchedResultsController<Favorites>!
    var snackResultController: NSFetchedResultsController<Favorites>!
    var beverageResultController: NSFetchedResultsController<Favorites>!
    
    var numberOfMeal: Int {
        return mealResultController.sections?[0].numberOfObjects ?? 0
    }
    
    var numberOfSnack: Int {
        return snackResultController.sections?[0].numberOfObjects ?? 0
    }
    
    var numberOfBeverage: Int {
        return beverageResultController.sections?[0].numberOfObjects ?? 0
    }
    
    private let section: [String] = ["Meal", "Snack", "Beverage"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultController()
        setUpMealResultController()
        setUpSnackResultController()
        setUpBeverageResultController()
    }
}

extension FavoriteListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.section.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return numberOfMeal + 1
        } else if section == 1 {
            return numberOfSnack + 1
        } else {
            return numberOfBeverage + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListDefaultCell", for: indexPath) as! FavoriteListDefaultCell
        return cell
//        if indexPath.section == 0 {
//            if indexPath.row == numberOfMeal {
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListDefaultCell", for: indexPath) as! FavoriteListDefaultCell
//                return cell
//            } else {
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListCell", for: indexPath) as! FavoriteListCell
//                cell.imageView = mealResultController.object(at: indexPath).foods.
//            }
//        } else if indexPath.section == 1 {
//
//        } else {
//
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Clicked")
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FavoriteListHeaderCell", for: indexPath) as! FavoriteListHeaderCell
        headerview.sectionTitleLabel.text = section[indexPath.section]
        return headerview
    }
    
}

extension FavoriteListViewController: NSFetchedResultsControllerDelegate {
    
    private func setUpFetchedResultController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dataController = appDelegate.dataController
                
        let fetchRequest: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let predicate = NSPredicate(format: "favorites.user == %@", User.user!)
        
        let sortDescripter = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescripter]
        fetchRequest.predicate = predicate

        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func setUpMealResultController() {
        let fetchRequest: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Favorites.foods.sort), "meal")
        let sortDescripter = NSSortDescriptor(key: "createionDate", ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescripter]
        
        mealResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: fetchedResultController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        mealResultController.delegate = self
        do {
            try mealResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func setUpSnackResultController() {
        let fetchRequest: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Favorites.foods.sort), "snack")
        let sortDescripter = NSSortDescriptor(key: "createionDate", ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescripter]
        
        snackResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: fetchedResultController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        snackResultController.delegate = self
        do {
            try snackResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func setUpBeverageResultController() {
        let fetchRequest: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Favorites.foods.sort), "beverage")
        let sortDescripter = NSSortDescriptor(key: "createionDate", ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescripter]
        
        beverageResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: fetchedResultController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        beverageResultController.delegate = self
        do {
            try beverageResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
}
