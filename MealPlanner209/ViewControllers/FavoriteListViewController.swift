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
    var fetchedResultController: NSFetchedResultsController<History>!
    
    var mealResultController: NSFetchedResultsController<Food>!
    var snackResultController: NSFetchedResultsController<Food>!
    var beverageResultController: NSFetchedResultsController<Food>!
    
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dataController = appDelegate.dataController
        setupMealResultController()
        setupSnackResultController()
        setupBeverageResultController()
        self.collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.fetchedResultController = nil
        self.mealResultController = nil
        self.snackResultController = nil
        self.beverageResultController = nil
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
        if indexPath.section == 0 {
            if indexPath.row == numberOfMeal {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListDefaultCell", for: indexPath) as! FavoriteListDefaultCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListCell", for: indexPath) as! FavoriteListCell
                guard let image = UIImage(data: mealResultController.object(at: indexPath).photo!) else {
                    cell.imageView.image = ImageHandler.resizeImage(image: UIImage(named: "user-2")!, targetSize: cell.imageView.frame.size)
                    return cell
                }
                cell.imageView.image = ImageHandler.resizeImage(image: image, targetSize: cell.imageView.frame.size)
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == numberOfSnack {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListDefaultCell", for: indexPath) as! FavoriteListDefaultCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListCell", for: indexPath) as! FavoriteListCell
                guard let image = UIImage(data: snackResultController.object(at: IndexPath(row: indexPath.row, section: 0)).photo!) else {
                    cell.imageView.image = ImageHandler.resizeImage(image: UIImage(named: "user-2")!, targetSize: cell.imageView.frame.size)
                    return cell
                }
                cell.imageView.image = ImageHandler.resizeImage(image: image, targetSize: cell.imageView.frame.size)
                return cell
            }
        } else {
            if indexPath.row == numberOfBeverage {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListDefaultCell", for: indexPath) as! FavoriteListDefaultCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteListCell", for: indexPath) as! FavoriteListCell
                guard let image = UIImage(data: beverageResultController.object(at: IndexPath(row: indexPath.row, section: 0)).photo!) else {
                    cell.imageView.image = ImageHandler.resizeImage(image: UIImage(named: "user-2")!, targetSize: cell.imageView.frame.size)
                    return cell
                }
                cell.imageView.image = ImageHandler.resizeImage(image: image, targetSize: cell.imageView.frame.size)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.row == numberOfMeal)
            || (indexPath.section == 1 && indexPath.row == numberOfSnack)
            || (indexPath.section == 2 && indexPath.row == numberOfBeverage) {
            let addFoodVC = self.storyboard?.instantiateViewController(identifier: "AddFoodVC") as! AddFoodViewController
            addFoodVC.foodSort = self.section[indexPath.section]
            self.navigationController?.pushViewController(addFoodVC, animated: true)
        } else {
            let history = History(context: dataController.viewContext)
            var food = Food(context: dataController.viewContext)
            food = mealResultController.object(at: indexPath)
            history.date = Date()
            switch indexPath.section {
            case 0:
                let foods =
            case 1:
                
            case 2:
                
            default:
                fatalError("Section Error")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FavoriteListHeaderCell", for: indexPath) as! FavoriteListHeaderCell
        headerview.sectionTitleLabel.text = self.section[indexPath.section]
        return headerview
    }
    
}

extension FavoriteListViewController: NSFetchedResultsControllerDelegate {
    
    private func setupFetchedResultController() {
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", User.user!)
        fetchRequest.predicate = userPredicate
        let sortDescripter = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescripter]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func setupMealResultController() {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", User.user!)
        let sortPredicate = NSPredicate(format: "sort == %@", "Meal")
        let sortDescripter = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, sortPredicate])
        fetchRequest.sortDescriptors = [sortDescripter]
        
        mealResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        mealResultController.delegate = self
        do {
            try mealResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func setupSnackResultController() {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", User.user!)
        let sortPredicate = NSPredicate(format: "sort == %@", "Snack")
        let sortDescripter = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, sortPredicate])
        fetchRequest.sortDescriptors = [sortDescripter]
        
        snackResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        snackResultController.delegate = self
        do {
            try snackResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func setupBeverageResultController() {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", User.user!)
        let sortPredicate = NSPredicate(format: "sort == %@", "Beverage")
        let sortDescripter = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, sortPredicate])
        fetchRequest.sortDescriptors = [sortDescripter]
        
        beverageResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        beverageResultController.delegate = self
        do {
            try beverageResultController.performFetch()
        } catch {
            fatalError("Fetch cannot be performed: \(error.localizedDescription)")
        }
    }
    
    private func addFood() {
        
    }
    
}
