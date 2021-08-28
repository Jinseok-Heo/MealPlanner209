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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    var dataController: DataController!
    var fetchedResultController: NSFetchedResultsController<History>!
    
    var currentCalories: CGFloat = 0
    var currentCarbs: CGFloat = 0
    var currentProtein: CGFloat = 0
    var currentFat: CGFloat = 0
    
    let maxCalories: CGFloat = 2700
    let maxCarbs: CGFloat = 1500
    let maxProtein: CGFloat = 120
    let maxFat: CGFloat = 800
    
    var favoriteListVC: FavoriteListViewController?
    var homeSubviews = [HomeSubView]()
    var itemCount: Int = 0
    
    let currentDate: String = {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Home"
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .green
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initButtonPosition()
        setupFetchedResultController()
        calculateNutrients()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultController = nil
        for subview in homeSubviews {
            subview.removeFromSuperview()
        }
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
        
        guard let user = User.user else { fatalError("Can't configure current user") }
        
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        let userPredicate = NSPredicate(format: "user == %@", user)
        let datePredicate = NSPredicate(format: "date == %@", currentDate)
        
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
        let height: CGFloat = 140
        let space: CGFloat = 10
        let buttonMaxY = defaultAddButton.frame.minY + scrollView.frame.minY
        var yFrame: CGFloat
        
        if buttonMaxY + height + space < self.view.bounds.maxY {
            yFrame = buttonMaxY + space
        } else {
            yFrame = buttonMaxY - defaultAddButton.frame.size.height - space - height
        }
        favoriteListVC.view.frame = CGRect(x: self.view.center.x - width / 2,
                                           y: yFrame,
                                           width: width,
                                           height: height)
        favoriteListVC.view.layer.borderWidth = 2
        favoriteListVC.view.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(favoriteListVC.view)
        self.addChild(favoriteListVC)
        // favoriteListVC.didMove(toParent: self)
    }
    
    private func moveButton(yDifference: CGFloat) {
        let newConstant = 100 + yDifference * CGFloat(itemCount)
        self.defaultAddButton.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: newConstant).isActive = true
        let timeInterval: TimeInterval = 1
        UIView.animate(withDuration: timeInterval) {
            self.defaultAddButton.center.y += yDifference * CGFloat(self.itemCount)
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
        removeSubView()
        viewWillAppear(true)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("Insert in home")
        case .delete:
            print("Delete in home")
        case .update:
            print("Update in home")
        case .move:
            print("Move")
        default:
            fatalError("Data controller type error")
        }
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

extension HomeViewController {
    
    private func initButtonPosition() {
        let initialConstant: CGFloat = 100
        self.defaultAddButton.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: initialConstant).isActive = true
    }
    
    private func setupSubviews(food: Food) {
        let currentButtonPosition = defaultAddButton.center
        moveButton(yDifference: 140 as CGFloat)
        let width = self.scrollContentView.bounds.width
        let height: CGFloat = 120
        let frame = CGRect(x: currentButtonPosition.x - width / 2,
                           y: currentButtonPosition.y - height / 2,
                           width: width,
                           height: height)
//        print("Food name: \(food.name), frame: \(frame)")
//        print("Button position: \(defaultAddButton.center)")
        
        let image: UIImage = {
            if let photo = food.photo {
                let image = UIImage(data: photo)
                return image ?? #imageLiteral(resourceName: "placeholder")
            } else {
                return #imageLiteral(resourceName: "placeholder")
            }
        }()
        
        let subView = HomeSubView(frame: frame, image: image, food: food, fetchedResultController: self.fetchedResultController)
        homeSubviews.append(subView)
        self.scrollContentView.addSubview(subView)
    }
    
    private func calculateNutrients() {
        guard let history = fetchedResultController.fetchedObjects?.first else {
            print("There is no history")
            return
        }
        
        guard let foods = history.foods else {
            print("There is no food")
            return
        }
        
        guard let foodsAsArray = foods.allObjects as? [Food] else {
            print("Can't convert foods as [Food]")
            return
        }
        
        itemCount = 0
        for food in foodsAsArray.reversed() {
            itemCount += 1
            currentCalories += CGFloat(food.calories)
            currentCarbs += CGFloat(food.carbohydrates)
            currentProtein += CGFloat(food.proteins)
            currentFat += CGFloat(food.fats)
            setupSubviews(food: food)
        }
//        print("scroll view size: \(scrollContentView.frame)")
        updateProgress()
    }
    
    private func updateProgress() {
        let caloriesProgress: CGFloat = currentCalories / maxCalories
        let carbsProgress: CGFloat = currentCarbs / maxCarbs
        let proteinProgress: CGFloat = currentProtein / maxProtein
        let fatProgress: CGFloat = currentFat / maxFat
        
        caloriesBar.progress = caloriesProgress
        carbsBar.progress = carbsProgress
        proteinsBar.progress = proteinProgress
        fatsBar.progress = fatProgress
    }
}
