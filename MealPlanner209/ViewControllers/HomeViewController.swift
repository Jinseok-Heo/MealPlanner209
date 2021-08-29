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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    var addButton: UIButton!
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
    
    var favoriteListVC: FavoriteListViewController!
    var homeSubviews = [HomeSubView]()
    var buttonConstraint: NSLayoutConstraint!
    
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
        
        scrollContentView.layer.backgroundColor = UIColor.yellow.cgColor
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .green
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultController()
        homeSubviews = []
        setupButton()
        calculateNutrients()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultController = nil
        for subview in homeSubviews {
            NSLayoutConstraint.deactivate(subview.constraints)
            subview.removeFromSuperview()
        }
        NSLayoutConstraint.deactivate([buttonConstraint])
        buttonConstraint = nil
        
        homeSubviews = []
    }
    
    override func viewDidLayoutSubviews() {
        self.view.autoresizesSubviews = false
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

        let height: CGFloat = 140
        let space: CGFloat = 10
        
        favoriteListVC.view.layer.borderWidth = 2
        favoriteListVC.view.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(favoriteListVC.view)
        favoriteListVC.view.translatesAutoresizingMaskIntoConstraints = false
        favoriteListVC.view.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: space).isActive = true
        favoriteListVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        favoriteListVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 10).isActive = true
        favoriteListVC.view.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.addChild(favoriteListVC)
        // favoriteListVC.didMove(toParent: self)
    }
    
    private func removeSubView() {
        if let favoriteListVC = self.favoriteListVC {
            if self.view.subviews.contains(favoriteListVC.view) {
                NSLayoutConstraint.deactivate(favoriteListVC.view.constraints)
                favoriteListVC.view.removeFromSuperview()
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
    
    private func setupButton() {
        addButton = UIButton()
        addButton.frame.size = CGSize(width: 26.5, height: 26.5)
        let imageButton = ImageHandler.resizeImage(image: #imageLiteral(resourceName: "add"), targetSize: addButton.frame.size)
        addButton.setImage(imageButton, for: .normal)
        addButton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        
        scrollContentView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerXAnchor.constraint(equalTo: self.scrollContentView.centerXAnchor).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 26.5).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 26.5).isActive = true
        buttonConstraint = addButton.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 70)
        buttonConstraint!.isActive = true
    }
    
    @objc func addButtonClicked() {
        addSubCollectionView()
    }
    
    private func setupSubviews(food: Food) {
        let width = self.scrollContentView.bounds.width
        let height: CGFloat = 120
        let frame = CGRect(x: 0,
                           y: 0,
                           width: width,
                           height: height)
        
        let image: UIImage = {
            if let photo = food.photo {
                let image = UIImage(data: photo)
                return image ?? #imageLiteral(resourceName: "placeholder")
            } else {
                return #imageLiteral(resourceName: "placeholder")
            }
        }()
        
        let subView = HomeSubView(frame: frame, image: image, food: food, fetchedResultController: self.fetchedResultController)
        self.scrollContentView.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.widthAnchor.constraint(equalToConstant: width).isActive = true
        subView.heightAnchor.constraint(equalToConstant: height).isActive = true
        if let lastView = homeSubviews.last {
            subView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 20).isActive = true
        } else {
            subView.topAnchor.constraint(equalTo: self.scrollContentView.topAnchor).isActive = true
        }
        homeSubviews.append(subView)
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
        
        for food in foodsAsArray.reversed() {
            currentCalories += CGFloat(food.calories)
            currentCarbs += CGFloat(food.carbohydrates)
            currentProtein += CGFloat(food.proteins)
            currentFat += CGFloat(food.fats)
            setupSubviews(food: food)
        }
        updateButton()
        updateProgress()
    }
    
    private func updateButton() {
        NSLayoutConstraint.deactivate([buttonConstraint])
        if let lastView = homeSubviews.last {
            buttonConstraint = addButton.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 40)
        } else {
            buttonConstraint = addButton.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 70)
        }
        buttonConstraint.isActive = true
        let timeInterval: TimeInterval = 1
        UIView.animate(withDuration: timeInterval) {
            self.addButton.center.y += 140
        }
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
