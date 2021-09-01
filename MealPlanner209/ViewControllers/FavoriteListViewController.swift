//
//  FavoriteListViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import CoreData
import DropDown

class FavoriteListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            flowLayout.estimatedItemSize = .zero
        }
    }

    var historyFetchedResultController: NSFetchedResultsController<History>! = {
        return FetchedResultController.historyFetchedResultController()
    }()
    var mealResultController: NSFetchedResultsController<Food>! = {
        return FetchedResultController.foodFetchedResultController(sort: "Meal")
    }()
    var snackResultController: NSFetchedResultsController<Food>! = {
        return FetchedResultController.foodFetchedResultController(sort: "Snack")
    }()
    var beverageResultController: NSFetchedResultsController<Food>! = {
        return FetchedResultController.foodFetchedResultController(sort: "Beverage")
    }()
    
    var numberOfMeal: Int {
        return mealResultController.sections?[0].numberOfObjects ?? 0
    }
    
    var numberOfSnack: Int {
        return snackResultController.sections?[0].numberOfObjects ?? 0
    }
    
    var numberOfBeverage: Int {
        return beverageResultController.sections?[0].numberOfObjects ?? 0
    }

    private let sectionTitle: [String] = ["Meal", "Snack", "Beverage"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.navigationItem.title = "Favorite List"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultControllerDelegate()
        self.collectionView.reloadData()
    }
    
}

extension FavoriteListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sectionTitle.count
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
            addFoodVC.foodSort = self.sectionTitle[indexPath.section]
            self.navigationController?.pushViewController(addFoodVC, animated: true)
        } else {
            let dropDown = DropDown()
            dropDown.dataSource = ["Add to foods today", "Remove from favorite list"]
            dropDown.anchorView = collectionView.cellForItem(at: indexPath)
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            
            dropDown.selectionAction = { (index: Int, item: String) in
                if index == 0 {
                    self.addFoodNotification(indexPath: indexPath)
                } else {
                    self.removeFoodNotification(indexPath: indexPath)
                }
                dropDown.clearSelection()
            }
            dropDown.show()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FavoriteListHeaderCell", for: indexPath) as! FavoriteListHeaderCell
        headerview.layer.borderWidth = 2
        headerview.layer.borderColor = UIColor.darkGray.cgColor
        headerview.layer.cornerRadius = 13
        headerview.sectionTitleLabel.text = self.sectionTitle[indexPath.section]
        headerview.sectionTitleLabel.font = UIFont(name: "Noteworthy Bold", size: 20)
        return headerview
    }
    
}

extension FavoriteListViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("Insert in favorite list")
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            print("Delete in favorite list")
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            print("Update in favorite list")
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            print("Move in favorite list")
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        default:
            fatalError("Data controller type error")
        }
    }
    
}

extension FavoriteListViewController {
    
    private func setupFetchedResultControllerDelegate() {
        mealResultController.delegate = self
        snackResultController.delegate = self
        beverageResultController.delegate = self
    }

    private func removeFoodNotification(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Remove food?", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            var food: Food
            switch indexPath.section {
            case 0:
                food  = self.mealResultController.object(at: IndexPath(row: indexPath.row, section: 0))
            case 1:
                food = self.snackResultController.object(at: IndexPath(row: indexPath.row, section: 0))
            case 2:
                food = self.snackResultController.object(at: IndexPath(row: indexPath.row, section: 0))
            default:
                fatalError("Section Error")
            }
            FetchedResultController.dataController.viewContext.delete(food)
            do {
                try FetchedResultController.dataController.viewContext.save()
            } catch {
                fatalError("Can't save data")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addFoodNotification(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Add food?", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            var food: Food
            switch indexPath.section {
            case 0:
                food  = self.mealResultController.object(at: IndexPath(row: indexPath.row, section: 0))
            case 1:
                food = self.snackResultController.object(at: IndexPath(row: indexPath.row, section: 0))
            case 2:
                food = self.beverageResultController.object(at: IndexPath(row: indexPath.row, section: 0))
            default:
                fatalError("Section Error")
            }

            if self.historyFetchedResultController.fetchedObjects?.count ?? 0 == 0 {
                let history = History(context: FetchedResultController.dataController.viewContext)
                history.date = FetchedResultController.currentDate
                history.user = User.user!
                history.addToFoods(food)
            } else {
                self.historyFetchedResultController.fetchedObjects?.first?.addToFoods(food)
            }
            
            do {
                try FetchedResultController.dataController.viewContext.save()
            } catch {
                fatalError("Can't save data")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
