//
//  HomeViewController.swift
//  MealPlanner209
//
//  Created by Jinseok on 2021/08/06.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var barStackView: UIStackView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    var caloriesBar: LinearProgressBar!
    var carbsBar: CircularProgressBar!
    var proteinBar: CircularProgressBar!
    var fatBar: CircularProgressBar!
    var addButton: UIButton!
    
    var fetchedResultController: NSFetchedResultsController<History>!
    
    var currentCalories: Double = 0
    var currentCarbs: Double = 0
    var currentProtein: Double = 0
    var currentFat: Double = 0
    
    let maxCalories: Double = User.user!.maxCalories
    let maxCarbs: Double = User.user!.maxCarbs
    let maxProtein: Double = User.user!.maxProtein
    let maxFat: Double = User.user!.maxFat
    
    var favoriteListVC: FavoriteListViewController!
    var homeSubviews = [HomeSubView]()
    var buttonConstraint: NSLayoutConstraint!
    var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGesture()
        setupNavigation()
        setupBars()
        scrollView.isScrollEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultController()
        updateSubView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultController = nil
        initSubView()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.autoresizesSubviews = false
    }
    
}

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if !(self.favoriteListVC?.view.bounds.contains(touch.location(in: self.favoriteListVC?.view)) ?? true) {
            removeSubCollectionView()
        }
        return !(self.favoriteListVC?.view.bounds.contains(touch.location(in: self.favoriteListVC?.view)) ?? true)
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        removeSubCollectionView()
        updateSubView()
    }
    
}

extension HomeViewController {
    
    // MARK: Setting
    private func setupFetchedResultController() {
        fetchedResultController = FetchedResultController.historyFetchedResultController()
        fetchedResultController.delegate = self
    }
    
    private func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupNavigation() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Home"
    }
    
    private func setupBars() {
        var linearFrame: CGRect

        let leftSpace: CGFloat = 10
        let barWidth = self.view.layer.bounds.width - caloriesLabel.frame.maxX - leftSpace - 20
        linearFrame = CGRect(x: caloriesLabel.frame.maxX + 10,
                             y: caloriesLabel.frame.origin.y,
                             width: barWidth,
                             height: caloriesLabel.frame.height)
        
        caloriesBar = LinearProgressBar(frame: linearFrame, maxValue: maxCalories, currentValue: currentCalories)
        self.contentView.addSubview(caloriesBar)
        caloriesBar.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 60).isActive = true
        
        let space = barStackView.spacing
        let width = (barStackView.frame.width - 2 * space) / 3
        let frame = CGRect(x: 0, y: 0, width: width, height: barStackView.frame.height)
        carbsBar = CircularProgressBar(frame: frame, title: "Carbs", maxValue: maxCarbs, currentValue: currentCarbs)
        proteinBar = CircularProgressBar(frame: frame, title: "Protein", maxValue: maxProtein, currentValue: currentProtein)
        fatBar = CircularProgressBar(frame: frame, title: "Fat     ", maxValue: maxFat, currentValue: currentFat)
        self.barStackView.addArrangedSubview(carbsBar)
        self.barStackView.addArrangedSubview(proteinBar)
        self.barStackView.addArrangedSubview(fatBar)
    }
    
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
    
    private func addSubCollectionView() {
        favoriteListVC = self.storyboard?.instantiateViewController(identifier: "FavoriteListVC") as? FavoriteListViewController
        favoriteListVC.historyFetchedResultController = self.fetchedResultController
        let height: CGFloat = 160
        let space: CGFloat = 20
        
        favoriteListVC.view.layer.borderWidth = 1.4
        favoriteListVC.view.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(favoriteListVC.view)
        favoriteListVC.view.translatesAutoresizingMaskIntoConstraints = false
        favoriteListVC.view.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: space).isActive = true
        favoriteListVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        favoriteListVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        favoriteListVC.view.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.addChild(favoriteListVC)
    }
    
    private func updateSubView() {
        initSubView()
        setupButton()
        calculateNutrients()
    }
    
    private func initSubView() {
        for subview in homeSubviews {
            NSLayoutConstraint.deactivate(subview.constraints)
            subview.removeFromSuperview()
        }
        homeSubviews = []
        
        if buttonConstraint != nil {
            NSLayoutConstraint.deactivate([buttonConstraint])
            buttonConstraint = nil
        }
        
        if addButton != nil {
            addButton.removeFromSuperview()
            addButton = nil
        }
    }
    
    private func removeSubCollectionView() {
        if let favoriteListVC = self.favoriteListVC {
            if self.view.subviews.contains(favoriteListVC.view) {
                NSLayoutConstraint.deactivate(favoriteListVC.view.constraints)
                favoriteListVC.view.removeFromSuperview()
            }
        }
    }
    
    @objc func addButtonClicked() {
        addSubCollectionView()
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
        
        currentCalories = 0
        currentCarbs = 0
        currentProtein = 0
        currentFat = 0
        
        for food in foodsAsArray.reversed() {
            currentCalories += food.calories
            currentCarbs += food.carbohydrates
            currentProtein += food.proteins
            currentFat += food.fats
            setupSubviews(food: food)
        }
        updateButton()
        updateBars()
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
    
    private func updateBars() {
        for subview in self.barStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        caloriesBar.removeConstraints(caloriesBar.constraints)
        caloriesBar.removeFromSuperview()
        setupBars()
    }
}
